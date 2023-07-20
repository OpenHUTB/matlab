function setDiskLoggingPreference(value)





    s=settings;
    pm_assert(s.hasGroup('simscape'));
    ssc=s.simscape;
    pm_assert(ssc.hasSetting('StreamToDisk'));
    streamToDisk=ssc.StreamToDisk;
    if strcmpi(value,'on')
        streamToDisk.PersonalValue=true;
    elseif strcmpi(value,'off')
        streamToDisk.PersonalValue=false;
    else
        try
            pm_error('physmod:common:logging2:mli:preferences:InvalidPreferenceSetting',value);
        catch ME
            ME.throwAsCaller();
        end
    end

end
