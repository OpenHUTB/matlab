function map=GetDESRuntimeInspectorDialogMap




    persistent modelDESRuntimeDialogObjectMap;

    if~isa(modelDESRuntimeDialogObjectMap,'containers.Map')
        modelDESRuntimeDialogObjectMap=...
        containers.Map('KeyType','double','ValueType','any');
    end
    map=modelDESRuntimeDialogObjectMap;