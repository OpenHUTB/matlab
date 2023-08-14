function[layerInputSizes,layerInputFormats,layerHasSequenceInput]=getLayerInputShapesAndSequenceInfo(layerIdx,...
    connectionInfo,layerOutputSizes,layerOutputFormats,networkInputSizeMap,layer,inputFormatToInputNamesMap,...
    isDlnetwork,inputLayers)





































































    numInputs=iGetNumInputsToLayer(layer);

    layerInputSizes=cell(1,numInputs);
    layerInputFormats=cell(1,numInputs);
    layerHasSequenceInput=false(1,numInputs);
    for inPortIdx=1:numInputs

        ipConnectionInfoSpecificToInPortIdx=dltargets.internal.getLayerInputConnectionForInPort(connectionInfo,layerIdx,inPortIdx);
        if isempty(ipConnectionInfoSpecificToInPortIdx)


            isInputLayer=any(cellfun(@(layerFromInputLayerCellArray)strcmp(layer.Name,layerFromInputLayerCellArray.Name),inputLayers));
            assert(isInputLayer);

            assert(~isempty(networkInputSizeMap));








            if numInputs>1



                layerAndPortName=[layer.Name,'/',layer.InputNames{inPortIdx}];
            else



                layerAndPortName=layer.Name;
            end

            [layerInputSizes{inPortIdx},layerInputFormats{inPortIdx}]=iGetIpSizeAndFormatUsingLayerAndPortName...
            (layerAndPortName,networkInputSizeMap,inputFormatToInputNamesMap,layer,isDlnetwork);
        else





            predecessorOutputSizes=layerOutputSizes(ipConnectionInfoSpecificToInPortIdx(1));
            predecessorOutputFormats=layerOutputFormats(ipConnectionInfoSpecificToInPortIdx(1));

            if iscell(predecessorOutputSizes)
                predecessorOutputSizes=predecessorOutputSizes{1};
                predecessorOutputFormats=predecessorOutputFormats{1};
            end
            layerInputSizes(inPortIdx)=predecessorOutputSizes(ipConnectionInfoSpecificToInPortIdx(2));
            layerInputFormats(inPortIdx)=predecessorOutputFormats(ipConnectionInfoSpecificToInPortIdx(2));
            layerInputFormats{inPortIdx}=iOrderFormat(layerInputFormats{inPortIdx});
        end


        layerHasSequenceInput(inPortIdx)=contains(layerInputFormats{inPortIdx},'T');
    end

end

function numInputs=iGetNumInputsToLayer(layer)


    numInputs=1;
    if~dltargets.internal.checkIfInputLayer(layer)


        internaLayer=nnet.cnn.layer.Layer.getInternalLayers(layer);
        assert(~isempty(internaLayer{1}.InputNames));
        numInputs=numel(internaLayer{1}.InputNames);
    end
end

function[layerInputSize,layerInputFormat]=iGetIpSizeAndFormatUsingLayerAndPortName(layerAndPortName,networkInputSizeMap,inputFormatToInputNamesMap,layer,isDlnetwork)




    inputFormat=inputFormatToInputNamesMap(layerAndPortName);
    if isempty(inputFormat)


        layerInputFormat=dltargets.internal.getFormatAndExampleInputsForInputLayer(layer,...
        networkInputSizeMap(layerAndPortName),inputFormat,isDlnetwork);
    else
        layerInputFormat=inputFormat;
    end
    layerInputFormat=iOrderFormat(layerInputFormat);

    layerInputSize=dltargets.internal.getInputSizeBasedOnFormat(...
    networkInputSizeMap(layerAndPortName),layerInputFormat,[]);
end

function fmt=iOrderFormat(fmt)










    orderedLabels='SCBTU';

    [~,dimInd]=ismember(fmt,orderedLabels);
    dimInd=sort(dimInd);
    fmt=orderedLabels(dimInd);
end