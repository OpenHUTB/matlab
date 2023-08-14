classdef SequenceInputCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.sequence_input_layer_comp';


        compKind='sequenceInputlayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.SequenceInputCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.SequenceInputCompBuilder.compKind;
        end

        function comp=convert(layer,converter,comp)

            batchIndex=4;
            comp.setBatchSize(converter.NetworkInfo.CodegenInputSizes{1}(batchIndex));


            inputNamesIdx=converter.NetworkInfo.InputLayerNameToInputNamesIdxMap(layer.Name);
            comp.setInputNamesIndex(int32(inputNamesIdx));


            layerInfo=converter.getLayerInfo(layer.Name);
            inputFormat=layerInfo.inputFormats{1};
            numSpatialDims=numel(strfind(inputFormat,'S'));


            assert((numSpatialDims==0)||(numSpatialDims==2));

            isImageInput=numSpatialDims==2;
            comp.setIsImageInput(isImageInput);
        end

        function validate(layer,validator)

            dltargets.internal.isValidSequenceInputDimensions(layer,validator);

            layerName=dltargets.internal.compbuilder.CodegenCompBuilder.getLayerName(layer,class(layer));
            unsupportedTargets={'arm-compute-mali'};
            if any(strcmpi(validator.getTargetLib(),unsupportedTargets))
                errorMessage=message('dlcoder_spkg:cnncodegen:unsupported_layer',layerName,validator.getTargetLib());
                validator.handleError(layer,errorMessage);
            end

            inputFormat=iGetInputFormat(validator,layer.Name);



            isImageSequence=count(inputFormat,'S')==2;


            if isImageSequence
                supportedSequenceImageTargets={'cudnn','arm-compute','mkldnn','onednn','tensorrt'};
                if~any(strcmpi(validator.getTargetLib(),supportedSequenceImageTargets))
                    errorMessage=message('dlcoder_spkg:cnncodegen:ImageSequenceInputNotSupported',validator.getTargetLib());
                    validator.handleError(layer,errorMessage);
                end
            end

            dltargets.internal.isValidInputNormalization(layer,validator);
            dltargets.internal.validateSplitComplexInputs(layer,validator);
        end

        function aStruct=toStruct(layer)

            aStruct=struct('Class',class(layer),'Name',layer.Name,'InputSize',layer.InputSize,...
            'Normalization',layer.Normalization,...
            'NormalizationDimension',layer.NormalizationDimension);
        end
    end
end

function inputFormat=iGetInputFormat(validator,layerName)
    layerInfo=validator.getLayerInfo(layerName);
    inputFormat=layerInfo.inputFormats;
    inputFormat=inputFormat{1};
end
