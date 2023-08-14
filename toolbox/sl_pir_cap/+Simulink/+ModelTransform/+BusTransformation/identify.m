


function identificationResult=identify(subsystemPath)
    if isempty(subsystemPath)
        DAStudio.error('sl_m2m_edittime:messages:ModelNameIsEmpty');
    end

    results=[];

    pathArray=split(subsystemPath,'/');
    modelName=pathArray{1};

    isModelExplicitlyLoaded=false;
    if~bdIsLoaded(modelName)
        load_system(modelName);
        isModelExplicitlyLoaded=true;
    end


    identificationResultsMcos=...
    Simulink.ModelRefactor.BusPortsTransform.identify(get_param(subsystemPath,'handle'));
    results.BusHierarchies=...
    Simulink.ModelTransform.BusTransformation.internal.mcosToAPIAdapter(identificationResultsMcos);
    results.TopModel=modelName;

    identificationResult=Simulink.ModelTransform.BusTransformation.Result(results,identificationResultsMcos);


    if(isModelExplicitlyLoaded)
        close_system(modelName,0);
    end
end


