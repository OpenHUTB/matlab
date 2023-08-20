classdef DlnetworkMexAccelerationConfig<nnet.internal.cnn.coder.MexNetworkConfig

    properties(Access=private)

        InputSize(1,:)cell

OutputNames

NetworkVersion

StateOutputRequested
    end


    properties
LayerOutputIndices
LayerOutputPortIndices
    end


    methods

        function obj=DlnetworkMexAccelerationConfig(inputSize,precision,targetLib,layers,layerOutputIndices,layerOutputPortIndices,formats,version)
            outputNames=iGetExternalOutputNames(layers,layerOutputIndices,layerOutputPortIndices);
            constantInput=iGenerateConstantInputs(outputNames,formats);
            obj=obj@nnet.internal.cnn.coder.MexNetworkConfig(...
            targetLib,precision,numel(outputNames),constantInput);

            obj.InputSize=inputSize;
            obj.NetworkVersion=version;
            obj.LayerOutputIndices=layerOutputIndices;
            obj.LayerOutputPortIndices=layerOutputPortIndices;
            obj.OutputNames=outputNames;

            if obj.Precision~="single"
                error(message('nnet_cnn:dlAccel:UnsupportedPrecision'))
            end
        end
    end


    methods(Access=protected)

        function keyContent=getKeyContent(this)
            keyContent={this.InputSize;this.Precision;...
            this.TargetLib;this.OutputNames;this.NetworkVersion};
        end


        function inputArgs=getCodegenVariableInputArgs(this)
            numInputs=numel(this.InputSize);
            exampleInputs=cell(1,numInputs);
            for i=1:numInputs
                sz=this.InputSize{i};
                exampleInputs{i}=ones(sz,this.Precision,'gpuArray');
            end
            inputArgs=exampleInputs;
        end

        function[designFileName,designFilePath]=getDesignFileNameAndPath(this)
            designFilePath=getMexNetworkPrivateDirectoryPath(this);
            designFileName='dlnet_pred';
        end


        function fusedLayerFcn=getAssociatedFusedLayerFcn(~)
            fusedLayerFcn=@nnet.internal.cnn.coder.MexDlnetworkLayer;
        end


        function networkInputSizes=getInputSizesForValidation(this,network)
            networkInputSizes=iGetInputSizes(network);
            isMissingInputLayers=numel(networkInputSizes)~=numel(this.InputSize);
            if isMissingInputLayers
                error(message('nnet_cnn:dlAccel:NoInputLayerUnsupported'))
            end
        end
    end
end


function constInputs=iGenerateConstantInputs(outputNames,formats)
    constInputs={cellstr(outputNames),cellstr(formats)};
end


function outputNames=iGetExternalOutputNames(layers,layerIndices,layerOutputIndices)

    numOutputs=numel(layerIndices);
    outputNames=repmat("",1,numOutputs);
    for i=1:numOutputs
        currentLayer=layers{layerIndices(i)};
        outputNames(i)=string(currentLayer.Name)+"/"+string(currentLayer.OutputNames{layerOutputIndices(i)});
    end
end


function inputSize=iGetInputSizes(network)
    privateNet=network.getPrivateNetwork();
    inputLayers=privateNet.OriginalLayers(privateNet.InputLayerIdx(privateNet.InputLayerMask));
    numInputLayers=numel(inputLayers);
    inputSize=cell(1,numInputLayers);

    for i=1:numInputLayers
        currentLayer=inputLayers{i};
        switch(string(class(currentLayer)))
        case "nnet.internal.cnn.layer.SequenceInput"
            currentInputSize=currentLayer.InputSize;
            nDims=numel(currentInputSize);
            if nDims<3
                inputSize{i}=[ones(1,3-nDims),currentInputSize];
            else
                inputSize{i}=currentInputSize;
            end
        otherwise
            inputSize{i}=currentLayer.InputSize;
        end
    end
end
