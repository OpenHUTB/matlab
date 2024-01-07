function editorId=getOrCreateSequenceDiagramEditorId(modelName,sequenceDiagramName)

    narginchk(2,2);


    if~bdIsLoaded(modelName)
        load_system(modelName);
    end
    sequencediagram.internal.validateSubdomain(modelName);
    editorId=builtin('_get_or_create_sequence_diagram_editor_id',modelName,sequenceDiagramName);

end


