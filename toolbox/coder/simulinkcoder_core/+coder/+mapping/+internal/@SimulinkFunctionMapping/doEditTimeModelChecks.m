function doEditTimeModelChecks(model)




    import coder.mapping.internal.*;

    if~SimulinkFunctionMapping.isSimulinkModel(model)
        DAStudio.error('RTW:codeGen:InvalidModelFcnPrototype',model);
    end
    if(modelIsLibrary(model))
        DAStudio.error('coderdictionary:api:LibrariesNotSupported');
    end


    isERTDerived=strcmp(get_param(model,'IsERTTarget'),'on');
    if isERTDerived
        isAUTOSAR=strcmp(get_param(model,'SystemTargetFile'),'autosar.tlc');
        if isAUTOSAR
            DAStudio.error('coderdictionary:api:AUTOSARNotSupported');
        end
    else
        DAStudio.error('coderdictionary:api:ERTTargetOnlySupported');
    end
end
