classdef SSDMergeLayer<nnet.layer.Layer




%#codegen

    properties(SetAccess=private)
NumChannels
    end

    methods
        function layer=SSDMergeLayer(name,numChannels,numInputs)
            layer.Name=name;
            layer.NumChannels=numChannels;
            layer.NumInputs=numInputs;
            layer.OutputNames="out";
        end

        function Z=predict(layer,varargin)
            coder.allowpcode('plain');

            numInputs=layer.NumInputs;
            numChannels=layer.NumChannels;

            [numAnchorBoxesForAllFeatureMaps,batchSize,numAnchorBoxesPerFeatureMap]=...
            coder.const(@coder.internal.layer.ssdMergeUtils.computeSSDLayerParameters,numInputs,numChannels,varargin{:});

            Z=coder.internal.layer.ssdMergeUtils.ssdMergeOperation(numInputs,...
            numChannels,numAnchorBoxesForAllFeatureMaps,batchSize,...
            numAnchorBoxesPerFeatureMap,varargin{:});
        end
    end

    methods(Static,Hidden)
        function n=matlabCodegenNontunableProperties(~)
            n={'NumChannels'};
        end
    end
end
