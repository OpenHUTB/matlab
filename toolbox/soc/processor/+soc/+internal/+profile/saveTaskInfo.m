function saveTaskInfo(modelName,subDir)




    lastDir=soc.internal.profile.getLatestDiagnosticDirectory(modelName,subDir);



    taskMgrBlk=find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'MaskType','Task Manager');
    if~isempty(taskMgrBlk)
        taskMgrBlk=taskMgrBlk{1};
        allTaskData=get_param(taskMgrBlk,'AllTaskData');
        filename=fullfile(lastDir,'TaskInfo');
        save(filename,'allTaskData')
    else

    end
end
