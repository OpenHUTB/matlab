function results=runChecks(taskIDList,file)




    import Simulink.ModelManagement.Project.Upgrade.Utils.restoreMdlAdvPreferences;
    import Simulink.ModelManagement.Project.Upgrade.Utils.getTaskNode;
    import Simulink.ModelManagement.Project.Upgrade.Utils.evaluateStatus;
    import Simulink.ModelManagement.Project.Upgrade.Utils.setModelAdvisor;
    import Simulink.ModelManagement.Project.Upgrade.Utils.userHasEmptiedTaskObjByChoosingOldReport;

    mp=ModelAdvisor.Preferences;
    state=mp.ShowProgressbar;
    mp.ShowProgressbar=false;
    restoreState=onCleanup(@()restoreMdlAdvPreferences(state));

    path=char(file);
    [parent,model]=fileparts(path);

    orig_state=warning;
    warning('off','Simulink:Engine:MdlFileShadowedByFile')
    restore=onCleanup(@()warning(orig_state));

    results=java.util.LinkedList;
    import com.mathworks.toolbox.slproject.project.upgrade.check.Result;

    if~bdIsLoaded(model)
        try
            load_system(path);
        catch E
            for n=1:taskIDList.size
                results.add(Result('NotRun',E.message));
            end
            return;
        end
    end
    [allegedParent,~]=fileparts(get_param(model,'filename'));
    if~strcmp(allegedParent,parent)
        errorMsg=getString(message('SimulinkProject:util:ProjectAnalyzeError',path,get_param(model,'filename')));
        for n=1:taskIDList.size
            results.add(Result('NotRun',errorMsg));
        end
        return;
    end

    taskIDs=cell(1,taskIDList.size);
    for n=1:taskIDList.size
        taskIDs{n}=char(taskIDList.get(n-1));
    end

    modelAdvisor=Simulink.ModelAdvisor;
    setModelAdvisor(modelAdvisor);
    mdlAdvObj=modelAdvisor.getModelAdvisor(model,'new');

    mdlAdvNodeObj=mdlAdvObj.getTaskObj(UpgradeAdvisor.UPGRADE_GROUP_ID);

    if userHasEmptiedTaskObjByChoosingOldReport(mdlAdvNodeObj,mdlAdvObj)
        infoMsg=getString(message('SimulinkProject:Upgrade:ProjectAnalyzeCanceledByUser'));
        for n=1:taskIDList.size
            results.add(Result('NotRun',infoMsg));
        end
        return;
    end

    tasks=mdlAdvNodeObj.getAllChildren;

    for n=1:length(tasks)
        tasks{n}.Selected=ismember(tasks{n}.ID,taskIDs);
    end

    runTaskAdvisor(mdlAdvNodeObj);

    for n=1:length(taskIDs)
        taskNode=getTaskNode(tasks,taskIDs{n});
        if~isempty(taskNode)
            checkObj=mdlAdvObj.getCheckObj(taskNode.MAC);
            jResult=Result(...
            evaluateStatus(taskNode),...
            checkObj.ResultInHTML);
            results.add(jResult);
        end
    end

end