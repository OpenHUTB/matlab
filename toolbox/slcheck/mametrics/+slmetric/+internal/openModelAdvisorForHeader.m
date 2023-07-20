function openModelAdvisorForHeader(rootSystemSID,config,workingDir,~,groupID)







    modelName=Simulink.ID.getModel(rootSystemSID);
    if~bdIsLoaded(modelName)
        load_system(modelName);
    end

    systemName=Simulink.ID.getFullName(rootSystemSID);


    if isempty(config)
        maObj=Simulink.ModelAdvisor.getModelAdvisor(systemName,...
        'WorkingDir',workingDir);
    else
        maObj=Simulink.ModelAdvisor.getModelAdvisor(systemName,...
        'configuration',config,'WorkingDir',workingDir);
    end
    maObj.displayExplorer();




    Advisor.Utils.useGUI(maObj,{groupID},'focus');

    drawnow;

end

