function outputConnectionInfo=getLayerOutputConnections(connectionInfo,layerIdx)
































    sourceNodeIdxColumn=1;

    sourcePortColumnIdx=1;
    destPortColumnIdx=2;










    uniqueEdgeAndPortIdx=connectionInfo.EndNodes(:,sourceNodeIdxColumn)==layerIdx;

    uniqueEdgesAndPorts=connectionInfo.EndPorts(uniqueEdgeAndPortIdx);
    numOutputs=sum(cellfun(@(portConnections)size(portConnections,1),uniqueEdgesAndPorts));

    uniqueTargets=connectionInfo.EndNodes(uniqueEdgeAndPortIdx,2);


    outputConnectionInfo=zeros(numOutputs*2,1);
    for iTarget=1:numel(uniqueTargets)
        outPortIdxForLayer=uniqueEdgesAndPorts{iTarget}(sourcePortColumnIdx);
        numEdgesToTarget=numel(uniqueEdgesAndPorts{iTarget}(:,destPortColumnIdx));
        outputConnectionInfo((outPortIdxForLayer-1)*2+1+(0:2:numEdgesToTarget))=uniqueTargets(iTarget);
        outputConnectionInfo((outPortIdxForLayer-1)*2+2+(0:2:numEdgesToTarget))=uniqueEdgesAndPorts{iTarget}(:,destPortColumnIdx);
    end

end
