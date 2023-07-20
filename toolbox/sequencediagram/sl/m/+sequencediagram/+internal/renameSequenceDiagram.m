function renameSequenceDiagram(modelName,sequenceDiagramName,newName)




    narginchk(3,3);


    if~bdIsLoaded(modelName)
        load_system(modelName);
    end

    sequencediagram.internal.validateSubdomain(modelName);
    builtin('_rename_sequence_diagram',modelName,sequenceDiagramName,newName);
end

