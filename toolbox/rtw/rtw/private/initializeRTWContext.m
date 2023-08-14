function initializeRTWContext(modelName)





    idService=get_param(modelName,'IdentifierService');
    if(~idService.codeGenerationContextExists())
        idService.initializeRTWContext(modelName);
    end