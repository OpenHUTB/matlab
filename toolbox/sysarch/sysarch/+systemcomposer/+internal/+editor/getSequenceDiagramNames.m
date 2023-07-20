function names=getSequenceDiagramNames(modelName)



    names={};
    file=which('sequencediagram.internal.getSequenceDiagramNames');
    if(~isempty(file))
        try
            names=sequencediagram.internal.getSequenceDiagramNames(modelName);
            names=sort(names);
        catch

        end
    end
end


