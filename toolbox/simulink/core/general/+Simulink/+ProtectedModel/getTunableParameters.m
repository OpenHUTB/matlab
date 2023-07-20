function params=getTunableParameters(protectedModelName)







    if slfeature('ProtectedModelTunableParameters')
        params=convertCharsToStrings(...
        Simulink.ModelReference.ProtectedModel.getTunableParameters(protectedModelName));
    else
        DAStudio.error('MATLAB:UndefinedFunctionText','Simulink.ProtectedModel.getTunableParameters');
    end

