function preferenceStruct=getMapperPreferences()



    if isempty(Simulink.sta.getMapperPrefVersion())
        Simulink.sta.createFactoryPreferences();
        preferenceStruct=Simulink.sta.getMapperPreferences();
    else



        Simulink.sta.PreferenceManager.appendToExistingPreferences();
        preferenceStruct=Simulink.sta.PreferenceManager.getRootInportMappingPrefsStruct();

    end
