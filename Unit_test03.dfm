object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 282
  ClientWidth = 418
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 152
    Top = 13
    Width = 27
    Height = 13
    Caption = 'Name'
  end
  object Label2: TLabel
    Left = 152
    Top = 38
    Width = 39
    Height = 13
    Caption = 'Address'
  end
  object Label3: TLabel
    Left = 152
    Top = 65
    Width = 23
    Height = 13
    Caption = 'Rack'
  end
  object Label4: TLabel
    Left = 152
    Top = 92
    Width = 18
    Height = 13
    Caption = 'Slot'
  end
  object BitBtn1: TBitBtn
    Left = 8
    Top = 8
    Width = 121
    Height = 25
    Caption = #1087#1086#1082#1072#1079#1072#1090#1100' '#1091#1089#1090#1088#1086#1081#1089#1090#1074#1072
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 0
    OnClick = BitBtn1Click
  end
  object Edit1: TEdit
    Left = 215
    Top = 8
    Width = 195
    Height = 21
    TabOrder = 1
    Text = '0'
  end
  object ListBox1: TListBox
    Left = 8
    Top = 39
    Width = 121
    Height = 71
    ItemHeight = 13
    TabOrder = 2
    OnClick = ListBox1Click
  end
  object Edit2: TEdit
    Left = 215
    Top = 35
    Width = 195
    Height = 21
    TabOrder = 3
  end
  object Edit3: TEdit
    Left = 215
    Top = 62
    Width = 195
    Height = 21
    TabOrder = 4
  end
  object Edit4: TEdit
    Left = 215
    Top = 89
    Width = 195
    Height = 21
    TabOrder = 5
  end
  object Button1: TButton
    Left = 152
    Top = 116
    Width = 75
    Height = 25
    Caption = #1048#1079#1084#1077#1085#1080#1090#1100
    TabOrder = 6
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 233
    Top = 116
    Width = 75
    Height = 25
    Caption = #1057#1086#1079#1076#1072#1090#1100
    TabOrder = 7
    OnClick = Button2Click
  end
end
