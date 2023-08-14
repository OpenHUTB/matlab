function inputLayerIndices=setInputLayerIndices(networkInfo)









    pirGraphIpLayerNamesInOrder=networkInfo.PIRGraphInputNames;
    numInputs=numel(pirGraphIpLayerNamesInOrder);

    layers=networkInfo.SortedLayers;
    totalLayers=numel(layers);

    inputLayerIndices=zeros(1,numInputs);
    for originalIpLayerNameIdx=1:numInputs
        originalIpLayerNameInPIRGraph=pirGraphIpLayerNamesInOrder{originalIpLayerNameIdx};
        for currLayerIdx=1:totalLayers
            currLayer=layers(currLayerIdx);
            if strcmp(currLayer.Name,originalIpLayerNameInPIRGraph)
                assert((isa(currLayer,'coder.internal.layer.InputLayer')||...
                isa(currLayer,'coder.internal.layer.PassThroughLayer')...
                ));
                inputLayerIndices(originalIpLayerNameIdx)=currLayerIdx;




                break;
            end
        end

    end
end