function isRun=isRunning(varargin)




    isRun=false;
    activeMAObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    if~isempty(activeMAObj)
        if strcmp(activeMAObj.stage,'ExecuteCheckCallback')
            isRun=true;
        end
    end
    if~isRun
        isRun=strcmp(ModelAdvisor.ParallelRun.getStatus(),'running');
    end
