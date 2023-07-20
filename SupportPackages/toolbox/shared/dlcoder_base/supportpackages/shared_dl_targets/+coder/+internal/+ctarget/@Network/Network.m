%#codegen



classdef(Abstract)Network<handle





    properties(Access=protected)

DLCustomCoderNetwork
    end

    properties(Access=private)


NetworkState



TunableLayers



        IsNetworkInitialized=false;


TunableLayerIndices


IsLayerTunable
    end

    methods(Hidden=true)


        function obj=Network()
            coder.allowpcode('plain');
        end
    end

    methods(Access=private)


        validateFixedSizeSequenceLength(obj,layer,inputs);
    end

    methods(Sealed,Access=protected)


        obj=initializeNetwork(obj,dltNetwork,networkInfo,networkName,codegenInputSizes)


        obj=setDLCustomCoderNetwork(obj,dltNetwork,networkInfo,networkName);


        obj=initializeOrResetState(obj,codegenInputSizes);


        callResetNetworkState(obj,codegenInputSizes);


        obj=initializeLayers(obj);


        layer=getLayer(obj,layerIdx)


        layer=getFusedLayer(obj,layerIdx,activationLayerIndices,fusedLayerOffsetIndices)


        outputs=callActivation(obj,inputsT,activationLayerIndices,...
        portIndices,dltNetwork,networkInfo,networkName,codegenInputSizes,...
        inputLayerIndices);


        outputs=callPredictAndUpdateState(obj,inputsT,miniBatchSize,...
        dltNetwork,networkInfo,networkName,codegenInputSizes,inputLayerIndices,...
        outputLayerIndices,numOutputLayers);


        Z=invokePredictCall(obj,layer,X,states,numOutputElems);


        inputData=convertInputDataToProperType(obj,isQuantizedLayer,outputData);


        storedLayerIdx=getStoredLayerIndex(obj,layerIndex);
    end

    methods


        function setupNetwork(obj,codegenInputSizes)
            obj.initializeNetwork(codegenInputSizes);
            obj.IsNetworkInitialized=true;
        end

        function setupAndResetNetwork(obj,codegenInputSizes)
            setupNetwork(obj,codegenInputSizes);
            resetNetwork(obj);
        end

        function resetNetwork(obj)%#ok


        end
    end


    methods(Static)

        validateOutputAfterPredict(inputData,outputData,inputFormats,outputFormats,layer)
    end

    methods(Static,Hidden)


        function names=matlabCodegenOnceNames
            names={'IsNetworkInitialized','setupAndResetNetwork','setupNetwork',...
            'initializeNetwork','resetNetwork'};
        end
    end


end
