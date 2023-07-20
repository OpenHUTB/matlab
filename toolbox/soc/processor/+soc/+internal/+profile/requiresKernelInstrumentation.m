function out=requiresKernelInstrumentation(modelName)
    hCS=getActiveConfigSet(modelName);
    instrumentationLabel=DAStudio.message('codertarget:ui:HWDiagInstrumentationStorage');
    out=isequal(codertarget.data.getParameterValue(hCS,instrumentationLabel),'Kernel');

end