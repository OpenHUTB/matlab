function editor=getEditorFromModel(modelName)

    editor=[];
    allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    for idx=1:numel(allStudios)
        if strcmp(get_param(allStudios(idx).App.blockDiagramHandle,'Name'),modelName)
            editor=allStudios(idx).App.getActiveEditor;
        end
    end
end

