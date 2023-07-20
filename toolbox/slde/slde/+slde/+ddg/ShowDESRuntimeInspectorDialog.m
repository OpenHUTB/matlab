function obj=ShowDESRuntimeInspectorDialog(blockPath)







    modelDialogObjectMap=slde.ddg.GetDESRuntimeInspectorDialogMap;

    modelName=bdroot(blockPath);
    modelH=get_param(modelName,'handle');

    if~modelDialogObjectMap.isKey(modelH)
        modelDialogObjectMap(modelH)=...
        slde.ddg.DESRuntimeInspectorDialog(blockPath);
    end

    obj=modelDialogObjectMap(modelH);
    obj.showDESRuntimeDialog(blockPath);