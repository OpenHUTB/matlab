function retrieveBlockSupportFromPrefToSettings()



    pref=lutdesigner.config.internal.getBlockSupportPref();
    bssOld=lutdesigner.config.internal.extractBlockSupportSettingsFromPref(pref);


    bssNew=lutdesigner.config.internal.getBlockSupportSettings();


    bss=lutdesigner.config.internal.mergeBlockSupportSettings(bssNew,bssOld);


    lutdesigner.config.internal.setBlockSupportSettings(bss);
end
