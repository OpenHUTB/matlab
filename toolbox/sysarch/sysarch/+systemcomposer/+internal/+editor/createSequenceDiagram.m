function sequenceDiagramName=createSequenceDiagram(modelName,sequenceDiagramName)




    if nargin<2
        error('Not enough parameters!');
    end

    sequenceDiagramNames=sequencediagram.internal.getSequenceDiagramNames(modelName);

    index=1;
    tsequenceDiagramName=strcat(sequenceDiagramName,int2str(index));
    while~isempty(sequenceDiagramNames)&&any(strcmp(sequenceDiagramNames,tsequenceDiagramName))
        index=index+1;
        tsequenceDiagramName=strcat(sequenceDiagramName,int2str(index));
    end
    sequenceDiagramName=tsequenceDiagramName;

    sequencediagram.internal.createSequenceDiagram(modelName,sequenceDiagramName);

end


