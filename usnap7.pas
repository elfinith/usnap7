  unit uSnap7;

interface

uses
  IBDatabase, IBQuery, IBSQL, SysUtils, Classes, Dialogs, Snap7, DB, RyTimer, DBTables;

const
  strDatabaseName = 'D:\WORK\Projects\Delphi\snap7\database\dbase.fdb';
  arrDBConnParams : array[0..2] of string = (
    'user_name=sysdba', 'PASSWORD=masterkey', 'lc_ctype=win1251'
  );
  strErrorDBConnect = '������ ���������� � ��';
  strErrorSQLExec = '������ ���������� SQL : ';
  strErrorDeviceConnect = '������ ����������� � ���������� ';
  strDefaultAddr = '127.0.0.1';
  strDefaultName = '������� ������';
  iDataBufferSize = 4095;
  iDefaultRack = 0;
  iDefaultSlot = 2;
  amPolling  = 0;
  amEvent    = 1;
  amCallBack = 2;

  AreaOf : array[0..5] of byte = (
    S7AreaDB, S7AreaPE, S7AreaPA, S7AreaMK, S7AreaTM, S7AreaCT
  );

  WLenOf : array[0..6] of integer = (
    S7WLBit, S7WLByte, S7WLWord, S7WLDword, S7WLReal, S7WLCounter, S7WLTimer
  );

type

  TDataBuffer = packed array [0..iDataBufferSize] of byte;

  TSelectQuery = class(TObject)
  private
    Database : TIBDatabase;
    Transaction : TIBTransaction;
  public
    Data : TIBQuery;
    constructor Create(SQL : string);
    destructor Destroy;
  end;

  TSnap7WorkArea = class(TObject)
  private
    slEnumDeviceIDs : TStringList;
    function GetDeviceIDs : TStringList;
  public
    property EnumDeviceIDs : TStringList read GetDeviceIDs;
    procedure AddDevice(strName : string; strAddr : string; iRack : integer; iSlot : integer);
    constructor Create;
    destructor Destroy;
  end;

  TSnap7Device = class(TObject)
  private
    fId : integer;
    fName : string;
    fAddr : string;
    fRack : integer;
    fSlot : integer;
    slEnumDataIDs : TStringList;
    function GetId : integer;
    function GetName : string;
    procedure SetName(NewName : string);
    function GetAddr : string;
    procedure SetAddr(NewAddr : string);
    function GetRack : integer;
    procedure SetRack(NewRack : integer);
    function GetSlot : integer;
    procedure SetSlot(NewSlot : integer);
    function GetDataIDs : TStringList;
  public
    ClientConnection : TS7Client;
    constructor Create(DEV_ID: integer);
    destructor Destroy;
    property Id : integer read GetId;
    property Name : string read GetName write SetName;
    property Addr : string read GetAddr write SetAddr;
    property Rack : integer read GetRack write SetRack;
    property Slot : integer read GetSlot write SetSlot;
    property EnumDataIDs : TStringList read GetDataIDs;
    function Connect : boolean;
    procedure AddData(strName : string; iAreaId, iDBNum, iDataStart, iDataAmount, iWLenId : integer);
  end;

  TSnap7Data = class(TObject)
  private
    fId : integer;
    fName : string;
    fArea : integer;
    fDBNum : integer;
    fDataStart : integer;
    fDataAmount : integer;
    fWLen : integer;
    fBuffer : TDataBuffer; // 4 K buffer
    fAsync : boolean;
    fLastError: integer;
    function GetId : integer;
    function GetName : string;
    procedure SetName(strName : string);
    function GetArea : integer;
    procedure SetArea(iAreaId : integer);
    function GetDBNum : integer;
    procedure SetDBNum(iDBNum : integer);
    function GetDataStart : integer;
    procedure SetDataStart(iDataStart : integer);
    function GetDataAmount : integer;
    procedure SetDataAmount(iDataAmount : integer);
    function GetWLen : integer;
    procedure SetWLen(iWLenId : integer);
    function GetBuffer : TDataBuffer;
    procedure SetBuffer(Buf : TDataBuffer);
    function GetAsync : boolean;
    procedure SetAsync(bAsync : boolean);
    procedure SetFLastError(const Value: integer);
  public
    Device : TSnap7Device;
    constructor Create(DM_ID : integer);
    destructor Destroy;
    property Id : integer read GetId;
    property Name : string read GetName write SetName;
    property Area : integer read GetArea write SetArea;
    property DBNum : integer read GetDBNum write SetDBNum;
    property DataStart : integer read GetDataStart write SetDataStart;
    property DataAmount : integer read GetDataAmount write SetDataAmount;
    property WLen : integer read GetWLen write SetWLen;
    property Buffer : TDataBuffer read GetBuffer write SetBuffer;
    property Async : boolean read GetAsync write SetAsync;
    property LastError : integer read fLastError write SetFLastError;
    function WordSize(Amount, WordLength: integer) : integer;
  end;

  TSnap7Poll = class(TObject)
  private
    fDM_ID : integer;
    Timer: TRyTimer;
  public
    // !!!!! ������� � private �����
    procedure GetData(Sender: TObject);

    procedure Start;
    procedure Stop;
    constructor Create(DM_ID, interval : integer);
    destructor Destroy;
  end;

