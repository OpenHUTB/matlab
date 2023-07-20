function open(modelName,sequencediagramName,debugMode)




    if nargin<3
        debugMode=false;
    end

    builtin('_open_sequence_diagram',modelName,sequencediagramName,debugMode);
end
