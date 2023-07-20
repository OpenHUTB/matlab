function out=isProfilingEnabled(hObj,varargin)



    hCS=hObj.getConfigSet();
    kernelStreamingMode=DAStudio.message('codertarget:ui:HWDiagStreamingModeTypeStorage');

    isKernProf=codertarget.profile.internal.isKernelProfilingEnabled(hCS);
    isCodeProf=codertarget.profile.internal.isCodeInstrumentationProfilingEnabled(hCS);

    if isCodeProf&&codertarget.data.isParameterInitialized(hCS,kernelStreamingMode)
        codertarget.data.setParameterValue(hCS,kernelStreamingMode,DAStudio.message('codertarget:ui:HWDiagStreamingModeUnLimValue'));
    end



    out=isKernProf||isCodeProf;
end

