function createSequenceDiagram(modelName,sequenceDiagramName)




    if nargin<1
        error('Not enough parameters!');
    end


    if~bdIsLoaded(modelName)
        try
            load_system(modelName);
        catch e
            error(e.message);
        end
    end

    sequencediagram.internal.validateSubdomain(modelName);
    builtin('_create_sequence_diagram',modelName,sequenceDiagramName);

end


