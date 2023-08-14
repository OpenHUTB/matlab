



function newvalue=setModuleNamingRule(~,proposedValue)



    if isequal(proposedValue,'UserSpecified')
        newvalue='SameAsModel';
        MSLDiagnostic('Simulink:mpt:MPTInvalidModuleNamingOption','UserSpecified','SameAsModel').reportAsWarning;
    else
        newvalue=proposedValue;
    end

