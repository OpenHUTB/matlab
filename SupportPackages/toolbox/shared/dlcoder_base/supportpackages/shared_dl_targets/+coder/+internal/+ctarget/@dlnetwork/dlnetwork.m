%#codegen


classdef(Sealed)dlnetwork<coder.internal.dlnetwork&coder.internal.ctarget.Network




    methods(Hidden=true)


        function obj=dlnetwork(matFile,variableName,varargin)
            coder.allowpcode('plain');


            obj@coder.internal.dlnetwork(matFile,variableName,varargin{:});
        end

    end

    methods(Access=protected)




        function callUpdateState(~)

            return;
        end


        function setup(~)

            return;
        end


        function callSetSize(~,~,~)

            return;
        end

        function setAnchor(~)

            return;
        end


        outputs=callPredict(obj,inputsT,outsizes,numOutputs);


        permutedData=permuteFeatureData(inputData);


        permutedData=permuteVectorSequenceData(obj,inputData,fmt)


        permutedData=permuteImageSequenceData(obj,dataInput,isDataOutput,dataFormat)


        inputDataT=transposeInputsBeforePredict(obj,dataInputs,inputHasTimeDim,isImageInput,inputFormats);


        outputDataT=transposeOutputsAfterPredict(obj,outputData,numOutputsRequested,outputFormats)
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
            name='dlnetwork';
        end

        function n=matlabCodegenSoftNontunableProperties(~)
            n={'TunableLayers'};
        end

        function n=matlabCodegenNontunableProperties(~)
            n={'TunableLayerIndices','IsLayerTunable'};
        end

    end
end
