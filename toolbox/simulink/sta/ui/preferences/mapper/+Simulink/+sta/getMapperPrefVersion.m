function mapperPrefVersionNumber=getMapperPrefVersion()




    mapperPrefVersionNumber=[];

    if ispref(Simulink.sta.PreferenceManager.prefGroupName)

        mapperPrefVersionNumber=getpref(Simulink.sta.PreferenceManager.prefGroupName,'version');
    end


