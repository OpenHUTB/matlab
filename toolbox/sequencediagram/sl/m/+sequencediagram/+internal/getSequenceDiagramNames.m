function names=getSequenceDiagramNames(modelName)

    if~bdIsLoaded(modelName)
        try
            load_system(modelName);
        catch ME
            ME.throwAsCaller();
        end
    end
    sequencediagram.internal.validateSubdomain(modelName);
    names=builtin('_get_available_sequencediagrams',modelName);
end


