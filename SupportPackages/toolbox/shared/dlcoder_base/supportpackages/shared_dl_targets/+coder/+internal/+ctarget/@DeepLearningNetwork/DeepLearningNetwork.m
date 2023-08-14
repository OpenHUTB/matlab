%#codegen


classdef(Sealed)DeepLearningNetwork<coder.internal.DeepLearningNetwork&coder.internal.ctarget.Network





    methods(Hidden=true)


        function obj=DeepLearningNetwork(matFile,variableName,varargin)
            coder.allowpcode('plain');


            obj@coder.internal.DeepLearningNetwork(matFile,variableName,varargin{:});
        end

    end

    methods(Access=protected)




        function callUpdateState(~)

            return;
        end


        function setup(~)

            return;
        end


        function callSetSize(~,~)

            return;
        end

        function setAnchor(~)

            return;
        end


        function callResetState(obj)


            obj.callResetNetworkState(obj.CodegenInputSizes);
        end




        out=callPredict(obj,inputsT,outsizes,numOutputs);


        out=callActivationsForCNN(obj,inputsT,outsizes,numOutputs);


        outMiniBatch=callActivationsForRNN(obj,miniBatch,layerIdx,portIdx,...
        outputFeatureSize,miniBatchSequenceLengthValue,isSequenceOutput,isSequenceFolded,...
        isCellInput,isImageInput,isImageOutput);


        outputData=predictForRNN(obj,in,callerFunction,varargin);



        [miniBatch,sampleSequenceLengths,miniBatchSequenceLengthValue]=prepareMinibatchForRNN(obj,...
        indata,inputSize,miniBatchSize,sequenceLengthMode,sequencePaddingValue,...
        sequencePaddingDirection,isCellInput,isImageInput,miniBatchIdx,numMiniBatches,...
        remainder,callerFunction);


        reshapedSample=prepareRNNCellOutput(obj,outMiniBatch,outputFeatureSize,miniBatchSequenceLengths,...
        sequenceLength,sequencePaddingDirection,sampleIdx,isImageOutput);


        outSample=prepareImageOutSampleForActivations(obj,outMiniBatch,sampleIdx,isCellInput);
        outSample=prepareVectorOutSampleForActivations(obj,outMiniBatch,sampleIdx,isCellInput);


        outSample=prepareVectorData(obj,inSample);
    end

    methods(Access=private)


        function checkNetworkIsSetUpForPredictCall(obj)


            codegenInputSizes=coder.internal.getprop_if_defined(obj.CodegenInputSizes);
            networkInfo=coder.internal.getprop_if_defined(obj.NetworkInfo);

            coder.internal.assert(~isempty(codegenInputSizes),'dlcoder_spkg:cnncodegen:DLCoderInternalError');
            coder.internal.assert(~isempty(networkInfo),'dlcoder_spkg:cnncodegen:DLCoderInternalError');
        end
    end

    methods(Static,Hidden)

        function n=matlabCodegenMxArrayNontunableProperties(~)
            n={'DLCustomCoderNetwork'};
        end

        function name=matlabCodegenUserReadableName(~)
            name='DeepLearningNetwork';
        end

        function n=matlabCodegenSoftNontunableProperties(~)
            n={'TunableLayers'};
        end

        function n=matlabCodegenNontunableProperties(~)
            n={'TunableLayerIndices','IsLayerTunable'};
        end

    end
end
