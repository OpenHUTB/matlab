function jChecks=getChecks()




    import com.mathworks.toolbox.slprojectsimulink.upgrade.SimulinkCheckBuilder;
    import Simulink.ModelManagement.Project.Upgrade.Utils.setModelAdvisor;

    mp=ModelAdvisor.Preferences;
    state=mp.ShowProgressbar;
    mp.ShowProgressbar=false;
    restoreState=onCleanup(@()restoreMdlAdvPreferences(state));

    tmpName=tempname;
    tempSystem=tmpName(length(tempdir)+1:length(tmpName));
    new_system(tempSystem,'FromTemplate','factory_default_model');

    originalCacheFolder=Simulink.fileGenControl('getinternalvalue','CacheFolder');
    cleanupGenControlPreferences=onCleanup(@()Simulink.fileGenControl('set',...
    'CacheFolder',originalCacheFolder));

    originalPath=path;
    restorePath=onCleanup(@()path(originalPath));

    Simulink.fileGenControl('set','CacheFolder',tempname,'createDir',true);
    modelAdvisor=Simulink.ModelAdvisor;
    setModelAdvisor(modelAdvisor);
    mdlAdvObj=modelAdvisor.getModelAdvisor(tempSystem,'new',UpgradeAdvisor.UPGRADE_GROUP_ID);
    mdlAdvWD=mdlAdvObj.getWorkDir;
    cleanupMdlAdvWD=onCleanup(@()rmdir(mdlAdvWD,'s'));
    taskRoot=mdlAdvObj.TaskAdvisorRoot;
    cleanup=onCleanup(@()deleteTaskRootAndCloseSystem(taskRoot,tempSystem));
    tasks=taskRoot.getAllChildren();

    jChecks=java.util.LinkedList;
    for n=1:numel(tasks)
        check=mdlAdvObj.getCheckObj(tasks{n}.MAC);
        isFixable=isa(check.Action,'ModelAdvisor.Action');

        javaCheckBuilder=SimulinkCheckBuilder(tasks{n}.ID);
        javaCheckBuilder.setTitle(check.Title);
        javaCheckBuilder.setSupportLibrary(check.SupportLibrary);
        javaCheckBuilder.setRequiresCompile(~strcmp(check.CallbackContext,'None'));
        javaCheckBuilder.setFixable(isFixable);
        javaCheckBuilder.setDescription(check.Description);
        javaCheckBuilder.setHelpLink([...
        'matlab:helpview(''mapkey:',check.CSHParameters.MapKey,''', '''...
        ,check.CSHParameters.TopicID,''', ''CSHelpWindow'')']);

        javaCheck=javaCheckBuilder.create;

        if~strcmp(check.ID,'com.mathworks.Simulink.UpgradeAdvisor.UpgradeModelHierarchy')
            jChecks.add(javaCheck);
        end
    end
end

function restoreMdlAdvPreferences(state)
    mp=ModelAdvisor.Preferences;
    mp.ShowProgressbar=state;
end

function deleteTaskRootAndCloseSystem(taskRoot,system)
    state=warning('off');
    cleanup=onCleanup(@()warning(state));
    delete(taskRoot);
    close_system(system,0);
end
