function out=showConfigurationWidget(hObj,varargin)



    hCS=hObj.getConfigSet();
    out=codertarget.profile.internal.isProfilingEnabled(hCS);
    if out
        isKernelProfiler=codertarget.data.isParameterInitialized(hCS,'Profiler.Instrumentation')&&isequal(codertarget.data.getParameterValue(hCS,'Profiler.Instrumentation'),0);
        transportName=codertarget.attributes.getExtModeData('Transport',hCS);
        isXCP=strcmp(transportName,Simulink.ExtMode.Transports.XCPTCP.Transport);
        out=isKernelProfiler||~isXCP;
    end
end


