function result=lutIdentify(system)




    result='';
    MAObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    MATask=MAObj.getTaskObj('com.mathworks.Simulink.MdlTransformer.LutXform');

    [wmsg,emsg]=m2m_obj_creation(system,MATask,'slEnginePir.m2m_lut');

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
    prefix=inputParams{2}.Value;

    try
        result=lutXformCandidate(MAObj.Userdata,system,0);
        MATask.check.Action.Enable=true;
        MAObj.setCheckResultStatus(true);
        MAObj.setCheckResultData(wmsg);
    catch ME
        result=ME.message;
        MAObj.setCheckErrorSeverity(true);
    end
end

