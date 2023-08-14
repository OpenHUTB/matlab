function reportDiagnosticIfV2Enabled()









    if slfeature('VMgrV2UI')>0
        throwAsCaller(MException(message('Simulink:VariantManager:LegacyCodeInvoked')));
    end
end
