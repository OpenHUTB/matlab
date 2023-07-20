





















%#codegen



function outputs=callPredictAndUpdateState(obj,inputsT,~,...
    dltNetwork,networkInfo,networkName,codegenInputSizes,~,...
    outputLayerIndices,numOutputLayers)



    if~coder.target('MATLAB')

        eml_allow_mx_inputs;
    end

    coder.allowpcode('plain');
    coder.inline('always');
    coder.extrinsic('coder.internal.DeepLearningNetworkUtils.getCustomLayerPropsForCCode');
    coder.internal.prefer_const(dltNetwork,networkInfo,networkName,codegenInputSizes,...
    outputLayerIndices,numOutputLayers);


    obj.setDLCustomCoderNetwork(dltNetwork,networkInfo,networkName);

    inputLayerIndices=coder.const(@feval,'getInputLayerIndices',obj.DLCustomCoderNetwork);
    numInputLayers=numel(inputLayerIndices);


    if~obj.IsNetworkInitialized
        obj.setupAndResetNetwork(codegenInputSizes);
    end

    numLayers=coder.const(@feval,'getNumLayers',obj.DLCustomCoderNetwork);

    isProfilingEnabled=coder.const(@feval,'dlcoderfeature',"cnnProfiling");
    fileID=coder.internal.coderNetworkUtils.initializeProfilingFile(isProfilingEnabled,networkName,numLayers);
    if coder.const(isProfilingEnabled)
        onCleanup(@()coder.internal.coderNetworkUtils.closeProfilingFile(fileID));%#ok
    end

    outT=cell(1,numLayers);
    layerOutputsComputed=false(1,numLayers);


    [fusedOutputLayerIndices,fusedOutputLayerOffsetIndices]=coder.const(@feval,...
    'getFusedLayerIndices',obj.DLCustomCoderNetwork,outputLayerIndices);






    inputsTOffset=0;
    for iIn=1:numInputLayers
        inputLayerIdx=inputLayerIndices(iIn);

        layer=obj.getFusedLayer(inputLayerIdx,[],[]);

        outT{inputLayerIdx}=cell(1,layer.NumOutputs);

        numInputs=layer.NumInputs;
        inT=cell(1,numInputs);
        for iSource=1:numInputs
            inT{iSource}=inputsT{inputsTOffset+iSource};
        end

        outT{inputLayerIdx}=iInvokeLayerPredictAndUpdateCall(obj,inputLayerIdx,layer,inT,isProfilingEnabled,fileID);

        inputsTOffset=inputsTOffset+numInputs;
        layerOutputsComputed(inputLayerIdx)=true;
    end


    for iLayer=1:numLayers
        if~layerOutputsComputed(iLayer)



            layer=obj.getFusedLayer(iLayer,fusedOutputLayerIndices,fusedOutputLayerOffsetIndices);
            isQuantizedLayer=coder.const(isa(layer,'coder.internal.layer.quantized.Layer'));

            inputConnections=coder.const(@feval,'getLayerInputConnections',obj.DLCustomCoderNetwork,coder.const(iLayer));
            numInputs=numel(inputConnections)/2;
            inT=cell(1,numInputs);
            for iSource=1:numInputs
                srcLayer=inputConnections((iSource-1)*2+1);
                srcLayerPort=inputConnections((iSource-1)*2+2);
                inT{iSource}=obj.convertInputDataToProperType(isQuantizedLayer,...
                outT{srcLayer}{srcLayerPort});
            end

            outT{iLayer}=iInvokeLayerPredictAndUpdateCall(obj,iLayer,layer,inT,isProfilingEnabled,fileID);

            layerOutputsComputed(iLayer)=true;
        end
    end


    outputs=cell(1,numOutputLayers);
    for iOut=1:numOutputLayers
        outputs{iOut}=outT{fusedOutputLayerIndices(iOut)}{1};

    end

end

function output=iInvokeLayerPredictAndUpdateCall(obj,layerIdx,layer,inT,isProfilingEnabled,fileID)
    if coder.const(@feval,'isStatefulLayer',obj.DLCustomCoderNetwork,layerIdx)
        statefulIdx=coder.const(@feval,'getStatefulIdx',obj.DLCustomCoderNetwork,layerIdx);

        timer=coder.internal.coderNetworkUtils.startTimer(isProfilingEnabled);
        output=obj.invokePredictCall(layer,inT,obj.NetworkState{statefulIdx},...
        layer.NumOutputs+layer.NumStates);
        coder.internal.coderNetworkUtils.printElapsedTimeToFile(isProfilingEnabled,timer,fileID,layerIdx,layer.Name);





        coder.unroll
        for iState=1:layer.NumStates

            obj.NetworkState{statefulIdx}{iState}=output{layer.NumOutputs+iState}(:,:,end);
        end
    else
        states=[];

        timer=coder.internal.coderNetworkUtils.startTimer(isProfilingEnabled);
        output=obj.invokePredictCall(layer,inT,states,layer.NumOutputs);
        coder.internal.coderNetworkUtils.printElapsedTimeToFile(isProfilingEnabled,timer,fileID,layerIdx,layer.Name);
    end
end