var
  JobDone : boolean = false;
  JobResult : integer = 0;

implementation

procedure UpdateQuery(strQuery: string);
var
  i : byte;
  DB : TIBDatabase;
  DBt : TIBTransaction;
begin
  DB := TIBDatabase.Create(nil);
  DBt := TIBTransaction.Create(nil);
  DB.DatabaseName := strDatabaseName;
  DB.LoginPrompt := false;
  for i := 0 to length(arrDBConnParams) - 1 do DB.Params.Add(arrDBConnParams[i]);
  DB.DefaultTransaction := DBt;
  try
    DB.Connected := true;
    DBt.Active := true;
    with TIBSQL.Create(nil) do try
      Database := DB;
      Transaction := DBt;
      SQL.Text := strQuery;
      ExecQuery;
    finally
      Free;
    end;
  except
    raise Exception.Create(strErrorSQLExec + strQuery);
  end;
  DBt.Free;
  DB.Free;
end;

procedure CliCompletion(usrPtr : pointer; opCode, opResult : integer); {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}
begin
  JobResult := opResult;
  JobDone := true;
end;

{ TSelectQuery }

constructor TSelectQuery.Create(SQL : string);
var
  i : byte;
begin
  inherited Create;
  Database := TIBDatabase.Create(nil);
  Transaction := TIBTransaction.Create(nil);
  Database.DatabaseName := strDatabaseName;
  Database.LoginPrompt := false;
  for i := 0 to length(arrDBConnParams) - 1 do Database.Params.Add(arrDBConnParams[i]);
  Database.DefaultTransaction := Transaction;
  try
    Database.Connected := true;
    Transaction.Active := true;
  except
    raise Exception.Create(strErrorDBConnect);
  end;
  Data := TIBQuery.Create(nil);
  Data.Database := Database;
  Data.Transaction := Transaction;
  Data.SQL.Text := SQL;
  try
    Data.Open;
  except
    raise Exception.Create(strErrorSQLExec + SQL);
  end;
end;

destructor TSelectQuery.Destroy;
begin
  Data.Free;
  Transaction.Free;
  Database.Free;
  inherited Destroy;
end;

{ TSnap7WorkArea }

function TSnap7WorkArea.GetDeviceIDs;
begin
  GetDeviceIDs := slEnumDeviceIDs;
end;

procedure TSnap7WorkArea.AddDevice(strName : string; strAddr : string;
  iRack : integer; iSlot : integer);
var
  newID : integer;
