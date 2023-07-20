function setPreference(paraName,value)
    mp=ModelAdvisor.Preferences;
    switch paraName
    case 1
        mp.ShowSourceTab=value;
    case 2
        mp.ShowExclusionTab=value;
    case 3
        mp.ShowAccordion=value;
    case 4
        mp.ShowExclusionsInRpt=value;
    case 5
        mp.RunInBackground=value;
    end

end
