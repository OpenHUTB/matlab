function inputConnectionInfo=getLayerInputConnectionForInPort(connectionInfo,layerIdx,inPortIdx)



































































    destinationNodeIdxColumn=2;

    sourcePortColumnIdx=1;
    destPortColumnIdx=2;



    uniqueEdgeLogicalIdx=connectionInfo.EndNodes(:,destinationNodeIdxColumn)==layerIdx;






    uniqueEndPortLogicalIdx=cellfun(@(endPorts)endPorts(:,destPortColumnIdx)==inPortIdx,connectionInfo.EndPorts,'UniformOutput',false);






    uniqueEdgeAndPortLogicalIdx=uniqueEdgeLogicalIdx&cellfun(@(logicalEndPortIdx)any(logicalEndPortIdx),uniqueEndPortLogicalIdx);


    inputConnectionInfo=[];
    if any(uniqueEdgeAndPortLogicalIdx)


        assert(nnz(uniqueEdgeAndPortLogicalIdx)==1);


        uniqueSources=connectionInfo.EndNodes(uniqueEdgeAndPortLogicalIdx,1);



        uniqueEdgesAndPorts=connectionInfo.EndPorts(uniqueEdgeAndPortLogicalIdx);


        numInputs=sum(cellfun(@(portConnections)size(portConnections,1),uniqueEdgesAndPorts));


        uniqueSubEndPortLogicalIdx=uniqueEndPortLogicalIdx(uniqueEdgeAndPortLogicalIdx);


        uniqueSubEndPortIndices=(1:numInputs)';
        uniqueSubEndPortIdx=uniqueSubEndPortIndices(uniqueSubEndPortLogicalIdx{1});



        inputConnectionInfo=zeros(2,1);

        inputConnectionInfo(1)=uniqueSources(1);
        inputConnectionInfo(2)=uniqueEdgesAndPorts{1}(uniqueSubEndPortIdx,sourcePortColumnIdx);

    end
end

