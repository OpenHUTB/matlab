function addMiscHook(hThisObj,hook,commandString)






    if~isprop(hThisObj,'MPFToolVersion')
        persistent diswarn
        if isempty(diswarn)
            MSLDiagnostic('Simulink:mpt:MPTMiscAddHook').reportAsWarning;
            diswarn=1;
        end
        return
    end

    if isprop(hThisObj,hook)
        hThisObj.(hook)=commandString;
    else
        MSLDiagnostic('Simulink:mpt:MPTMiscAddInvalidHook',hook).reportAsWarning;
    end

