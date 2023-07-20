function[processedOutSizes,processedOutFormats,hasSequenceOutput]=getLayerOutputShapesAndSequenceInfo(net,inputSizes,inputFormats,exampleSequenceLengths)
































    lg=toposort(dltargets.internal.utils.NetworkUtils.getLayerGraph(net));
    outputNames=iPrepareOutputNames(lg);

    if isa(net,'dlnetwork')
        sampleInputs=iPrepareDummyInputsForDLNetwork(net,inputSizes,inputFormats,exampleSequenceLengths);
        [outSizes,outFormats]=deep.internal.sdk.forwardDataAttributes(net,sampleInputs{:},'Outputs',outputNames);

        [processedOutSizes,processedOutFormats,hasSequenceOutput]=iPostprocessOutSizes(outSizes,outFormats,...
        outputNames,lg);
    else
        [sampleInputs,isBatchDimStripped]=iPrepareDummyInputsForDAGNetwork(net,inputSizes);
        [outSizes,outFormats]=deep.internal.sdk.forwardDataAttributes(net,sampleInputs{:},'Outputs',outputNames);

        [processedOutSizes,processedOutFormats,hasSequenceOutput]=iPostprocessOutSizes(outSizes,outFormats,...
        outputNames,lg);

        if isBatchDimStripped



            batchSize=inputSizes{1}(end);
            [processedOutSizes,processedOutFormats]=iAddBatchDim(processedOutSizes,processedOutFormats,batchSize,lg);
        end
    end
end








function inputPlaceholders=iPrepareDummyInputsForDLNetwork(net,inputSizes,inputFormats,exampleSequenceLengths)
    isDefferedInitializedDLNet=isa(net,'dlnetwork')&&~isempty(net.getExampleInputs);
    inputLayers=dltargets.internal.getIOLayers(net);
    inputPlaceholders=cell(numel(inputSizes),1);
    isLayerInDlnetwork=true;
    for i=1:numel(inputSizes)

        inputFormat=inputFormats{i};

        exampleSequenceLength=[];
        if~isempty(exampleSequenceLengths)
            exampleSequenceLength=exampleSequenceLengths(i);
        end

        if isDefferedInitializedDLNet




            [~,inputPlaceholders{i}]=...
            dltargets.internal.getFormatAndExampleInputsForInputLayer([],inputSizes{i},inputFormat,isLayerInDlnetwork,exampleSequenceLength);
        else
            [~,inputPlaceholders{i}]=...
            dltargets.internal.getFormatAndExampleInputsForInputLayer(inputLayers{i},inputSizes{i},inputFormat,isLayerInDlnetwork,exampleSequenceLength);
        end
    end
end


function[inputPlaceholders,isBatchDimStripped]=iPrepareDummyInputsForDAGNetwork(lg,inputSizes)

    isBatchDimStripped=false;
    inputLayers=dltargets.internal.getIOLayers(lg);

    inputPlaceholders=cell(numel(inputLayers),1);
    inputFormats=cell(numel(inputLayers),1);


    inputFormat=[];
    for i=1:numel(inputLayers)
        isLayerInDlnetwork=false;

        [inputFormats{i},inputPlaceholders{i}]=dltargets.internal.getFormatAndExampleInputsForInputLayer(inputLayers{i},...
        inputSizes{i},inputFormat,isLayerInDlnetwork);




        if isa(inputLayers{i},'nnet.cnn.layer.SequenceInputLayer')
            isBatchDimStripped=true;
            inputPlaceholders{i}=iStripBatchDim(inputPlaceholders{i},inputFormats{i});
        end
    end
end



function inputData=iStripBatchDim(inputData,inputFormat)
    inputSize=size(inputData);
    batchDim=strfind(inputFormat,'B');
    assert(~isempty(batchDim),"Batch dimension not found in the input data format.");



    if numel(inputSize)>=batchDim
        inputSize(batchDim)=[];
    end

    inputData=ones(inputSize);
end



