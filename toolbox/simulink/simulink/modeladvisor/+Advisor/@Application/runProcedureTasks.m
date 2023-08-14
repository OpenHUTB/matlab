


function runProcedureTasks(this,selectedCompIds,subTrees)

    currentTimeStamp=this.RunTime;



    taskInfo=this.TaskManager.getTaskInfoForExecution();
    normalTaskModes=taskInfo.regularTaskCompileInfo.UniqueModes;




    normalNoneCompileTasksSelected=...
    any(normalTaskModes==Advisor.CompileModes.None);



    mode=this.TaskManager.getNextProcedureCompileMode(true,...
    selectedCompIds,currentTimeStamp,normalNoneCompileTasksSelected);



    executedProcedureModes=Advisor.CompileModes.empty(0,0);


    while~isempty(mode)


        if mode==Advisor.CompileModes.None
            loc_runNonCompileTasks(this,selectedCompIds)


        else
            this.runCompileTasks(mode,subTrees)
        end

        executedProcedureModes(end+1)=mode;%#ok<AGROW>


        mode=this.TaskManager.getNextProcedureCompileMode(false,...
        selectedCompIds,currentTimeStamp,normalNoneCompileTasksSelected);
    end



    missingModes=setdiff(normalTaskModes,executedProcedureModes);



    if~isempty(missingModes)
        this.runNormalTasks(missingModes,selectedCompIds,subTrees);
    end
end