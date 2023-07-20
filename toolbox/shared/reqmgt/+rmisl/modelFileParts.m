function[mdlLocation,mdlName,mdlExt]=modelFileParts(modelH,resolveHarnessId)
    if nargin<2
        resolveHarnessId=true;
    end
    if resolveHarnessId&&rmisl.isComponentHarness(modelH)


        [mdlLocation,mdlName,mdlExt]=Simulink.harness.internal.sidmap.getHarnessModelUniqueName(modelH);
    else
        modelFilePath=get_param(modelH,'FileName');
        [mdlLocation,mdlName,mdlExt]=fileparts(modelFilePath);
    end
end
