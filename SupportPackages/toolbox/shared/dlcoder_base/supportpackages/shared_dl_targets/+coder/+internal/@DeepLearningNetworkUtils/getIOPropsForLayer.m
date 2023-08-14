














function[opSize,sortedLayerIdx,portId,isSequenceOutput,isSequenceFolded]=getIOPropsForLayer(net,layerArg,inputSizes,targetLib)




    coder.allowpcode('plain');


    [oplayerIdx,portId]=coder.internal.coderNetworkUtils.getLayerIndex(net,layerArg);


    maxLayers=coder.const(numel(net.Layers));
    coder.internal.assert(maxLayers>=oplayerIdx,...
    'dlcoder_spkg:cnncodegen:invalid_layerIdx',...
    num2str(oplayerIdx));
    layer=net.Layers(oplayerIdx);


    inputLayers=dltargets.internal.getIOLayers(net);

    for i=1:numel(inputLayers)

        if strcmpi(targetLib,'tensorrt')



            if isequal(layer,inputLayers{i})&&strcmp(layer.Normalization,'none')
                error(message('dlcoder_spkg:cnncodegen:invalid_activation_tensorrt',layerArg));
            end
        end
    end


    inputSizes=iStripBatchDim(inputSizes);


    outputSize=coder.internal.iohandling.cnn.OutputDataPreparer.getOutputSizeForLayer(...
    net,...
    layer,...
    portId,...
    inputSizes);

    if isa(net,'DAGNetwork')

        sortedLayerIdx=find(strcmp({net.SortedLayers.Name}',layer.Name));
    else
        sortedLayerIdx=oplayerIdx;
    end

    opSize=outputSize;








    isSequenceOutputLayerVector=net.getInternalDAGNetwork.inferSequenceOutput();



    isSequenceOutput=isSequenceOutputLayerVector(sortedLayerIdx);


    lgraph=dltargets.internal.getSortedLayerGraph(net);

    isCustomCoderLayerGraph=false;
    isSequenceFolded=coder.internal.DeepLearningNetworkUtils.checkIfFolded(lgraph,sortedLayerIdx,isCustomCoderLayerGraph);
end


function formattedInputSizes=iStripBatchDim(inputSizes)
    formattedInputSizes=cell(size(inputSizes));
    for i=1:numel(inputSizes)
        formattedInputSizes{i}=inputSizes{i}(1:end-1);
    end
end
