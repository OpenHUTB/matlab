


function runNormalTasks(this,selectedCompIds,subTrees)

    taskInfo=this.TaskManager.getTaskInfoForExecution();
    compModes=taskInfo.regularTaskCompileInfo.UniqueModes;


    if any(compModes==Advisor.CompileModes.None)

        this.runNonCompileTasks(selectedCompIds);


        compModes=compModes(compModes~=Advisor.CompileModes.None);
    end


    if any(compModes==Advisor.CompileModes.DIY)

        this.runDIYTasks(selectedCompIds);


        compModes=compModes(compModes~=Advisor.CompileModes.DIY);
    end


    if~isempty(compModes)
        this.runCompileTasks(compModes,subTrees);
    end
end
