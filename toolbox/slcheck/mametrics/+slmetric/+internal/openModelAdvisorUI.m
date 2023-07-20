function openModelAdvisorUI(system,configuration,workingDir)






    modelName=strtok(system,'/');
    if(bdIsLoaded(modelName)==false)
        load_system(modelName)
    end

    if isempty(configuration)
        maObj=Simulink.ModelAdvisor.getModelAdvisor(system,...
        'WorkingDir',workingDir);
    else
        maObj=Simulink.ModelAdvisor.getModelAdvisor(system,...
        'configuration',configuration,'WorkingDir',workingDir);
    end
    maObj.displayExplorer();
end

