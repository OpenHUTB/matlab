function results=runUpgradesReRunningChecks(taskIDList,file)




    Simulink.ModelManagement.Project.Upgrade.runChecks(taskIDList,file);

    import Simulink.ModelManagement.Project.Upgrade.Utils.restoreMdlAdvPreferences;
    import Simulink.ModelManagement.Project.Upgrade.Utils.setModelAdvisor;

    mp=ModelAdvisor.Preferences;
    state=mp.ShowProgressbar;
    mp.ShowProgressbar=false;
    restoreState=onCleanup(@()restoreMdlAdvPreferences(state));

    path=char(file);
    [~,model]=fileparts(path);

    orig_state=warning;
    warning('off','Simulink:Engine:MdlFileShadowedByFile');
    restore=onCleanup(@()warning(orig_state));

    results=java.util.LinkedList;
    import com.mathworks.toolbox.slproject.project.upgrade.check.Result;

    if~bdIsLoaded(model)
        load_system(path);
    elseif~strcmp(get_param(model,'filename'),path)
        errorMsg=getString(message('SimulinkProject:util:ProjectUpgradeError',path,get_param(model,'filename')));
        for n=1:taskIDList.size
            results.add(Result('NotRun',errorMsg));
        end
        return;
    end

    tasks=cell(1,taskIDList.size);
    for n=1:taskIDList.size
        tasks{n}=char(taskIDList.get(n-1));
    end

    modelAdvisor=Simulink.ModelAdvisor;
    setModelAdvisor(modelAdvisor);
    mdlAdvObj=modelAdvisor.getModelAdvisor(model);

    for n=1:numel(tasks)
        taskObj=mdlAdvObj.getTaskObj(tasks{n});
        checkID=taskObj.Check.ID;
        try

            if bdIsLibrary(model)
                set_param(model,'Lock','off');
            end
            mdlAdvObj.runAction(checkID,taskObj);
            jResult=Result('Applied',taskObj.Check.Action.ResultInHTML);
        catch E
            jResult=Result('NotRun',E.message);
        end
        results.add(jResult);
    end

    if bdIsDirty(model)
        try
            state=warning('off');
            restoreWarning=onCleanup(@()warning(state));
            save_system(model);
        catch E
            resultsWithWarning=java.util.LinkedList;
            for n=1:taskIDList.size
                composedMsg=getString(message(...
                'SimulinkProject:util:ProjectUpgradeSaveError',...
                char(results.get(n-1).getResultText),...
                E.message));
                resultsWithWarning.add(Result('NotRun',composedMsg));
            end
            results.clear;
            results.addAll(resultsWithWarning);
        end
    end

end