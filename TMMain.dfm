object MainForm: TMainForm
  Left = 225
  Top = 106
  Caption = 'AeTrayMenu'
  ClientHeight = 64
  ClientWidth = 206
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  TextHeight = 13
  object LeftClickPopup: TPopupMenu
    Images = ImageList
    OnPopup = LeftRightClickPopupPopup
    Left = 40
    Top = 8
  end
  object RightClickPopup: TPopupMenu
    Images = ImageList
    OnPopup = LeftRightClickPopupPopup
    Left = 72
    Top = 8
  end
  object TrayIcon: TJvTrayIcon
    IconIndex = -1
    Icons = ImageList
    DropDownMenu = LeftClickPopup
    PopupMenu = RightClickPopup
    Visibility = []
    OnDblClick = TrayIconDblClick
    OnMouseDown = TrayIconMouseDown
    Left = 104
    Top = 8
  end
  object CheckServicesTimer: TTimer
    Enabled = False
    Interval = 0
    OnTimer = CheckServicesTimerTimer
    Left = 136
    Top = 8
  end
  object ImageList: TImageList
    Left = 168
    Top = 8
  end
end
