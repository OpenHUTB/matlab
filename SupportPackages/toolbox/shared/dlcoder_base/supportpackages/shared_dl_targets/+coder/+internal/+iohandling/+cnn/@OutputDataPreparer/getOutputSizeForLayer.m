%#codegen














function outputSize=getOutputSizeForLayer(net,outputLayer,portId,inputSizes)



    coder.allowpcode('plain');

    sortedLayers=dltargets.internal.getSortedLayers(net);


    sortedlayerIdx=find(strcmp({sortedLayers.Name}',outputLayer.Name));


    inputSizes=iPrepareInputSizes(inputSizes,net);

    outputSize=net.getOutputSize(sortedlayerIdx,inputSizes);

    if iscell(outputSize)

        assert(numel(outputSize)>=portId);


        outputSize=outputSize{portId};
    end

end






function inputSizes=iPrepareInputSizes(inputSizes,net)
    numInputLayers=numel(net.InputNames);

    if~iscell(inputSizes)
        inputSizes={inputSizes};
    end

    assert(numel(inputSizes)==numInputLayers);
    for inIdx=1:numInputLayers
        layerIdx=find(strcmp(net.InputNames{inIdx},{net.Layers.Name}));
        if isa(net.Layers(layerIdx),'nnet.cnn.layer.FeatureInputLayer')
            featureSize=inputSizes{inIdx};
            assert(numel(featureSize)==1||numel(featureSize)==3);




            if numel(featureSize)==3
                featureSize=featureSize(3);
            end

            dummyBatchDimension=1;
            newInputSize=[dummyBatchDimension,featureSize];
            inputSizes{inIdx}=newInputSize;
        end
    end
end