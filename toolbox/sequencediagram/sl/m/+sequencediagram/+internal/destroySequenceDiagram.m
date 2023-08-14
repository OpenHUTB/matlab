function destroySequenceDiagram(modelName,sequenceDiagramName)




    narginchk(2,2);


    if~bdIsLoaded(modelName)
        load_system(modelName);
    end

    sequencediagram.internal.validateSubdomain(modelName);
    builtin('_destroy_sequence_diagram',modelName,sequenceDiagramName);

end



