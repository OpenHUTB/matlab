function map=ModelToDialogMap()





mlock
    persistent modelToDialogMap
    if isempty(modelToDialogMap)
        modelToDialogMap=containers.Map;
    end
    map=modelToDialogMap;
