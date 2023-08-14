function addParameterSimulink(obj)




    if~bdIsLoaded(obj.ModelName)
        load_system(obj.ModelName);
        objModelCleanup=onCleanup(@()close_system(obj.ModelName,0));
    end


    params=Simulink.internal.getModelParameterInfo(obj.ModelName);


    obj.bhaviorInfo.parameters=params;
end


