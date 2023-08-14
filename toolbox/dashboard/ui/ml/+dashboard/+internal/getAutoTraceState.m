function out=getAutoTraceState()
    sg=matlab.settings.SettingsGroup;
    dashboardSettings=sg.dashboardapp;
    out=dashboardSettings.AutoTrace.ActiveValue;
end