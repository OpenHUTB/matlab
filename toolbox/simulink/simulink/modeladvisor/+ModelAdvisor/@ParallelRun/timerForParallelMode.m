function timerForParallelMode(obj)


    if strcmp(obj.parallelJob.State,'finished')
        obj.cleanup();
        return;
    else
        try
            parallelInfo=obj.mdladvObj.Database.loadData('ParallelInfo');
        catch E
            return;
        end
        if~isempty(parallelInfo)&&...
            isfield(parallelInfo,'status')&&...
            ~isempty(parallelInfo.status)&&...
            strcmp(parallelInfo.status,DAStudio.message('ModelAdvisor:engine:BackgroundRunCompleted'))
            obj.cleanup();
            return;
        end
    end

    try
        if isempty(parallelInfo)||~isfield(parallelInfo,'index')||parallelInfo.index==0
            if isfield(parallelInfo,'status')&&isempty(parallelInfo.status)
                statusStr=DAStudio.message('ModelAdvisor:engine:BackgroundRunStarting');
            else
                statusStr=parallelInfo.status;
            end
        else
            statusStr=DAStudio.message('ModelAdvisor:engine:BackgroundRunStatus',num2str(parallelInfo.index),num2str(parallelInfo.orderedTaskIndex));
            if isfield(parallelInfo,'status')&&~isempty(parallelInfo.status)&&...
                strcmp(parallelInfo.status,DAStudio.message('Simulink:tools:MACompilingModel'))
                statusStr=DAStudio.message('Simulink:tools:MACompilingModel');
            end
        end
        obj.mdladvObj.setStatus(statusStr);
    catch E

    end