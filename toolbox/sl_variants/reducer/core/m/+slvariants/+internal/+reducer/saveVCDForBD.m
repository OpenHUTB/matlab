function saveVCDForBD(modelName,nameOfVariantConfigDataObj,varConfigDataObj)





    loadModel(modelName);
    if~isVCDFromSLDD(modelName)


        assignin('base',nameOfVariantConfigDataObj,varConfigDataObj);
    else


        ddSpec=get_param(modelName,'DataDictionary');
        ddConn=Simulink.dd.open(ddSpec);
        ddConn.assignin(nameOfVariantConfigDataObj,varConfigDataObj,'Configurations');
    end
end

function loadModel(modelName)
    if bdIsLoaded(modelName)
        return;
    end
    try
        load_system(modelName);
    catch excep
        throwAsCaller(excep)
    end
end

function tf=isVCDFromSLDD(modelName)
    vcdSource=slvariants.internal.reducer.getVCDOSource(modelName);
    [~,~,ext]=fileparts(vcdSource);
    tf=isequal(lower(ext),'.sldd');
end
