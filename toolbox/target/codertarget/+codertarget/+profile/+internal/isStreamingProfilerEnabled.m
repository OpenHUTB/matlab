function out=isStreamingProfilerEnabled(hObj,varargin)



    hCS=hObj.getConfigSet();
    attr=codertarget.attributes.getTargetHardwareAttributes(hCS);
    supportsTargetServices=attr.SupportsTargetServices;
    connectivitySupport=codertarget.data.isParameterInitialized(hCS,'TargetServices.Running')&&isequal(codertarget.data.getParameterValue(hCS,'TargetServices.Running'),1);
    isProfilingEnabled=isequal(get_param(hCS,'CodeExecutionProfiling'),'on');
    out=isProfilingEnabled&&supportsTargetServices&&connectivitySupport;
end


