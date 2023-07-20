function result=commonSrcInterpIdentify(system)




    result='';
    MAObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    MATask=MAObj.getTaskObj('com.mathworks.Simulink.MdlTransformer.CommonSrcInterpXform');
    [wmsg,emsg]=m2m_obj_creation(system,MATask,'slEnginePir.m2m_CommonSourceInterpolation');

    if~isempty(emsg)
        result=emsg;
        return;
    end

    inputParams=MAObj.getInputParameters;
    skipLib=inputParams{1}.Value;
    if skipLib
        MAObj.Userdata.fSkipLinkedBlks=1;
    else
        MAObj.Userdata.fSkipLinkedBlks=0;
    end

    try
        result=commonSrcInterpXformCandidate(MAObj.Userdata,system,0);
        MATask.check.Action.Enable=true;
        MAObj.setCheckResultStatus(true);
        MAObj.setCheckResultData(wmsg);
    catch ME
        result=ME.message;
        MAObj.setCheckErrorSeverity(true);
    end

end


