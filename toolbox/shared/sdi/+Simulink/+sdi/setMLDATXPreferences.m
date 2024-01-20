function setMLDATXPreferences(compression,memLimit)

    try
        compression=validatestring(compression,["none","normal","fastest"],1);
        validateattributes(memLimit,{'numeric'},{'real','scalar','integer','>=',50},2);

        switch compression
        case "normal"
            cv=1;
        case "fastest"
            cv=2;
        otherwise
            cv=0;
        end
        Simulink.sdi.setMLDATXPreferencesImpl(cv,memLimit);
    catch me
        me.throwAsCaller();
    end
end
