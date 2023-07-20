function isProtecting=isProtectingModelAndBinariesAndPWS(modelName)





    isProtecting=false;
    isProtected=slInternal('getReferencedModelFileInformation',modelName);
    if~isProtected&&...
        bdIsLoaded(modelName)
        isPWSEnabled=strcmp(get_param(modelName,'PortableWordSizes'),'on');
        if isPWSEnabled&&Simulink.ModelReference.ProtectedModel.protectingModel(modelName)
            pmCreator=get_param(modelName,'ProtectedModelCreator');
            isProtecting=~pmCreator.packageSourceCode;
        end
    end
