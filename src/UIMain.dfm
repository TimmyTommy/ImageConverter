object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Image Converter'
  ClientHeight = 625
  ClientWidth = 974
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseWheel = FormMouseWheel
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 557
    Width = 974
    Height = 68
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 497
    object LabelOut: TLabel
      Left = 90
      Top = 42
      Width = 43
      Height = 13
      Caption = 'LabelOut'
    end
    object LabelStepRadius: TLabel
      Left = 312
      Top = 10
      Width = 57
      Height = 13
      Caption = 'Radius Step'
    end
    object LabelCircleStep: TLabel
      Left = 312
      Top = 39
      Width = 51
      Height = 13
      Caption = 'Circle Step'
    end
    object LabelPointCount: TLabel
      Left = 560
      Top = 39
      Width = 56
      Height = 13
      Caption = 'Point Count'
    end
    object LabelDeltaSize: TLabel
      Left = 560
      Top = 10
      Width = 44
      Height = 13
      Caption = 'DeltaSize'
    end
    object BtnLoadImg: TButton
      Left = 9
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Load Image'
      TabOrder = 0
      OnClick = BtnLoadImgClick
    end
    object ButtonGenerate: TButton
      Left = 90
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Generate'
      TabOrder = 1
      OnClick = ButtonGenerateClick
    end
    object TrackBarStepRadius: TTrackBar
      Left = 375
      Top = 6
      Width = 150
      Height = 27
      Max = 5000
      Min = 1
      Position = 800
      ShowSelRange = False
      TabOrder = 2
      TickStyle = tsNone
    end
    object TrackBarStepCircle: TTrackBar
      Left = 375
      Top = 35
      Width = 150
      Height = 26
      Max = 30
      Position = 4
      ShowSelRange = False
      TabOrder = 3
    end
    object SpinEditPointCount: TSpinEdit
      Left = 631
      Top = 36
      Width = 89
      Height = 22
      Increment = 1000
      MaxValue = 1000000
      MinValue = 0
      TabOrder = 4
      Value = 300000
    end
    object TrackBarDeltaSize: TTrackBar
      Left = 631
      Top = 6
      Width = 150
      Height = 26
      Max = 30
      Position = 18
      ShowSelRange = False
      TabOrder = 5
    end
    object ButtonSaveImage: TButton
      Left = 9
      Top = 37
      Width = 75
      Height = 25
      Caption = 'Save Image'
      TabOrder = 6
      OnClick = ButtonSaveImageClick
    end
  end
  object TabControl: TTabControl
    Left = 0
    Top = 0
    Width = 974
    Height = 557
    Align = alClient
    TabOrder = 1
    Tabs.Strings = (
      'Source')
    TabIndex = 0
    OnChange = TabControlChange
    OnMouseUp = TabControlMouseUp
    object ScrollBox: TScrollBox
      Left = 4
      Top = 24
      Width = 966
      Height = 529
      Align = alClient
      BevelEdges = []
      BevelInner = bvNone
      BevelOuter = bvNone
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 0
      object Image: TImage
        Left = 3
        Top = 3
        Width = 500
        Height = 500
        AutoSize = True
        Center = True
        OnMouseDown = ImageMouseDown
        OnMouseMove = ImageMouseMove
        OnMouseUp = ImageMouseUp
      end
    end
  end
end
