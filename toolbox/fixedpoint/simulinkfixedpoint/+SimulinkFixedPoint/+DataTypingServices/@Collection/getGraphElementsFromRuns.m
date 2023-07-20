function[allNodesMap,allEdgesMap]=getGraphElementsFromRuns(this)






















    allNodesMap=containers.Map;
    allEdgesMap=containers.Map;

    fptRepository=fxptds.FPTRepository.getInstance;


    for idx=1:(length(this.refMdls))
        dataset=fptRepository.getDatasetForSource(this.refMdls{idx});
        runObj=dataset.getRun(this.proposalSettings.scaleUsingRunName);





        runObj.deleteInvalidResults();


        localNodeKeys=runObj.dataTypeGroupInterface.nodes.keys;
        localNodes=runObj.dataTypeGroupInterface.nodes.values;
        for index=1:length(localNodeKeys)

            if~allNodesMap.isKey(localNodeKeys{index})
                allNodesMap(localNodeKeys{index})=localNodes{index};
            end
        end



        localEdges=runObj.dataTypeGroupInterface.edges.values;
        localEdgesKeys=runObj.dataTypeGroupInterface.edges.keys;
        for index=1:length(localEdges)

            if~allEdgesMap.isKey(localEdgesKeys{index})
                allEdgesMap(localEdgesKeys{index})=localEdges{index};
            end
        end
    end
end


