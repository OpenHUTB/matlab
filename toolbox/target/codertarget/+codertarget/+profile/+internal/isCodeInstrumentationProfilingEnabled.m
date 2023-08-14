function out=isCodeInstrumentationProfilingEnabled(hObj,varargin)




    hCS=hObj.getConfigSet();

    storage=DAStudio.message('codertarget:ui:HWDiagShowInSDIStorage');
    isShowInSDI=codertarget.data.isParameterInitialized(hCS,storage)&&...
    codertarget.data.getParameterValue(hCS,storage);

    storage=DAStudio.message('codertarget:ui:HWDiagInstrumentationStorage');
    isCodeInst=codertarget.data.isParameterInitialized(hCS,storage)&&...
    isequal(codertarget.data.getParameterValue(hCS,storage),'Code');


    isCodeExecProf=isequal(get_param(hCS,'CodeExecutionProfiling'),'on');


    out=isShowInSDI&&isCodeInst&&isCodeExecProf;
end
