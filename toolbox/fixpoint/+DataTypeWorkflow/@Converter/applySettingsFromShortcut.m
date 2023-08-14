function applySettingsFromShortcut(this,shortcutName)













    this.assertDEValid();


    validateattributes(shortcutName,{'char'},{'nonempty','row'});


    shortcutsForSelectedSystem=this.ShortcutManager.getShortcutNames;


    shortcutName=this.ShortcutManager.getTranslatedShortcut(shortcutName);

    if~ismember(shortcutName,shortcutsForSelectedSystem)
        error(message('SimulinkFixedPoint:autoscaling:shortcutStringMismatch',shortcutName));
    end


    this.ShortcutManager.applyShortcut(shortcutName);
end
