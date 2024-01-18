function editorName=harnessIdToEditorName(storedId,shouldOpen)

    if nargin<2
        shouldOpen=true;
    end
    [editorName,localSid]=Simulink.harness.internal.sidmap.getHarnessObjectFromUniqueID(storedId,shouldOpen);
    [~,localSid]=rmisl.harnessTargetIdToSID(storedId);

    if isempty(editorName)
        return;
    else
        editorName=[editorName,localSid];
    end

end
