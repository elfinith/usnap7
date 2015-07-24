unit Unit_test03;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, usnap7, StdCtrls, Buttons, DBCtrls;

type
  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    Edit1: TEdit;
    ListBox1: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Edit3: TEdit;
    Label4: TLabel;
    Edit4: TEdit;
    Button1: TButton;
    Button2: TButton;
    ListBox2: TListBox;
    Label5: TLabel;
    Edit5: TEdit;
    Label6: TLabel;
    Edit6: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    Edit7: TEdit;
    Edit8: TEdit;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Edit9: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Button3: TButton;
    Button4: TButton;
    CheckBox1: TCheckBox;
    Edit12: TEdit;
    Button5: TButton;
    Button6: TButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ListBox2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  tst : TSnap7Device;
  Poll : TSnap7Poll;

implementation

{$R *.dfm}

procedure TForm1.BitBtn1Click(Sender: TObject);
var
  i : integer;
begin
  ListBox1.Clear;
  with TSnap7WorkArea.Create do try
    for i := 0 to EnumDeviceIDs.Count - 1 do ListBox1.Items.Add(EnumDeviceIDs[i]);
  finally
    Free;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  with TSnap7Device.Create(StrToInt(ListBox1.Items.Strings[ListBox1.ItemIndex])) do try
    Name := Edit1.Text;
    Addr := Edit2.Text;
    Rack := StrToInt(Edit3.Text);
    Slot := StrToInt(Edit4.Text);
  finally
    Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i : integer;
begin
  ListBox1.Items.Clear;
  with TSnap7WorkArea.Create do try
    AddDevice(Edit1.Text,Edit2.Text,StrToInt(Edit3.Text),StrToInt(Edit4.Text));
    for i := 0 to EnumDeviceIDs.Count - 1 do ListBox1.Items.Add(EnumDeviceIDs[i]);
  finally
    Free;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  i : integer;
begin
  ListBox2.Items.Clear;
  with TSnap7Device.Create(StrToInt(ListBox1.Items.Strings[ListBox1.ItemIndex])) do try
    AddData(Edit5.Text,StrToInt(Edit6.Text),StrToInt(Edit7.Text),
      StrToInt(Edit8.Text),StrToInt(Edit9.Text),StrToInt(Edit10.Text));
    for i := 0 to EnumDataIDs.Count - 1 do ListBox2.Items.Add(EnumDataIDs[i]);
  finally
    Free;
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  x : integer;
  Buf : TDataBuffer;
begin
  with TSnap7Data.Create(StrToInt(ListBox2.Items.Strings[ListBox2.ItemIndex])) do try
    Name := Edit5.Text;
    Area := StrToInt(Edit6.Text);
    DBNum := StrToInt(Edit7.Text);
    DataStart := StrToInt(Edit8.Text);
    DataAmount := StrToInt(Edit9.Text);
    WLen := StrToInt(Edit10.Text);
    Async := CheckBox1.Checked;
    for x := 0 to WordSize(DataAmount,WLen) - 1 do Buf[x] := StrToIntDef(Edit12.Text,2);
    Buffer := Buf;
  finally
    Free;
  end;

end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  Poll := TSnap7Poll.Create(StrToInt(ListBox2.Items.Strings[ListBox2.ItemIndex]),5000);
  Poll.Start;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  Poll.Stop;
  Poll.Destroy;
end;

procedure TForm1.ListBox1Click(Sender: TObject);
var
  i : integer;
begin
  with TSnap7Device.Create(StrToInt(ListBox1.Items.Strings[ListBox1.ItemIndex])) do try
    Edit1.Text := Name;
    Edit2.Text := Addr;
    Edit3.Text := IntToStr(Rack);
    Edit4.Text := IntToStr(Slot);
    ListBox2.Items.Clear;
    for i := 0 to EnumDataIDs.Count - 1 do ListBox2.Items.Add(EnumDataIDs[i]);
  finally
    Destroy;
  end;
end;

procedure TForm1.ListBox2Click(Sender: TObject);
var
  x : integer;
begin
  with TSnap7Data.Create(StrToInt(ListBox2.Items.Strings[ListBox2.ItemIndex])) do try
    Edit5.Text := Name;
    Edit6.Text := IntToStr(Area);
    Edit7.Text := IntToStr(DBNum);
    Edit8.Text := IntToStr(DataStart);
    Edit9.Text := IntToStr(DataAmount);
    Edit10.Text := IntToStr(WLen);
    CheckBox1.Checked := Async;
    Edit11.Clear;
    for x := 0 to WordSize(DataAmount, WLen) - 1 do
      Edit11.Text := Edit11.Text + '$' + IntToHex(Buffer[x],2);
  finally
    Destroy;
  end;
end;

end.
