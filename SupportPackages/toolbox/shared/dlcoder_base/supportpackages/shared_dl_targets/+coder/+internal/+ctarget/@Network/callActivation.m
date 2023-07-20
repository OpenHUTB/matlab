





















%#codegen



function outputs=callActivation(obj,inputsT,activationLayerIndices,portIndices,...
    dltNetwork,networkInfo,networkName,codegenInputSizes,~)



    if~coder.target('MATLAB')

        eml_allow_mx_inputs;
    end

    coder.allowpcode('plain');
    coder.inline('always');
    coder.internal.prefer_const(activationLayerIndices,portIndices,dltNetwork,networkInfo,...
    networkName,codegenInputSizes);


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


    [fusedActivationLayerIndices,fusedLayerOffsetIndices]=coder.const(@feval,'getFusedLayerIndices',...
    obj.DLCustomCoderNetwork,activationLayerIndices);

    numOutputs=numel(activationLayerIndices);
    coder.internal.assert(numel(portIndices)==numOutputs,'dlcoder_spkg:cnncodegen:IncorrectNumPorts');

    isActivationLayerFused=coder.const(@feval,'hasFusedActivationLayers',obj.DLCustomCoderNetwork,...
    activationLayerIndices);

    activationNeedReshapeBool=coder.const(@feval,'checkIfActivationsNeedReshape',obj.DLCustomCoderNetwork,...
    fusedActivationLayerIndices);

    [~,activationLayerOutputFormat]=coder.const(@feval,'getLayerIOFormats',...
    obj.DLCustomCoderNetwork,fusedActivationLayerIndices,networkInfo);

    batchSize=coder.const(@feval,'getBatchSize',networkInfo);

    if coder.const(~isActivationLayerFused)

        outputs=iGetActivations(obj,inputsT,fusedActivationLayerIndices,fusedLayerOffsetIndices,...
        portIndices,inputLayerIndices,numInputLayers,numLayers,isProfilingEnabled,fileID,...
        activationLayerOutputFormat,batchSize,activationNeedReshapeBool);
    else

        outputs=cell(1,numOutputs);
        for idxActivations=1:numOutputs
            currentLayerActivation=iGetActivations(obj,inputsT,fusedActivationLayerIndices(idxActivations),...
            fusedLayerOffsetIndices(idxActivations),portIndices(idxActivations),inputLayerIndices,...
            numInputLayers,numLayers,isProfilingEnabled,fileID,...
            {activationLayerOutputFormat{idxActivations}},batchSize,activationNeedReshapeBool(idxActivations));
            outputs{idxActivations}=currentLayerActivation{:};
        end
    end

end


function outputs=iGetActivations(obj,inputsT,fusedActivationLayerIndices,...
    fusedLayerOffsetIndices,portIndices,inputLayerIndices,numInputLayers,...
    numLayers,insertProfilingHooks,fileID,activationLayerOutputFormat,...
    batchSize,activationNeedReshapeBool)



    numOutputs=numel(fusedActivationLayerIndices);

    numOutputsComputed=0;

    outT=cell(1,numLayers);

    layerOutputsComputed=false(1,numLayers);








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

        outT{inputLayerIdx}=iInvokeLayerPredictCall(obj,inputLayerIdx,layer,inT,insertProfilingHooks,fileID);

        inputsTOffset=inputsTOffset+numInputs;
        layerOutputsComputed(inputLayerIdx)=true;
    end


    coder.unroll();
    for iLayer=1:numLayers
        if~layerOutputsComputed(iLayer)



            layer=obj.getFusedLayer(iLayer,fusedActivationLayerIndices,fusedLayerOffsetIndices);
            isQuantizedLayer=coder.const(isa(layer,'coder.internal.layer.quantized.Layer'));


            inputConnections=coder.const(@feval,'getLayerInputConnections',...
            obj.DLCustomCoderNetwork,coder.const(iLayer));
            numInputs=numel(inputConnections)/2;

            srcLayers=inputConnections(((1:numInputs)-1)*2+1);
            srcLayerPorts=inputConnections(((1:numInputs)-1)*2+2);





            inT=iConvertAllInputDataToProperType(obj,isQuantizedLayer,srcLayerPorts,outT{srcLayers});





            outT{iLayer}=iInvokeLayerPredictCall(obj,iLayer,layer,inT,insertProfilingHooks,fileID);

            layerOutputsComputed(iLayer)=true;
        end



        numOutputsComputed=iNumRequiredOutputsComputed(numOutputs,numOutputsComputed,fusedActivationLayerIndices,iLayer);
        if numOutputsComputed==numOutputs
            break;
        end
    end


    outputs=cell(1,numOutputs);
    for iOut=1:numOutputs
        if coder.const(activationNeedReshapeBool(iOut))

            outputs{iOut}=coder.internal.layer.foldingUnfoldingUtils.unfoldingOperation(...
            outT{fusedActivationLayerIndices(iOut)}{portIndices(iOut)},...
            activationLayerOutputFormat{iOut}{portIndices(iOut)},...
            [activationLayerOutputFormat{iOut}{portIndices(iOut)},'T'],batchSize);
        else
            outputs{iOut}=outT{fusedActivationLayerIndices(iOut)}{portIndices(iOut)};
        end
    end

end

function output=iInvokeLayerPredictCall(obj,layerIdx,layer,inT,insertProfilingHooks,fileID)
    coder.inline('always');
    timer=coder.internal.coderNetworkUtils.startTimer(insertProfilingHooks);
    if~coder.const(@feval,'isStatefulLayer',obj.DLCustomCoderNetwork,layerIdx)
        states=[];
        output=obj.invokePredictCall(layer,inT,states,layer.NumOutputs);
    else
        statefulIdx=coder.const(@feval,'getStatefulIdx',obj.DLCustomCoderNetwork,layerIdx);
        output=obj.invokePredictCall(layer,inT,obj.NetworkState{statefulIdx},layer.NumOutputs);
    end
    coder.internal.coderNetworkUtils.printElapsedTimeToFile(insertProfilingHooks,timer,fileID,...
    layerIdx,layer.Name);

end












function inT=iConvertAllInputDataToProperType(obj,isQuantizedLayer,srcLayerPorts,varargin)

    coder.inline("always");
    coder.internal.prefer_const(isQuantizedLayer,srcLayerPorts);

    numInT=coder.const(numel(srcLayerPorts));

    narginchk(3,3+numInT);



    inT=cell(1,numInT);

    for iSource=coder.unroll(1:numInT)
        inT{iSource}=obj.convertInputDataToProperType(isQuantizedLayer,...
        varargin{iSource}{srcLayerPorts(iSource)});
    end
end














function numOutputsComputed=iNumRequiredOutputsComputed(numOutputs,currentNumOutputs,fusedActivationLayerIndices,currentLayer)
    coder.inline("always");
    coder.internal.prefer_const(numOutputs,fusedActivationLayerIndices,currentLayer);
    numOutputsComputed=currentNumOutputs;

    for iOut=coder.unroll(1:numOutputs)
        if(currentLayer==fusedActivationLayerIndices(iOut))
            numOutputsComputed=numOutputsComputed+1;
        end
    end

end
