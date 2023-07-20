














function deselectCheckInstances(this,varargin)



    if strcmp(this.AnalysisRoot,'empty')
        DAStudio.error('Advisor:base:App_NotInitialized');
    end

    p=inputParser();
    p.addParameter('ids',{});
    p.parse(varargin{:});
    in=p.Results;

    if~isempty(in.ids)
        taskIds=in.ids;

        if~iscell(taskIds)
            taskIds={taskIds};
        end
    else
        taskIds={};
    end


    if~this.TaskManager.IsInitialized
        this.TaskManager.initialize(this.AnalysisRootComponentId);
    end

    status=0;

    if isempty(this.RootMAObj)

        [~,status]=this.updateModelAdvisorObj(this.AnalysisRootComponentId,true);
    end

    if status==0
        if~isempty(taskIds)
            for n=1:length(taskIds)
                this.TaskManager.selectTask(taskIds{n},false);
            end

        else
            this.TaskManager.selectAllTasks(false);
        end
    end
end