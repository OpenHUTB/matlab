function b=getStylePreference







    s=settings;
    pm_assert(s.hasGroup('simscape'));
    ssc=s.simscape;
    pm_assert(ssc.hasSetting('EnableDomainStyles'));

    if ssc.EnableDomainStyles.ActiveValue
        b='on';
    else
        b='off';
    end

end