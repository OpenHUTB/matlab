function destroyRTWContext(modelName)





    idService=get_param(modelName,'IdentifierService');
    if(idService.codeGenerationContextExists())
        idService.destroyRTWContext();
    else
        idService.cleanReserveList();
    end
