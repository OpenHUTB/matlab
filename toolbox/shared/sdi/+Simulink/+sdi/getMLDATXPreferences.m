function[compression,memLimit]=getMLDATXPreferences()
    [cv,memLimit]=Simulink.sdi.getMLDATXPreferencesImpl();

    switch cv
    case 1
        compression="normal";
    case 2
        compression="fastest";
    otherwise
        compression="none";
    end
end
