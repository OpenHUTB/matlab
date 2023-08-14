


function runSynchronous(this)


    [selectedCompIds,subTrees]=...
    this.setupRun();



    if~isempty(selectedCompIds)
        taskInfo=this.TaskManager.cacheTaskInfo();

        checkIDs=this.TaskManager.getChecksScheduledForExecution();
        this.CheckIDsExecuted=checkIDs;


        if~isempty(taskInfo.procedureTaskCompileInfo)

            this.runProcedureTasks(selectedCompIds,subTrees);

        else


            this.runNormalTasks(selectedCompIds,subTrees);
        end


        if~isempty(this.CompileErrors)
            this.TaskManager.setCompileError(this.CompileErrors,this.RunTime,...
            selectedCompIds);
        end


        if~isempty(this.CompileErrors)
            this.CompileErrors={};
        end


        if this.MultiMode




            this.aggregateResults(selectedCompIds);
        end


        this.CheckIDsExecuted={};
    end
end

