%#codegen


classdef GruLayer<coder.internal.layer.RecurrentLayer




    properties(SetAccess=private)
StateActivationFcn
GateActivationFcn
ResetGateMode
ReturnLast
InputFormat
NumHiddenUnits
    end

    properties

InputGateWeights
InputStateWeights
RecurrentGateWeights
RecurrentStateWeights
InputGateBias
InputStateBias
RecurrentGateBias
RecurrentStateBias
    end

    methods

        function layer=GruLayer(name,numHiddenUnits,inputWeights,recurrentWeights,bias,...
            initHiddenState,stateActivationFcn,gateActivationFcn,resetGateMode,...
            outputMode,inputFormat)
            layer.Name=name;
            layer.NumHiddenUnits=numHiddenUnits;

            layer.StateActivationFcn=stateActivationFcn;
            layer.GateActivationFcn=gateActivationFcn;
            layer.ResetGateMode=resetGateMode;

            layer.ReturnLast=strcmp(outputMode,'last');

            layer.NumStates=1;
            layer.State{1}=initHiddenState;
            layer.InputFormat=inputFormat;

            [layer.InputGateWeights,layer.InputStateWeights,layer.RecurrentGateWeights,...
            layer.RecurrentStateWeights,layer.InputGateBias,layer.InputStateBias,...
            layer.RecurrentGateBias,layer.RecurrentStateBias]=...
            coder.internal.layer.GruLayer.iSplitWeights(inputWeights,...
            recurrentWeights,bias,numHiddenUnits,resetGateMode);
        end

        function[Y,HS]=predict(layer,X,hiddenState)
            coder.allowpcode('plain');

            useMATLABBuiltInOperations=coder.const(coder.internal.coderNetworkUtils.isCustomBLASCallbackEnabled()||coder.internal.coderNetworkUtils.isMexCodeConfig());
            N=coder.internal.layer.utils.getFormatSizeAndDimension(X,layer.InputFormat,'B');
            if coder.const(coder.internal.coderNetworkUtils.canUseMultiThreading())&&~useMATLABBuiltInOperations

                [Y,HS]=coder.internal.layer.rnnUtils.gruUtils.gruForwardUsingExplicitLoops(...
                layer,X,layer.NumHiddenUnits,layer.InputGateWeights,...
                layer.InputStateWeights,layer.RecurrentGateWeights,...
                layer.RecurrentStateWeights,layer.InputGateBias,layer.InputStateBias,...
                layer.RecurrentGateBias,layer.RecurrentStateBias,hiddenState);
            else
                if coder.const(N==1)
                    [Y,HS]=coder.internal.layer.rnnUtils.gruUtils.gruForwardSingletonBatch(layer,...
                    coder.internal.layer.rnnUtils.prepareSingletonBatchDataForRnn(X,layer.InputFormat),...
                    layer.NumHiddenUnits,layer.InputGateWeights,layer.InputStateWeights,...
                    layer.RecurrentGateWeights,layer.RecurrentStateWeights,layer.InputGateBias,...
                    layer.InputStateBias,layer.RecurrentGateBias,layer.RecurrentStateBias,hiddenState);
                else
                    [Y,HS]=coder.internal.layer.rnnUtils.gruUtils.gruForwardNonSingletonBatch(...
                    layer,X,layer.NumHiddenUnits,layer.InputGateWeights,...
                    layer.InputStateWeights,layer.RecurrentGateWeights,...
                    layer.RecurrentStateWeights,layer.InputGateBias,layer.InputStateBias,...
                    layer.RecurrentGateBias,layer.RecurrentStateBias,hiddenState);
                end
            end

        end

    end

    methods(Static,Hidden)
        function n=matlabCodegenNontunableProperties(~)
            n={'StateActivationFcn','GateActivationFcn','ResetGateMode','ReturnLast',...
            'InputFormat','NumHiddenUnits'};
        end

        function[inputGateWeights,inputStateWeights,recurrentGateWeights,...
            recurrentStateWeights,inputGateBias,inputStateBias,recurrentGateBias,...
            recurrentStateBias]=...
            iSplitWeights(inputWeights,recurrentWeights,bias,numHiddenUnits,resetGateMode)












            [inputGateWeights,inputStateWeights]=...
            coder.internal.layer.rnnUtils.gruUtils.getGateAndStateWeights(...
            numHiddenUnits,inputWeights);

            [recurrentGateWeights,recurrentStateWeights]=...
            coder.internal.layer.rnnUtils.gruUtils.getGateAndStateWeights(...
            numHiddenUnits,recurrentWeights);

            [inputGateBias,inputStateBias,recurrentGateBias,...
            recurrentStateBias]=...
            coder.internal.layer.rnnUtils.gruUtils.getGateAndStateBias(numHiddenUnits,bias,...
            strcmp(resetGateMode,'recurrent-bias-after-multiplication'));

        end

    end

end