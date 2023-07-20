









function compileCallbackFct(this,compileService,~)
    activeMode=compileService.ActiveCompileMode;
    modelName=get_param(compileService.ActiveModel,'Name');

    taskInfo=this.TaskManager.getTaskInfoForExecution();


    taskList=taskInfo.regularTaskCompileInfo.TaskIdxList;
    taskIds=taskList(taskInfo.regularTaskCompileInfo.ModeList==...
    activeMode);

    if this.MultiMode







        if this.AnalysisRootType~=Advisor.component.Types.Model&&...
            strcmp(modelName,this.RootModel)
            cmpID=this.AnalysisRootComponentId;
        else
            cmpID=modelName;
        end




...
...
...
...
...
...
...
...
        instanceIds{1}=cmpID;



        for n=1:length(instanceIds)
            if this.CompId2MAObjIdxMap.isKey(instanceIds{n})

                idx=this.CompId2MAObjIdxMap(instanceIds{n});
                maObj=this.MAObjs{idx};


                maObj.StartTime=this.RunTime;




                maObj.runTasksForMode(activeMode,taskIds,...
                taskInfo.procedureTaskCompileInfo);

                maObj.StartTime=0;
            end
        end



    else
        maObj=this.RootMAObj;


        maObj.StartTime=this.RunTime;


        maObj.runTasksForMode(activeMode,taskIds,...
        taskInfo.procedureTaskCompileInfo);

        maObj.StartTime=0;


    end
end