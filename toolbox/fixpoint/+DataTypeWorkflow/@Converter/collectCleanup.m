function collectCleanup(this,cleanupShortcut)





    this.SystemSettings.turnOffFastRestart();


    this.applySettingsFromShortcut(cleanupShortcut);



    this.SystemSettings.restoreSettings();

end

