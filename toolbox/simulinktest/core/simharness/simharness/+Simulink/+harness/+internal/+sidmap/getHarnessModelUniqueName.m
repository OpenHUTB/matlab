function[mdlLocation,mdlName,mdlExt]=getHarnessModelUniqueName(model)

    systemModel=Simulink.harness.internal.getHarnessOwnerBD(model);
    modelFilePath=get_param(systemModel,'FileName');
    [mdlLocation,mdlName,mdlExt]=fileparts(modelFilePath);

    harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(model);
    mdlName=[mdlName,':',harnessInfo.uuid];
end
