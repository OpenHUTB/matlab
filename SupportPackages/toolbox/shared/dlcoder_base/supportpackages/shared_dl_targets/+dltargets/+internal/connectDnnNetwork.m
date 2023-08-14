function connectDnnNetwork(connectivity,topNetwork,networkInfo,layer2comp)






    layers=keys(connectivity);
    for k=1:numel(layers)
        connections=connectivity(layers{k});
        for p=1:numel(connections)
            destLayer=connections(p).outputLayer;
            dltargets.internal.connectComps(...
            layer2comp(layers{k}),...
            connections(p).sourceport,...
            layer2comp(destLayer),...
            connections(p).destport,...
            topNetwork);
        end
    end

    iPrependInputCompAndConnectToDnnNetwork(topNetwork,networkInfo,layer2comp);

    iAppendOutputCompAndConnectToDnnNetwork(topNetwork,networkInfo,layer2comp);

end

function iPrependInputCompAndConnectToDnnNetwork(topNetwork,networkInfo,layer2comp)
    inputLayers=networkInfo.InputLayers;
    inputNames=networkInfo.InputNames;
    numNetworkInputs=numel(inputNames);

    for networkInputPortIdx=1:numNetworkInputs

        inputLayerNameAndPortName=strsplit(inputNames{networkInputPortIdx},'/');
        inputLayerName=inputLayerNameAndPortName{1};


        layerIndices=1:numel(inputLayers);
        inputLayerIdx=layerIndices(cellfun(@(layer)strcmp(layer.Name,inputLayerName),inputLayers));
        inputLayer=inputLayers{inputLayerIdx(1)};

        if~dltargets.internal.checkIfInputLayer(inputLayer)


            inputNodeComp=layer2comp(inputLayer.Name);
            inputNodeInportIdx=1;
            if numel(inputLayerNameAndPortName)>1
                portName=inputLayerNameAndPortName{2};


                isPortNameInInputNamesBoolVector=cellfun(@(inputPortName)strcmp(inputPortName,portName),inputLayer.InputNames);
                inputIndices=1:numNetworkInputs;
                inputNodeInportIdx=inputIndices(isPortNameInInputNamesBoolVector);
            end
            iPrependInputComp(inputNames{networkInputPortIdx},inputNodeInportIdx,inputNodeComp,topNetwork,networkInputPortIdx,networkInfo)
        else
            inputComp=layer2comp(inputNames{networkInputPortIdx});
            inputPort=0;
            dltargets.internal.connectComps(topNetwork,networkInputPortIdx-1,inputComp,inputPort,topNetwork);
        end
    end
end

function iAppendOutputCompAndConnectToDnnNetwork(topNetwork,networkInfo,layer2comp)

    outputLayers=networkInfo.OutputLayers;
    outputNames=networkInfo.OutputNames;
    numNetworkOutputs=numel(outputNames);


    for networkOutputPortIdx=1:numNetworkOutputs

        outputLayerAndPortName=strsplit(outputNames{networkOutputPortIdx},'/');
        outputLayerName=outputLayerAndPortName{1};


        outputLayerIdx=find(cellfun(@(layer)strcmp(layer.Name,outputLayerName),outputLayers));
        outputLayer=outputLayers{outputLayerIdx(1)};

        if(~dltargets.internal.checkIfOutputLayer(outputLayer))

            outputNodeComp=layer2comp(outputLayer.Name);

            danglingNodeOutportIdx=1;
            if numel(outputLayerAndPortName)>1
                portName=outputLayerAndPortName{2};


                isPortNameInOutputNamesBoolVector=cellfun(@(outputName)strcmp(outputName,portName),outputLayer.OutputNames);
                outputIndices=1:numNetworkOutputs;
                danglingNodeOutportIdx=outputIndices(isPortNameInOutputNamesBoolVector);
            end

            iAppendOutputComp(outputNames{networkOutputPortIdx},danglingNodeOutportIdx,outputNodeComp,topNetwork,networkOutputPortIdx,networkInfo)

        else


            outputComp=layer2comp(outputNames{networkOutputPortIdx});
            outputPort=0;
            iAssertValidDLTActivationAndPortIndices(outputComp);
            dltargets.internal.connectComps(outputComp,outputPort,topNetwork,networkOutputPortIdx-1,topNetwork);
            dltargets.internal.setOutputCompProperties(outputComp,outputNames{networkOutputPortIdx},networkInfo);
        end

    end
end

