function openModelAdvisorResultsInEditor(rootSystemSID,config,workingDir,systemSID,groupID)







    systemName=Simulink.ID.getFullName(rootSystemSID);


    if isempty(config)
        maObj=Simulink.ModelAdvisor.getModelAdvisor(systemName,...
        'WorkingDir',workingDir);
    else
        maObj=Simulink.ModelAdvisor.getModelAdvisor(systemName,...
        'configuration',config,'WorkingDir',workingDir);
    end
    maObj.displayExplorer('hide');




    Advisor.Utils.useGUI(maObj,{groupID},'focus');


    if slfeature('AdvisorWebUI')==1
        maObj.displayInformer();
        maObj.focusInformerNode({groupID});
    else
        originalSetting=getpref('modeladvisor','ShowInformer');

        maObj.MEMenus.ShowInformerGUI.on='on';
        maObj.MEMenus.ShowCheckResultsGUI.on='on';

        drawnow;
        setpref('modeladvisor','ShowInformer',originalSetting);
    end

    slmetric.internal.open_system(systemSID);


end

