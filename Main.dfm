object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 299
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    635
    299)
  PixelsPerInch = 96
  TextHeight = 16
  object Button1: TButton
    Left = 8
    Top = 266
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo: TMemo
    Left = 8
    Top = 8
    Width = 619
    Height = 252
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
end
