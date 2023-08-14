function out=showKernelProfilingOptions(hObj,varargin)



    isProfilingEnabled=codertarget.profile.internal.isProfilingEnabled(hObj);
    hCS=hObj.getConfigSet();
    out=isProfilingEnabled&&strcmpi('Linux',codertarget.targethardware.getTargetRTOS(hCS));
end


