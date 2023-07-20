function out=isKernelProfilingEnabled(hObj,varargin)




    hCS=hObj.getConfigSet();

    storage=DAStudio.message('codertarget:ui:HWDiagShowInSDIStorage');
    isShowInSDI=codertarget.data.isParameterInitialized(hCS,storage)&&...
    codertarget.data.getParameterValue(hCS,storage);

    storage=DAStudio.message('codertarget:ui:HWDiagInstrumentationStorage');
    isKernelInst=codertarget.data.isParameterInitialized(hCS,storage)&&...
    isequal(codertarget.data.getParameterValue(hCS,storage),'Kernel');


    out=isShowInSDI&&isKernelInst;
end
