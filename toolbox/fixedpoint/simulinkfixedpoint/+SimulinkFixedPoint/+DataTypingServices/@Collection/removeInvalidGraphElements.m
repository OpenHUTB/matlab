function[allNodes,allEdges]=removeInvalidGraphElements(this,allNodesMap,allEdgesMap)






























    allNodes=allNodesMap.values;


    invalidNodesIndex=cellfun(@(x)(~fxptds.isResultValid(x)),allNodes);


    allEdges=allEdgesMap.values;



    if~any(invalidNodesIndex)
        return;
    end


    allNodesKeys=allNodesMap.keys;


    allNodes(invalidNodesIndex)='';


    invalidNodesKeys=allNodesKeys(invalidNodesIndex);





    invalidNodes=cellfun(@(x)(allNodesMap(x)),invalidNodesKeys,'UniformOutput',false);

    for index=1:length(invalidNodesKeys)



        allEdgesLength=length(allEdges);
        currentInvalidEdgesIndex=false(1,allEdgesLength);
        for edgesIndex=1:allEdgesLength
            currentInvalidEdgesIndex(edgesIndex)=any(strcmp(invalidNodesKeys{index},allEdges{edgesIndex}));
        end


        currentInvalidEdges=allEdges(currentInvalidEdgesIndex);


        allEdges(currentInvalidEdgesIndex)='';








        currentInvalidEdges=[currentInvalidEdges{:}];

        if~isempty(currentInvalidEdges)

            currentInvalidEdges(strcmp(invalidNodesKeys{index},currentInvalidEdges))='';


            for k=1:length(currentInvalidEdges)

                absorbingNode=allNodesMap(currentInvalidEdges{k});
                this.collapseNode(invalidNodes{index},absorbingNode);
            end


            for k=1:length(currentInvalidEdges)-1
                allEdges=[allEdges,{{currentInvalidEdges{k},currentInvalidEdges{k+1}}}];%#ok<AGROW>
            end
        end
    end

end


