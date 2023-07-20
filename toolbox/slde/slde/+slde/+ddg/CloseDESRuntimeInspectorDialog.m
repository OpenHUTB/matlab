function CloseDESRuntimeInspectorDialog(modelName)




    modelDialogObjectMap=slde.ddg.GetDESRuntimeInspectorDialogMap;
    modelH=get_param(modelName,'handle');

    if modelDialogObjectMap.isKey(modelH)
        obj=modelDialogObjectMap(modelH);
        obj.deleteDialog();
        modelDialogObjectMap(modelH)=[];
        remove(modelDialogObjectMap,modelH);

    end
