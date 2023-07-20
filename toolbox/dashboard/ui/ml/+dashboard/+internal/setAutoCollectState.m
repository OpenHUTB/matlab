function setAutoCollectState(state)
    sg=matlab.settings.SettingsGroup;
    dashboardSettings=sg.dashboardapp;
    dashboardSettings.AutoCollect.PersonalValue=state;
end