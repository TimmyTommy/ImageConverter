object MainForm: TMainForm
  Left = 411
  Top = 77
  Caption = 'Image Converter'
  ClientHeight = 651
  ClientWidth = 947
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseWheel = FormMouseWheel
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 553
    Width = 947
    Height = 98
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 712
    ExplicitWidth = 1313
    object LabelOut: TLabel
      Left = 171
      Top = 68
      Width = 43
      Height = 13
      Caption = 'LabelOut'
    end
    object LabelStepSpacing: TLabel
      Left = 312
      Top = 10
      Width = 59
      Height = 13
      Caption = 'Line Spacing'
    end
    object LabelLineStep: TLabel
      Left = 312
      Top = 39
      Width = 44
      Height = 13
      Caption = 'Line Step'
    end
    object LabelDeltaSize: TLabel
      Left = 312
      Top = 68
      Width = 47
      Height = 13
      Caption = 'Amplitude'
    end
    object LabelSpacingStepDisplay: TLabel
      Left = 527
      Top = 10
      Width = 54
      Height = 13
      Caption = 'RadiusStep'
    end
    object LabelLineStepDisplay: TLabel
      Left = 527
      Top = 39
      Width = 41
      Height = 13
      Caption = 'LineStep'
    end
    object LabelDeltaSizeDisplay: TLabel
      Left = 527
      Top = 68
      Width = 47
      Height = 13
      Caption = 'Amplitude'
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
    object ButtonGenRoundSpiral: TButton
      Left = 90
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Round Spiral'
      TabOrder = 1
      OnClick = ButtonGenRoundSpiralClick
    end
    object TrackBarStepSpacing: TTrackBar
      Left = 375
      Top = 6
      Width = 150
      Height = 27
      Max = 20000
      Min = 1
      Position = 5000
      ShowSelRange = False
      TabOrder = 2
      TickStyle = tsNone
      OnChange = TrackBarChange
    end
    object TrackBarStepLine: TTrackBar
      Left = 375
      Top = 35
      Width = 150
      Height = 26
      Max = 500
      Position = 5
      ShowSelRange = False
      TabOrder = 3
      TickStyle = tsNone
      OnChange = TrackBarChange
    end
    object TrackBarDeltaSize: TTrackBar
      Left = 375
      Top = 65
      Width = 150
      Height = 28
      Max = 200
      Position = 18
      ShowSelRange = False
      TabOrder = 4
      TickStyle = tsNone
      OnChange = TrackBarChange
    end
    object ButtonSaveImage: TButton
      Left = 9
      Top = 34
      Width = 75
      Height = 25
      Caption = 'Save Image'
      TabOrder = 5
      OnClick = ButtonSaveImageClick
    end
    object ComboBoxSmoothing: TComboBox
      Left = 9
      Top = 65
      Width = 156
      Height = 21
      Style = csDropDownList
      TabOrder = 6
    end
    object ButtonGenSquareSpiral: TButton
      Left = 90
      Top = 34
      Width = 75
      Height = 25
      Caption = 'Square Spiral'
      TabOrder = 7
      OnClick = ButtonGenSquareSpiralClick
    end
    object ButtonGenSquareSpiralWobble: TButton
      Left = 171
      Top = 34
      Width = 110
      Height = 25
      Caption = 'Square Spiral Wobble'
      TabOrder = 8
      OnClick = ButtonGenSquareSpiralWobbleClick
    end
    object ButtonGenRoundSpiralWobble: TButton
      Left = 171
      Top = 6
      Width = 110
      Height = 25
      Caption = 'Round Spiral Wobble'
      TabOrder = 9
      OnClick = ButtonGenRoundSpiralWobbleClick
    end
  end
  object TabControl: TTabControl
    Left = 0
    Top = 0
    Width = 947
    Height = 553
    Align = alClient
    TabOrder = 1
    Tabs.Strings = (
      'Source')
    TabIndex = 0
    OnChange = TabControlChange
    OnMouseUp = TabControlMouseUp
    ExplicitWidth = 1313
    ExplicitHeight = 712
    object ScrollBox: TScrollBox
      Left = 4
      Top = 24
      Width = 939
      Height = 525
      Align = alClient
      BevelEdges = []
      BevelInner = bvNone
      BevelOuter = bvNone
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 0
      ExplicitWidth = 1305
      ExplicitHeight = 684
      object Image: TImage
        Left = 3
        Top = 3
        Width = 534
        Height = 510
        AutoSize = True
        Center = True
        OnMouseDown = ImageMouseDown
        OnMouseMove = ImageMouseMove
        OnMouseUp = ImageMouseUp
      end
    end
  end
end
