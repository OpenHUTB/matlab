function map=ModelToDialogMap()




    persistent modelToDialogMap
    if isempty(modelToDialogMap)
        modelToDialogMap=containers.Map;
    end
    map=modelToDialogMap;
