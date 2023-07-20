function out=getAutoCollectState()
    sg=matlab.settings.SettingsGroup;
    dashboardSettings=sg.dashboardapp;
    out=dashboardSettings.AutoCollect.ActiveValue;
end