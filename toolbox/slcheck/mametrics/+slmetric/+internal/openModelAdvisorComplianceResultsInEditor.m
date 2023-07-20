function openModelAdvisorComplianceResultsInEditor(rootSystemSID,config,workingDir,systemSID,taskID)







    systemName=Simulink.ID.getFullName(rootSystemSID);


    if isempty(config)
        maObj=Simulink.ModelAdvisor.getModelAdvisor(systemName,...
        'WorkingDir',workingDir);
    else
        maObj=Simulink.ModelAdvisor.getModelAdvisor(systemName,...
        'configuration',config,'WorkingDir',workingDir);
    end


    maObj.displayExplorer('hide');





    if ischar(taskID)
        taskID={taskID};
    end

    Advisor.Utils.useGUI(maObj,taskID,'focus');

    if slfeature('AdvisorWebUI')==1
        maObj.displayInformer();
        maObj.focusInformerNode(taskID);
    else
        originalSetting=getpref('modeladvisor','ShowInformer');


        maObj.MEMenus.ShowInformerGUI.on='on';


        drawnow;
        setpref('modeladvisor','ShowInformer',originalSetting);
    end

    slmetric.internal.open_system(systemSID);
end

