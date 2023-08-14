function defaultNTObj=getDefaultNumericTypeObject(proposalSettings)



    defaultNTObj='';
    if proposalSettings.ProposeForFloatingPoint||proposalSettings.ProposeForInherited
        defaultNTObj=fixdt(true,proposalSettings.DefaultWordLength,proposalSettings.DefaultFractionLength);
    end
end
