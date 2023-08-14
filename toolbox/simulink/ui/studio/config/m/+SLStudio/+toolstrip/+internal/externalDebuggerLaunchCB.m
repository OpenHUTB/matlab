function externalDebuggerLaunchCB(cbinfo)
    modelH=cbinfo.studio.App.blockDiagramHandle;
    modelHandle=cbinfo.editorModel.handle;
    if~isempty(modelHandle)
        modelH=modelHandle;
    end
    SLCC.OOP.LaunchExternalDebuggerForModel(modelH);
end
