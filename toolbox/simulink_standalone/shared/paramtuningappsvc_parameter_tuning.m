function paramtuningappsvc_parameter_tuning(in1,blockPath,paramName,newValue)






    if isa(in1,'char')||isa(in1,'double')

        obj=codertarget.targetservices.SDIIntegration.manageInstance('get',in1);
        svc=obj.TgtConnMgr.getService('coder.internal.connectivity.ParamTuningAppSvc');
    elseif isa(in1,'simulinkstandalone.metamodel.BuildData')

        svc=in1.tgtConnMgr.getService('coder.internal.connectivity.ParamTuningAppSvc');
    else
        assert(false,'The first input argument to paramtuningappsvc_parameter_tuning must be either a model name or a struct');
    end

    if(isstruct(newValue))
        newValue=simulink.rapidaccelerator.internal.convertStructFieldsToTargetFormat(newValue);
    end

    try
        svc.setParam(blockPath,paramName,newValue);
        svc.tuneParams();
    catch ME
        MSLDiagnostic('Simulink:tools:rapidAccelTgtConnParamDownloadWarning',ME.message).reportAsWarning;
    end
end
