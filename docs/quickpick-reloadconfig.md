# QuickPick → tray "reload config" (in-place menu refresh)

## Purpose

When QuickPick installs a new module version, the running Bearsampp stack must reflect
it. Two halves are involved:

1. **The functional switch** (config, symlink, database service restart) — handled by the
   PHP `reload` action (`ActionReload`). This already makes phpMyAdmin / localhost / the
   running server correct.
2. **The tray's in-memory menu** (version labels, the MySQL/MariaDB console launcher, the
   version submenus) — these only refresh when the *running* Aestan tray executes its
   built-in `readconfig`. Nothing in the PHP/web context can reach into the running tray
   to trigger that, and there is **no** command-line switch on the stock tray to do it
   (`-reload` just launches a second instance).

This feature adds a tray command-line switch so QuickPick can tell the **already-running**
tray to re-read its config **in place** — no application restart, no service cycling.

## Tray side — DONE (branch `quickpick` of Bearsampp/aetraymenu)

A new switch `-reloadconfig -id={bearsampp}` was added, mirroring how `-quit` works.

- `AeTrayMenu.dpr` — recognizes `-reloadconfig` before the app starts, calls
  `ReloadInstance(id)`, and exits (so it never creates a second tray).
- `TMCmnFunc.pas` — `ReloadInstance(id)` finds the running window
  (`FindWindow(nil, 'AeTrayMenu[<id>]')`) and sends the registered message
  `AeTrayMenuReloadConfig` (via `RegisterWindowMessage`).
- `TMMain.pas` — the main form registers the same message in its constructor and overrides
  `WndProc`; when that message arrives it calls `ReadConfig` (rebuild menus/services only —
  **it does not reset/restart services**, so it won't re-cycle the DB the PHP reload just
  restarted).

> **Build required:** `bearsampp.exe` must be recompiled from this branch (Delphi 12 CE).
> Until the shipped `bearsampp.exe` contains this switch, the PHP call below is a no-op
> (an old exe would spawn a duplicate instance — do NOT ship the PHP half until the exe
> ships).

## PHP side — TODO (do later, in the Bearsampp core repo)

**File:** `core/classes/actions/class.action.quickPick.php`, method `installModule()`.

After the functional reload has been triggered **and the `bearsampp.ini` has been
regenerated with the new version** (`ActionReload` does this via
`file_put_contents(Path::getIniFilePath(), Util::utf8ToCp1252(TplApp::process()))`), signal
the running tray to re-read it:

```php
// Refresh the running tray's menu in place (version labels + console launcher) without
// restarting the app or cycling services. Requires bearsampp.exe built from the
// aetraymenu 'quickpick' branch (adds the -reloadconfig switch). Leading "" is the
// empty window title required by cmd.exe "start" (see CommandRunner::background).
$reloadTrayCmd = '"" "' . Path::getExeFilePath() . '" -reloadconfig -id={bearsampp}';
Log::debug('Refreshing tray menu: ' . $reloadTrayCmd);
CommandRunner::background($reloadTrayCmd);
```

`Path::getExeFilePath()` → `<root>/bearsampp.exe`. The id `{bearsampp}` matches the tray's
`ID={bearsampp}` (see `class.action.rebuildIni.php`) and the existing
`"<exe>" -quit -id={bearsampp}` usage in `class.batch.php`.

### Ordering / race note (important)

`readconfig` re-reads `bearsampp.ini` from disk, so that file must already contain the new
version **before** the tray is signalled. The current QuickPick spawns the reload detached
(`php-win.exe root.php reload`), so there is a race: the tray could `readconfig` before the
reload rewrites the ini.

Pick one of:

- **(preferred)** Regenerate the ini synchronously in QuickPick right before signalling —
  `TplApp::process()` only builds strings (no winbinder), so it is AJAX-safe:
  ```php
  file_put_contents(Path::getIniFilePath(), Util::utf8ToCp1252(TplApp::process()));
  $reloadTrayCmd = '"" "' . Path::getExeFilePath() . '" -reloadconfig -id={bearsampp}';
  CommandRunner::background($reloadTrayCmd);
  ```
- Or run the functional reload **not** detached (wait for it), then signal the tray.
- Or have the JS wait (it already delays ~8s before refreshing the page) and issue the
  tray signal after that delay — least reliable; avoid.

## Ready-to-use prompt for the PHP change

> In `core/classes/actions/class.action.quickPick.php`, `installModule()` (enhanced-mode
> success path, after the version config is written), make the running Aestan tray refresh
> its menu in place. First regenerate the tray ini synchronously
> (`file_put_contents(Path::getIniFilePath(), Util::utf8ToCp1252(TplApp::process()))`), then
> launch `"<bearsampp.exe>" -reloadconfig -id={bearsampp}` via `CommandRunner::background()`
> (prefix the command with an empty `""` title for cmd.exe `start`). Use
> `Path::getExeFilePath()` for the exe path. Do NOT call `resetservices` or restart the app —
> the functional reload already restarts the database service; `-reloadconfig` only repaints
> the tray menu. This requires `bearsampp.exe` built from the aetraymenu `quickpick` branch.

## Manual test

1. Build & run `bearsampp.exe` from the `quickpick` branch.
2. From a shell: `bearsampp.exe -reloadconfig -id={bearsampp}`
   - Expect: the tray menu re-reads its ini in place; **no** second tray icon appears;
     services are **not** restarted.
   - Compare to `bearsampp.exe -reload -id={bearsampp}` on the stock build, which wrongly
     spawns a duplicate instance.
