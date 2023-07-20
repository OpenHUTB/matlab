function utilCheckCollectCompInfo(model)





    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(model);

    quickScan=false;







    task=mdladvObj.getTaskObj('com.mathworks.Simulink.PerformanceAdvisor.InefficientLookupTableBlocks');

    if task.Selected

        checkObj=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.InefficientLookupTableBlocks');


        CompInfo.value=utilGetLookup1D2DInfo(model,quickScan);
        CompInfo.valid=true;


        utilSetCheckCompInfo(checkObj,CompInfo);
    end







    task=mdladvObj.getTaskObj('com.mathworks.Simulink.PerformanceAdvisor.CheckDelayBlockCircularBufferSetting');

    if task.Selected

        checkObj=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckDelayBlockCircularBufferSetting');


        CompInfo.value=utilGetDelayBlocks(model);
        CompInfo.valid=true;


        utilSetCheckCompInfo(checkObj,CompInfo);
    end







    task=mdladvObj.getTaskObj('com.mathworks.Simulink.PerformanceAdvisor.CheckIfNeedDecoupleContDiscRates');

    if task.Selected

        checkObj=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckIfNeedDecoupleContDiscRates');


        CompInfo.value=utilGetDecoupleInfo(model);
        CompInfo.valid=true;


        utilSetCheckCompInfo(checkObj,CompInfo);
    end























end

