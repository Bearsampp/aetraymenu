program AeTrayMenu;

uses
  Forms,
  SysUtils,
  Windows,
  TMMain in 'TMMain.pas' {MainForm},
  TMAbout in 'TMAbout.pas' {AboutDiag},
  TMConfig in 'TMConfig.pas',
  TMStruct in 'TMStruct.pas',
  TMCmnFunc in 'TMCmnFunc.pas',
  TMMsgs in 'TMMsgs.pas',
  TMHtmlWindow in 'TMHtmlWindow.pas' {HtmlWindow},
  TMSrvCtrl in 'TMSrvCtrl.pas',
  TMLoading in 'TMLoading.pas' {LoadingForm};

{$R *.res}

begin
  { Do some command-line parameter handling first }
  if FindCmdLineSwitch('quit', ['-'], True) then
  begin
    KillInstance(FindCmdSwitch('-id='));
    Exit;
  end;

  { Tell an already-running instance to re-read its configuration (menu, services,
    etc.) without restarting. Used by QuickPick so a freshly installed module version
    is reflected in the tray menu. Signals the existing instance and exits without
    creating a new tray. }
  if FindCmdLineSwitch('reloadconfig', ['-'], True) then
  begin
    ReloadInstance(FindCmdSwitch('-id='));
    Exit;
  end;

  { Start it up! }
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  Application.Title := 'Aestan Tray Menu';
  Application.CreateForm(TMainForm, MainForm);
  Application.ShowMainForm := False;
  ShowWindow(Application.Handle, SW_HIDE);
  Application.Run;
end.