function[outputSizes,outputFormats]=iAddBatchDim(outputSizes,outputFormats,batchSize,lgraph)

    sortedLayers=dltargets.internal.getSortedLayers(lgraph);

    for iLayer=1:numel(sortedLayers)

        layer=sortedLayers(iLayer);
        if isprop(layer,'NumOutputs')&&layer.NumOutputs>1
            numOutputs=layer.NumOutputs;
        else
            numOutputs=1;
        end

        for iOut=1:numOutputs
            batchDim=strfind(outputFormats{iLayer}{iOut},'B');
            if~isempty(batchDim)






                if~isa(layer,'nnet.layer.Layer')||outputSizes{iLayer}{iOut}(batchDim)==1










                    outputSizes{iLayer}{iOut}(batchDim)=batchSize;
                end
            else


                sequenceDim=strfind(outputFormats{iLayer}{iOut},'T');
                if~isempty(sequenceDim)
                    batchDim=sequenceDim;
                else
                    unspecifiedDim=strfind(outputFormats{iLayer}{iOut},'U');
                    if~isempty(unspecifiedDim)
                        batchDim=unspecifiedDim;
                    else
                        batchDim=numel(outputFormats{iLayer}{iOut})+1;
                    end
                end
                outputSizes{iLayer}{iOut}=[outputSizes{iLayer}{iOut}(1:batchDim-1),batchSize,outputSizes{iLayer}{iOut}(batchDim:end)];
                outputFormats{iLayer}{iOut}=[outputFormats{iLayer}{iOut}(1:batchDim-1),'B',outputFormats{iLayer}{iOut}(batchDim:end)];
            end
        end
    end
end



function finalOutputNames=iPrepareOutputNames(lgraph)
    sortedLayers=dltargets.internal.getSortedLayers(lgraph);
    numLayers=numel(sortedLayers);
    finalOutputNames={};
    for i=1:numLayers
        layer=sortedLayers(i);
        layerName=layer.Name;
        if isprop(layer,'NumOutputs')&&layer.NumOutputs>1
            outputNames=cellfun(@(outputPortName)strcat(layerName,'/',outputPortName),layer.OutputNames,'UniformOutput',false);
        else
            outputNames={layerName};
        end

        finalOutputNames=[finalOutputNames,outputNames];%#ok
    end
end





function[processedOutSizes,processedOutFormats,hasSequenceOutput]=iPostprocessOutSizes(outSizes,outFormats,...
    outputNames,lgraph)

    sortedLayers=dltargets.internal.getSortedLayers(lgraph);
    numLayers=numel(sortedLayers);
    hasSequenceOutput=false(numLayers,1);

    layerNames=string({sortedLayers.Name});



    for i=1:numel(outFormats)
        layerNameAndPort=split(outputNames{i},'/');
        sequenceDim=strfind(outFormats{i},'T');
        if~isempty(sequenceDim)
            unspecifiedDim=strfind(outFormats{i},'U');

            if~isempty(unspecifiedDim)
                coder.internal.assert(sequenceDim==unspecifiedDim-1,"dlcoder_spkg:cnncodegen:DLCoderInternalError");
            else
                coder.internal.assert(sequenceDim==numel(outFormats{i}),"dlcoder_spkg:cnncodegen:DLCoderInternalError");
            end
            outSizes{i}(sequenceDim)=[];


            layerIndex=layerNames==layerNameAndPort(1);
            hasSequenceOutput(layerIndex)=true;
        end
    end


    processedOutSizes=cell(numLayers,1);
    processedOutFormats=cell(numLayers,1);

    offset=1;
    for i=1:numLayers
        layer=sortedLayers(i);
        if isprop(layer,'NumOutputs')&&(layer.NumOutputs>1)
            numOutputs=layer.NumOutputs;
        else
            numOutputs=1;
        end

        if numOutputs
            processedOutSizes{i}=outSizes(offset:offset+numOutputs-1);
            processedOutFormats{i}=outFormats(offset:offset+numOutputs-1);
        else
            processedOutSizes{i}=outSizes{offset};
            processedOutFormats{i}=outFormats{offset};
        end

        offset=offset+numOutputs;
    end
end
