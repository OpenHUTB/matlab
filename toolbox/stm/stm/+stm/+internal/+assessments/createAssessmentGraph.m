












function outputGraph=createAssessmentGraph(assessDataStruct)

    sourceNodes=[];
    targetNodes=[];
    for i=1:length(assessDataStruct)
        if assessDataStruct{i}.parent~=-1
            sourceNodes=[sourceNodes,string(assessDataStruct{i}.parent)];
            targetNodes=[targetNodes,string(assessDataStruct{i}.id)];
        end
    end

    outputGraph=digraph(sourceNodes,targetNodes);

end