function iAppendOutputComp(outputPortName,danglingNodeOutportIdx,danglingNodeComp,topNetwork,networkOutputPortIdx,networkInfo)


    compKind=dltargets.internal.compbuilder.OutputCompBuilder.getCompKind();
    outputName=char("output_"+outputPortName);
    outputLayerComp=dltargets.internal.compbuilder.CodegenCompBuilder.addComponentToNetwork(...
    topNetwork,compKind,outputName);
    outputLayerComp.setCompKey(dltargets.internal.compbuilder.OutputCompBuilder.getCompKey());
    outputLayerComp.setDLTActivationLayerIndex(danglingNodeComp.getDLTActivationLayerIndex());
    outputLayerComp.setDLTActivationPortIndex(danglingNodeOutportIdx-1);





    outputPort=0;
    dltargets.internal.connectComps(danglingNodeComp,danglingNodeOutportIdx-1,outputLayerComp,outputPort,topNetwork);


    dltargets.internal.setOutputCompProperties(outputLayerComp,outputPortName,networkInfo);


    dltargets.internal.connectComps(outputLayerComp,outputPort,topNetwork,networkOutputPortIdx-1,topNetwork);


    layerHeaders=dltargets.internal.SupportedLayers.m_headerFiles;
    dltargets.internal.utils.LayerToCompUtils.setCustomHeaderProperty(outputLayerComp,layerHeaders);

end

function iPrependInputComp(inputLayerAndPortName,inputNodeInportIdx,inputNodeComp,topNetwork,networkInputPortIdx,networkInfo)

    inPorts=inputNodeComp.PirInputPorts;
    inputFormat=inPorts(inputNodeInportIdx).getDataFormat();

    inputName=char("input_"+replace(inputLayerAndPortName,'/','_'));
    codegenInputSizeToLayer=networkInfo.InputLayerNameToInputSizeMap(inputLayerAndPortName);
    inputNamesIdx=networkInfo.InputLayerNameToInputNamesIdxMap(inputLayerAndPortName);





    networkInfo.updatePIRGraphInputNames(networkInputPortIdx,inputName);

    if contains(inputFormat,'T')

        numSpatialDims=numel(strfind(inputFormat,'S'));


        assert((numSpatialDims==0)||(numSpatialDims==2));

        compKind=dltargets.internal.compbuilder.SequenceInputCompBuilder.getCompKind();
        newInputComp=dltargets.internal.compbuilder.CodegenCompBuilder.addComponentToNetwork(...
        topNetwork,compKind,inputName);
        newInputComp.setCompKey(dltargets.internal.compbuilder.SequenceInputCompBuilder.getCompKey());


        isImageInput=numSpatialDims==2;
        newInputComp.setIsImageInput(isImageInput);

    else
        compKind=dltargets.internal.compbuilder.InputCompBuilder.getCompKind();
        newInputComp=dltargets.internal.compbuilder.CodegenCompBuilder.addComponentToNetwork(...
        topNetwork,compKind,inputName);
        newInputComp.setCompKey(dltargets.internal.compbuilder.InputCompBuilder.getCompKey());






        newInputComp.setHeight(codegenInputSizeToLayer(1));
        newInputComp.setWidth(codegenInputSizeToLayer(2));
        newInputComp.setChannels(codegenInputSizeToLayer(3));



        newInputComp.setNorm('none');
    end



    newInputComp.setBatchSize(codegenInputSizeToLayer(4));


    newInputComp.setInputNamesIndex(int32(inputNamesIdx));







    inputSizeToLayer=dltargets.internal.getInputSizeBasedOnFormat(codegenInputSizeToLayer,inputFormat,1);


    dltargets.internal.setCompOutputDimensions({inputSizeToLayer},{inputFormat},newInputComp);


    dltargets.internal.setCompDataFormats(newInputComp,{inputFormat},{inputFormat});


    layerHeaders=dltargets.internal.SupportedLayers.m_headerFiles;
    dltargets.internal.utils.LayerToCompUtils.setCustomHeaderProperty(newInputComp,layerHeaders);


    outputPort=0;
    dltargets.internal.connectComps(newInputComp,outputPort,inputNodeComp,inputNodeInportIdx-1,topNetwork);


    inputPort=0;
    dltargets.internal.connectComps(topNetwork,networkInputPortIdx-1,newInputComp,inputPort,topNetwork);

end

function iAssertValidDLTActivationAndPortIndices(outputComp)
    assert(outputComp.getDLTActivationLayerIndex()>0,"OutputLayerComps in DAGNetwork must have valid DLTActivationLayerIndex");
    assert(outputComp.getDLTActivationPortIndex()>-1,"OutputLayerComps in DAGNetwork must have valid DLTActivationPortIndex");
end
