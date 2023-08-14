classdef AdditionCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.addition_layer_comp';


        compKind='additionlayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.AdditionCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.AdditionCompBuilder.compKind;
        end

        function validate(layer,validator)

            unsupportedTargets={'cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);

            layerInfo=validator.getLayerInfo(layer.Name);


            if~dltargets.internal.compbuilder.AdditionCompBuilder.areDimsCompatible(...
                layerInfo.inputSizes)
                errorMessage=message('dlcoder_spkg:ValidateNetwork:AddLayerDimsMismatch',layer.Name);
                validator.handleError(layer,errorMessage);
            end
        end
    end

    methods(Static,Access=private)
        function isValid=areDimsCompatible(layerInputSizes)





            inputSize_1=layerInputSizes{1};
            isValid=true;
            for i=2:numel(layerInputSizes)

                inputSize_i=layerInputSizes{i};
                if~isequal(inputSize_1,inputSize_i)
                    isValid=false;
                    return;
                end

            end

        end
    end
end
