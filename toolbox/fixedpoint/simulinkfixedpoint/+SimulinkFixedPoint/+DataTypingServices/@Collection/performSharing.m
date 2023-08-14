function performSharing(this)




    [allNodesMap,allEdgesMap]=this.getGraphElementsFromRuns();



    if~isempty(allNodesMap)




        [allNodes,allEdges]=this.removeInvalidGraphElements(allNodesMap,allEdgesMap);


        allEdges=this.shareDataObjects(allNodes,allEdges);


        universalGroupInterface=fxptds.DataTypeGroupInterface();


        cellfun(@(x)(universalGroupInterface.addNode(x)),allNodes);


        cellfun(@(x)(universalGroupInterface.addEdge(x{1},x{2})),allEdges);



        universalGroupInterface.formDataTypeGroups();










        fptRepository=fxptds.FPTRepository.getInstance;

        for idx=1:(length(this.refMdls))
            dataset=fptRepository.getDatasetForSource(this.refMdls{idx});
            runObj=dataset.getRun(this.proposalSettings.scaleUsingRunName);


            runObj.setDataTypeGroupInterface(universalGroupInterface);
        end
    end
end
