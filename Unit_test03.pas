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
    procedure BitBtn1Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
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
begin
  with TSnap7Device.Create(StrToInt(ListBox1.Items.Strings[ListBox1.ItemIndex])) do try
    Edit1.Text := Name;
    Edit2.Text := Addr;
    Edit3.Text := IntToStr(Rack);
    Edit4.Text := IntToStr(Slot);
  finally
    Free;
  end;
end;

end.
