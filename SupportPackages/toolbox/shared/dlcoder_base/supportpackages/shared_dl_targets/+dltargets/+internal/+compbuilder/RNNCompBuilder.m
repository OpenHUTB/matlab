classdef(Abstract)RNNCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    methods(Static,Access=protected)
        function comp=setCommonRNNCompProperties(layer,~,comp)

            comp.setFeatureDimension(layer.InputSize);

            comp.setHiddenSize(layer.NumHiddenUnits);

            outputMode=strcmp(layer.OutputMode,'last');
            comp.setLastMode(outputMode);

            comp.setstateActivationFunction(layer.StateActivationFunction);

            comp.setgateActivationFunction(layer.GateActivationFunction);
        end

        function defaultStateFcn=hasDefaultStateFunction(layer)
            defaultStateFcn=strcmpi(layer.StateActivationFunction,'tanh');
        end

        function defaultGateFcn=hasDefaultGateFunction(layer)
            defaultGateFcn=strcmpi(layer.GateActivationFunction,'sigmoid');
        end

    end

    methods(Static,Access=public)

        function checkForMimoRNNLayer(layer,validator)
            if layer.HasStateInputs||layer.HasStateOutputs
                errorMessage=message('dlcoder_spkg:cnncodegen:UnsupportedMimoRnn',layer.Name,validator.getTargetLib());
                validator.handleError(layer,errorMessage);
            end
        end
    end
end

