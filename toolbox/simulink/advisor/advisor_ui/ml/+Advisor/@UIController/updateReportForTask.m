function report=updateReportForTask(this,TaskId)

    taskObj=this.maObj.getTaskObj(TaskId);
    checkObj=taskObj.Check;

    if strcmp(checkObj.CallbackStyle,'StyleTwo')||strcmp(checkObj.CallbackStyle,'StyleThree')
        resultDescription=checkObj.Result{1};
        resultHandles=checkObj.Result{2};
    else
        resultHandles=checkObj.Result;
        resultDescription=cell(numel(resultHandles));
    end

    if~iscell(resultHandles)
        resultHandles={resultHandles};
    end


    report=this.maObj.formatCheckCallbackOutput(checkObj,resultHandles,resultDescription,taskObj.MACIndex,false,taskObj);
end