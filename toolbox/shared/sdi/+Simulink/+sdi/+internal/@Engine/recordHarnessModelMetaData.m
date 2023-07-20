function recordHarnessModelMetaData(this,mdlName,runID)


    interface=Simulink.sdi.internal.Framework.getFramework();
    interface.recordHarnessModelMetaData(this,mdlName,runID);
end