begin
  with TSelectQuery.Create('select max(dev_id) from device;') do try
    newID := Data.Fields[0].AsInteger + 1;
  finally
    Destroy;
  end;
  UpdateQuery('insert into device(dev_id,name,addr,rack,slot) values('
    + IntToStr(newID) + ',''' + strName + ''',''' + strAddr + ''',' + IntToStr(iRack)
    + ',' + IntToStr(iSlot) + ')');
  slEnumDeviceIDs.Add(IntToStr(newID));
end;

constructor TSnap7WorkArea.Create;
begin
  inherited Create;
  slEnumDeviceIDs := TStringList.Create;
  with TSelectQuery.Create('select dev_id from device order by dev_id;').Data do try
    while not(EOF) do begin
      slEnumDeviceIDs.Add(IntToStr(Fields[0].AsInteger));
      Next;
    end; // while not(EOF)
  finally
    Destroy;
  end;
end;

destructor TSnap7WorkArea.Destroy;
begin
  slEnumDeviceIDs.Free;
  inherited Destroy;
end;

{ TSnap7Device }

function TSnap7Device.GetId : integer;
begin
  Getid := fId;
end;

procedure TSnap7Device.SetName(NewName : string);
begin
  UpdateQuery('update device set device.name = ''' + NewName
    + ''' where device.dev_id=' + IntToStr(fId) + ';');
  fName := NewName;
end;

function TSnap7Device.GetName : string;
begin
  GetName := fName;
end;

procedure TSnap7Device.SetAddr(NewAddr : string);
begin
  UpdateQuery('update device set device.addr = ''' + NewAddr
    + ''' where device.dev_id=' + IntToStr(fId) + ';');
  fAddr := NewAddr;
end;

function TSnap7Device.GetAddr : string;
begin
  GetAddr := fAddr;
end;

procedure TSnap7Device.SetRack(NewRack : integer);
begin
  UpdateQuery('update device set device.rack = ' + IntToStr(NewRack)
    + ' where device.dev_id=' + IntToStr(fId) + ';');
  fRack := NewRack;
end;

function TSnap7Device.GetRack : integer;
begin
  GetRack := fRack;
end;

procedure TSnap7Device.SetSlot(NewSlot : integer);
begin
  UpdateQuery('update device set device.slot = ' + IntToStr(NewSlot)
    + ' where device.dev_id=' + IntToStr(fId) + ';');
  fSlot := NewSlot;
end;

function TSnap7Device.GetSlot : integer;
begin
  GetSlot := fSlot;
end;

function TSnap7Device.Connect : boolean;
begin
  Result := ClientConnection.ConnectTo(fAddr, fRack, fSlot) = 0;
end;

function TSnap7Device.GetDataIDs;
begin
  GetDataIDs := slEnumDataIDs;
end;

procedure TSnap7Device.AddData(strName : string; iAreaId, iDBNum, iDataStart,
  iDataAmount, iWLenId : integer);
var
  newID : integer;
begin
  with TSelectQuery.Create('select max(dm_id) from data_map where dev_id='
  + IntToStr(fId) + ';') do try
    newID := Data.Fields[0].AsInteger + 1;
  finally
    Destroy;
  end;
  UpdateQuery('insert into data_map(dm_id,name,dev_id,area_id,db_num,data_start,'
    + 'data_amount,wlen_id) values(' + IntToStr(newID) + ',''' + strName + ''','
    + IntToStr(fId) + ',' + IntToStr(iAreaId) + ',' + IntToStr(iDBNum) + ',' + IntToStr(iDataStart)
    + ',' + IntToStr(iDataAmount) + ',' + IntToStr(iWLenId) + ');');
  slEnumDataIDs.Add(IntToStr(newID));
end;

constructor TSnap7Device.Create(DEV_ID: integer);
begin
  inherited Create;
  with TSelectQuery.Create('select addr, rack, slot, name from device where dev_id = '
  + IntToStr(DEV_ID) + ';').Data do try
    fId := DEV_ID;
    if RecordCount > 0 then begin
      fAddr := Fields[0].AsString;
      fRack := Fields[1].AsInteger;
      fSlot := Fields[2].AsInteger;
      fName := Fields[3].AsString;
    end
    else begin
      fAddr := strDefaultAddr;
      fRack := iDefaultRack;
      fSlot := iDefaultSlot;
      fName := strDefaultName;
    end;
  finally
    Destroy;
  end;
  slEnumDataIDs := TStringList.Create;
  with TSelectQuery.Create('select data_map.dm_id from data_map, device '
  + 'where (device.dev_id = data_map.dev_id) and (device.dev_id = ' + IntToStr(fId)
  + ')').Data do try
    while not(EOF) do begin
      slEnumDataIDs.Add(IntToStr(Fields[0].AsInteger));
      Next;
    end; // while not(EOF)
  finally
    Destroy;
  end;
  ClientConnection := TS7Client.Create;
//  ClientConnection.SetAsCallback(@CliCompletion, nil);
  if not(Connect) then raise Exception.Create(strErrorDeviceConnect + fAddr + ':'
    + IntToStr(fRack) + ':' + IntToStr(fSlot));
end;

destructor TSnap7Device.Destroy;
begin
  slEnumDataIDs.Free;
  ClientConnection.Free;
  inherited Destroy;
end;

{ TSnap7Data }

function TSnap7Data.GetId : integer;
begin
  Getid := fId;
end;

function TSnap7Data.GetName : string;
begin
  GetName := fName;
end;

procedure TSnap7Data.SetName(strName : string);
begin
  UpdateQuery('update data_map set name = ''' + strName  + ''' where dm_id=' + IntToStr(fId) + ';');
  fName := strName;
end;

function TSnap7Data.GetArea : integer;
begin
  GetArea := fArea;
end;

procedure TSnap7Data.SetArea(iAreaId : integer);
begin
  UpdateQuery('update data_map set area_id = ' + IntToStr(iAreaId)
    + ' where dm_id=' + IntToStr(fId) + ';');
  fArea := iAreaId;
end;

function TSnap7Data.GetDBNum : integer;
begin
  GetDBNum := fDBNum;
end;

procedure TSnap7Data.SetDBNum(iDBNum : integer);
begin
  UpdateQuery('update data_map set db_num = ' + IntToStr(iDBNum)
    + ' where dm_id=' + IntToStr(fId) + ';');
  fDBNum := iDBNum;
end;

function TSnap7Data.GetDataStart : integer;
begin
  GetDataStart := fDataStart;
end;

procedure TSnap7Data.SetDataStart(iDataStart : integer);
begin
  UpdateQuery('update data_map set data_start = ' + IntToStr(iDataStart)
    + ' where dm_id=' + IntToStr(fId) + ';');
  fDataStart := iDataStart;
end;

function TSnap7Data.GetDataAmount : integer;
begin
  GetDataAmount := fDataAmount;
end;

procedure TSnap7Data.SetDataAmount(iDataAmount : integer);
begin
  UpdateQuery('update data_map set data_amount = ' + IntToStr(iDataAmount)
    + ' where dm_id=' + IntToStr(fId) + ';');
  fDataAmount := iDataAmount;
end;

function TSnap7Data.GetWLen : integer;
begin
  GetWLen := fWLen;
end;

procedure TSnap7Data.SetWLen(iWLenId : integer);
begin
  UpdateQuery('update data_map set wlen_id = ' + IntToStr(iWlenId)
    + ' where dm_id=' + IntToStr(fId) + ';');
  fWlen := iWlenId;
end;

function TSnap7Data.GetBuffer : TDataBuffer;
begin
  GetBuffer := fBuffer;
end;

procedure TSnap7Data.SetBuffer(Buf : TDataBuffer);
var
  DEV_ID, x : integer;
begin
  with TSelectQuery.Create('select dev_id from data_map where dm_id=' + IntToStr(fId) + ';').Data do
  try
    DEV_ID := Fields[0].AsInteger;
  finally
    Destroy;
  end;
  with TSnap7Device.Create(DEV_ID) do try
    if fAsync then
      LastError := ClientConnection.AsWriteArea(AreaOf[fArea],fDBNum,fDataStart,fDataAmount,WLenOf[fWLen],@Buf)
    else
      LastError := ClientConnection.WriteArea(AreaOf[fArea],fDBNum,fDataStart,fDataAmount,WLenOf[fWLen],@Buf);
  finally
    Destroy;
  end;
end;

function TSnap7Data.GetAsync : boolean;
begin
  GetAsync := fAsync;
end;

procedure TSnap7Data.SetAsync(bAsync : boolean);
begin
  if bAsync then UpdateQuery('update data_map set async=1 where dm_id=' + IntToStr(fId) + ';')
  else UpdateQuery('update data_map set async=0 where dm_id=' + IntToStr(fId) + ';');
  fAsync := bAsync;
end;

function TSnap7Data.WordSize(Amount, WordLength: integer): integer;
begin
  case WLenOf[WordLength] of
    S7WLBit : Result := Amount * 1;  // S7 sends 1 byte per bit
    S7WLByte : Result := Amount * 1;
    S7WLWord : Result := Amount * 2;
    S7WLDword : Result := Amount * 4;
    S7WLReal : Result := Amount * 4;
    S7WLCounter : Result := Amount * 2;
    S7WLTimer : Result := Amount * 2;
  else
    Result := 0;
  end;
end;

procedure TSnap7Data.SetFLastError(const Value: integer);
begin
  FLastError := Value;
end;

constructor TSnap7Data.Create(DM_ID: integer);
begin
  inherited Create;
  with TSelectQuery.Create('select data_map.name, data_map.area_id, data_map.db_num, '
  + 'data_map.data_start, data_map.data_amount, data_map.wlen_id, data_map.dev_id, data_map.async '
  + 'from data_map, area, wlen where (data_map.dm_id = ' + IntToStr(DM_ID) + ') ').Data do
  try
    if RecordCount > 0 then begin
      fId := DM_ID;
      fName := Fields[0].AsString;
      fArea := Fields[1].AsInteger;
      fDBNum := Fields[2].AsInteger;
      fDataStart := Fields[3].AsInteger;
      fDataAmount := Fields[4].AsInteger;
      fWLen := Fields[5].AsInteger;
      fAsync := Fields[7].AsInteger = 1;
      with TSnap7Device.Create(Fields[6].AsInteger) do try
        if fAsync then
          LastError := ClientConnection.AsReadArea(
            AreaOf[fArea], DBNum, DataStart, DataAmount, WLenOf[fWLen], @fBuffer)
        else
          LastError := ClientConnection.ReadArea(
            AreaOf[fArea], DBNum, DataStart, DataAmount, WLenOf[fWLen], @fBuffer);
      finally
        Destroy;
      end;
    end
    else begin
      raise Exception.Create('Data description not found');
    end;
  finally
    Destroy;
  end;
end;

destructor TSnap7Data.Destroy;
begin
  inherited Destroy;
end;

{ TSnap7Poll }

procedure TSnap7Poll.Start;
begin
  Timer.Start;
end;

procedure TSnap7Poll.Stop;
begin
  Timer.Stop;
end;

procedure TSnap7Poll.GetData(Sender: TObject);
var
  i : byte;
  DB : TIBDatabase;
  DBt : TIBTransaction;
  ms: TMemoryStream;
  strQuery : string;
  Qry : TIBSQL;
  Buf : TDataBuffer;
begin
  DB := TIBDatabase.Create(nil);
  DBt := TIBTransaction.Create(nil);
  DB.DatabaseName := strDatabaseName;
  DB.LoginPrompt := false;
  for i := 0 to length(arrDBConnParams) - 1 do DB.Params.Add(arrDBConnParams[i]);
  DB.DefaultTransaction := DBt;
  strQuery := 'insert into data_values(dm_id,poll_time,poll_data) values('
    + IntToStr(fDM_ID) + ',''' + FormatDateTime('dd/mm/yyyy hh:MM:ss', Now()) + ''',:data_value);';
  try
    with TSnap7Data.Create(fDM_ID) do try
      Buf := Buffer;
    finally
      Destroy;
    end;
    DB.Connected := true;
    DBt.Active := true;
    with TIBSQL.Create(nil) do try
      Database := DB;
      Transaction := DBt;
      ParamCheck := True;
      SQL.Text := strQuery;
      Prepare;
      ms := TMemoryStream.Create;
      ms.Write(Buf,SizeOf(Buf));
      ParamByName('data_value').LoadFromStream(ms);
      ExecQuery;
      ms.Free;
    finally
      Free;
    end;
    DBt.Free;
    DB.Free;
  except
    raise Exception.Create(strErrorSQLExec + strQuery);
  end;
end;

constructor TSnap7Poll.Create(DM_ID, interval : integer);
begin
  inherited Create;
  fDM_ID := DM_ID;
  Timer := TRyTimer.Create;
  Timer.Interval := interval;
  Timer.OnTimer := GetData;
end;

destructor TSnap7Poll.Destroy;
begin
  Timer.Free;
  inherited Destroy;
end;

end.
