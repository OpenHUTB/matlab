function setAutoTraceState(state)
    sg=matlab.settings.SettingsGroup;
    dashboardSettings=sg.dashboardapp;
    dashboardSettings.AutoTrace.PersonalValue=state;
end