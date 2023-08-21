classdef DAGNetworkMexAccelerationConfig<nnet.internal.cnn.coder.MexNetworkConfig

    properties(SetAccess=private)

        IsCallingPredict(1,1)logical

MiniBatchSize
    end


    properties(Access=private)

        ActivationLayerName=[]

        HasMultipleInputs(1,1)logical

        InputSize(1,:)cell

NetworkInfo
    end


    methods

        function obj=DAGNetworkMexAccelerationConfig(inputSize,precision,miniBatchSize,targetLib,activationLayerName,netInfo)
            isCallingPredict=isempty(activationLayerName);
            if isCallingPredict
                numOutputs=numel(netInfo.OutputSizes);
            else
                numOutputs=1;
            end
            constInputs=iGenerateConstantInputs(isCallingPredict,numOutputs,activationLayerName,miniBatchSize);
            obj=obj@nnet.internal.cnn.coder.MexNetworkConfig(...
            targetLib,precision,numOutputs,constInputs);

            obj.InputSize=inputSize;
            obj.MiniBatchSize=miniBatchSize;
            obj.ActivationLayerName=activationLayerName;
            obj.HasMultipleInputs=numel(inputSize)>1;
            obj.NetworkInfo=netInfo;
            obj.IsCallingPredict=isCallingPredict;

            if any(obj.NetworkInfo.HasSequenceInput)
                error(message('nnet_cnn:dlAccel:SequenceInputLayerUnsupported'));
            end
            if obj.NetworkInfo.IsFeatureInput
                error(message('nnet_cnn:dlAccel:FeatureInputLayerNotSupported'));
            end
        end
    end


    methods(Access=protected)
        function keyContent=getKeyContent(this)
            keyContent={this.InputSize;this.Precision;this.MiniBatchSize;...
            this.TargetLib;this.ActivationLayerName};
        end


        function inputArgs=getCodegenVariableInputArgs(this)

            if this.HasMultipleInputs

                dataInputs={};
                for i=1:numel(this.InputSize)
                    currentInput=zeros([this.InputSize{i},this.MiniBatchSize],this.Precision);
                    dataInputs=[dataInputs,{currentInput}];%#ok<AGROW>
                end
                inputArgs={dataInputs};
            else
                inputArgs={gpuArray(zeros([this.InputSize{1},this.MiniBatchSize],this.Precision))};
            end
        end

        function[designFileName,designFilePath]=getDesignFileNameAndPath(this)
            designFilePath=getMexNetworkPrivateDirectoryPath(this);

            if this.IsCallingPredict
                if this.HasMultipleInputs
                    designFileName='dagnet_pred';
                else
                    designFileName='dagnet_pred_si';
                end
            else
                if this.HasMultipleInputs
                    designFileName='dagnet_act';
                else
                    designFileName='dagnet_act_si';
                end
            end
        end


        function fusedLayerFcn=getAssociatedFusedLayerFcn(~)
            fusedLayerFcn=@nnet.internal.cnn.coder.MexDAGNetworkLayer;
        end


        function inputSizes=getInputSizesForValidation(this,network)
            iAssertHasOnlySupportedInputLayers(network);
            inputSizes=this.NetworkInfo.InputSizes;
        end
    end
end


function constInputs=iGenerateConstantInputs(isCallingPredict,numOutputs,activationLayerName,miniBatchSize)

    constInputs={miniBatchSize};

    if~isCallingPredict

        constInputs=[constInputs,{activationLayerName}];
    end
end


function iAssertHasOnlySupportedInputLayers(network)
    internalNet=network.getInternalDAGNetwork();
    layers=internalNet.Layers;
    numLayers=numel(layers);
    for i=1:numLayers
        layer=layers{i};
        if isa(layer,"nnet.internal.cnn.layer.InputLayer")&&~isa(layer,"nnet.internal.cnn.layer.ImageInput")
            error(message("nnet_cnn:dlAccel:InputLayerNotSupported"))
        end
    end
end
