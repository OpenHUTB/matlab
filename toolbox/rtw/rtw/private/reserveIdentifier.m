function reserveIdentifier(modelName,reservedIdents)






    narginchk(2,2);
    idService=get_param(modelName,'IdentifierService');
    if(idService.codeGenerationContextExists())
        DAStudio.error('Simulink:Engine:RTWIdentifierServiceCodeGenStarted');
    else
        idService.reserveIdentifier(reservedIdents);
    end
