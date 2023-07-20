function b=getDiskLoggingPreference







    s=settings;
    pm_assert(s.hasGroup('simscape'));
    ssc=s.simscape;
    pm_assert(ssc.hasSetting('StreamToDisk'));
    if ssc.StreamToDisk.ActiveValue
        b='on';
    else
        b='off';
    end

end
