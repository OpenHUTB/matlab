function applySettingsFromRun(this,runName)





















    this.assertDEValid();
    this.validateRunName(runName);



    this.ShortcutManager.applyShortcut(runName);
end
