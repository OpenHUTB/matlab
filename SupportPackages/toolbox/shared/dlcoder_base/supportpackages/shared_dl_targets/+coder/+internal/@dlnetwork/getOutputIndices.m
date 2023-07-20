

















function[sortedOutputLayerIndices,outputPortIndices]=getOutputIndices(dlnet,numOutputsRequested,outputLayerNames,targetLib)




    assert(isa(dlnet,'dlnetwork'));


    if~isempty(outputLayerNames)

        outputLayerNames=string(outputLayerNames);


        iValidateOutputLayerNames(outputLayerNames,dlnet,targetLib);

        numOutputs=numel(outputLayerNames);
    else

        numOutputs=numel(dlnet.OutputNames);
        outputLayerNames=string(dlnet.OutputNames);

    end

    outputLayerIndices=zeros(1,numOutputs);
    outputPortIndices=cell(1,numOutputs);
    for i=1:numOutputs
        [outputLayerIndices(i),outputPortIndices{i}]=coder.internal.coderNetworkUtils.getLayerIndex(dlnet,char(outputLayerNames(i)));
        outputPortIndices{i}=outputPortIndices{i}-1;
    end


    sortedLayers=dltargets.internal.getSortedLayers(dlnet);
    outputLayers=dlnet.Layers(outputLayerIndices);


    sortedOutputLayerIndices=arrayfun(@(layer)find(strcmp({sortedLayers.Name}',layer.Name)),outputLayers,UniformOutput=false);


    sortedOutputLayerIndices=sortedOutputLayerIndices(1:numOutputsRequested);
    outputPortIndices=outputPortIndices(1:numOutputsRequested);
end


function iValidateOutputLayerNames(outputLayerNames,dlnet,targetLib)
    if strcmpi(targetLib,'tensorrt')


        outputLayerNames=string(outputLayerNames);
        layerNames={dlnet.Layers.Name};
        for i=1:numel(outputLayerNames)
            if contains(dlnet.InputNames,outputLayerNames(i))



                outLayerName=outputLayerNames(i);
                inputLayer=dlnet.Layers(layerNames==outLayerName);



                if isprop(inputLayer,'Normalization')&&strcmp(inputLayer.Normalization,'none')
                    error(message('dlcoder_spkg:dlnetwork:InvalidOutputLayerTensorRT',inputLayer.Name));
                end
            end
        end

    end
end
