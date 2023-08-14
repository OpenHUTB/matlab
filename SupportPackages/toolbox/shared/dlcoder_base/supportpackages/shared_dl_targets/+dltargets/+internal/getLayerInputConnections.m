function inputConnectionInfo=getLayerInputConnections(connectionInfo,layerIdx)































    destinationNodeIdxColumn=2;

    sourcePortColumnIdx=1;
    destPortColumnIdx=2;










    uniqueEdgeAndPortIdx=connectionInfo.EndNodes(:,destinationNodeIdxColumn)==layerIdx;

    uniqueEdgesAndPorts=connectionInfo.EndPorts(uniqueEdgeAndPortIdx);
    numInputs=sum(cellfun(@(portConnections)size(portConnections,1),uniqueEdgesAndPorts));

    uniqueSources=connectionInfo.EndNodes(uniqueEdgeAndPortIdx,1);


    inputConnectionInfo=zeros(numInputs*2,1);
    for iSource=1:numel(uniqueSources)
        inPortIdxForLayer=uniqueEdgesAndPorts{iSource}(destPortColumnIdx);
        numEdgesFromSource=numel(uniqueEdgesAndPorts{iSource}(:,sourcePortColumnIdx));
        inputConnectionInfo((inPortIdxForLayer-1)*2+1+(0:2:numEdgesFromSource))=uniqueSources(iSource);
        inputConnectionInfo((inPortIdxForLayer-1)*2+2+(0:2:numEdgesFromSource))=uniqueEdgesAndPorts{iSource}(:,sourcePortColumnIdx);
    end

end

