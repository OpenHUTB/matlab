


function runDIYTasks(this,selectedCompIds)

    activeMode=Advisor.CompileModes.DIY;
    taskInfo=this.TaskManager.getTaskInfoForExecution();


    taskList=taskInfo.regularTaskCompileInfo.TaskIdxList;
    taskIds=taskList(taskInfo.regularTaskCompileInfo.ModeList==...
    activeMode);

    for n=1:length(selectedCompIds)

        idx=this.CompId2MAObjIdxMap(selectedCompIds{n});
        maObj=this.MAObjs{idx};


        maObj.StartTime=this.RunTime;

        maObj.runTasksForMode(activeMode,taskIds,taskInfo.procedureTaskCompileInfo);

        maObj.StartTime=0;
    end
end