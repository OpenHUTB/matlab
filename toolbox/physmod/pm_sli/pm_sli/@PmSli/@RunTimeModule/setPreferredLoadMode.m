function setPreferredLoadMode(preferredLoadMode)





    s=settings;
    pm_assert(s.hasGroup('simscape'));
    ssc=s.simscape;
    pm_assert(ssc.hasSetting('DefaultEditingMode'));


    ssc.DefaultEditingMode.PersonalValue=preferredLoadMode;

end



