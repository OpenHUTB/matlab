function utilAdjustTargetFrequency(mdladvObj,hDI)



    if hDI.isShowGenericTargetFrequencyTask
        taskObj=mdladvObj.getTaskObj('com.mathworks.HDL.SetGenericTargetFrequency');
    else
        taskObj=mdladvObj.getTaskObj('com.mathworks.HDL.SetTargetFrequency');
    end

    system=mdladvObj.System;
    hModel=bdroot(system);


    inputParams=mdladvObj.getInputParameters(taskObj.MAC);
    targetFreq=inputParams{1};
    targetFreq.Value=num2str(hDI.getTargetFrequency);

    if~hDI.isShowGenericTargetFrequencyTask
        defaultFreq=inputParams{2};
        rangeFreq=inputParams{4};


        defaultFreq.Value=num2str(hDI.getDefaultTargetFrequency);


        rangeFreq.Value=hDI.getRangeTargetFrequency;
    end


    if hDI.isEnabledTargetFrequency
        targetFreq.Enable=true;
    else
        targetFreq.Enable=false;
    end


    hDI.saveTargetFrequencyToModel(hModel,str2double(targetFreq.Value));


end
