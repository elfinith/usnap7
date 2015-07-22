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
    procedure BitBtn1Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ListBox2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  tst : TSnap7Device;

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
  with TSnap7Data.Create(StrToInt(ListBox2.Items.Strings[ListBox2.ItemIndex]), false) do try
    Edit5.Text := Name;
    Edit6.Text := IntToStr(Area);
    Edit7.Text := IntToStr(DBNum);
    Edit8.Text := IntToStr(DataStart);
    Edit9.Text := IntToStr(DataAmount);
    Edit10.Text := IntToStr(WLen);
    Edit11.Clear;
    for x := 0 to WordSize(DataAmount, WLen) - 1 do
      Edit11.Text := Edit11.Text + '$' + IntToHex(Buffer[x],2);
  finally
    Destroy;
  end;
end;

end.
