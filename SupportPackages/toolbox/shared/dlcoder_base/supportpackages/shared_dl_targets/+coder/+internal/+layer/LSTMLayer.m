%#codegen


classdef LSTMLayer<coder.internal.layer.RecurrentLayer




    properties(SetAccess=private)
StateActivationFcn
GateActivationFcn
ReturnLast
InputFormat
NumHiddenUnits
    end

    properties

InputGateWeights
InputStateWeights
RecurrentGateWeights
RecurrentStateWeights
GateBias
StateBias
    end

    methods

        function layer=LSTMLayer(name,numHiddenUnits,inputWeights,recurrentWeights,...
            bias,initCellState,initHiddenState,...
            stateActivationFcn,gateActivationFcn,outputMode,inputFormat)
            layer.Name=name;
            layer.NumHiddenUnits=numHiddenUnits;

            layer.StateActivationFcn=stateActivationFcn;
            layer.GateActivationFcn=gateActivationFcn;
            layer.ReturnLast=strcmp(outputMode,'last');

            layer.NumStates=2;
            layer.State{1}=initCellState;
            layer.State{2}=initHiddenState;
            layer.InputFormat=inputFormat;

            [layer.InputGateWeights,layer.InputStateWeights,layer.RecurrentGateWeights,...
            layer.RecurrentStateWeights,layer.GateBias,layer.StateBias]=...
            coder.internal.layer.LSTMLayer.iSplitWeights(inputWeights,...
            recurrentWeights,bias,numHiddenUnits);

        end

        function[Y,CS,HS]=predict(layer,X,cellState,hiddenState)
            coder.allowpcode('plain');

            [Y,CS,HS]=coder.internal.layer.rnnUtils.lstmUtils.forward(layer,X,...
            layer.NumHiddenUnits,layer.InputGateWeights,layer.InputStateWeights,...
            layer.RecurrentGateWeights,layer.RecurrentStateWeights,...
            layer.GateBias,layer.StateBias,cellState,hiddenState);
        end

    end

    methods(Static,Hidden)

        function n=matlabCodegenNontunableProperties(~)
            n={'StateActivationFcn','GateActivationFcn','ReturnLast','InputFormat',...
            'NumHiddenUnits'};
        end

        function[inputGateWeights,inputStateWeights,recurrentGateWeights,...
            recurrentStateWeights,gateBias,stateBias]=...
            iSplitWeights(inputWeights,recurrentWeights,bias,numHiddenUnits)











            [inputGateWeights,inputStateWeights]=...
            coder.internal.layer.rnnUtils.lstmUtils.getGateAndStateWeights(...
            numHiddenUnits,inputWeights);

            [recurrentGateWeights,recurrentStateWeights]=...
            coder.internal.layer.rnnUtils.lstmUtils.getGateAndStateWeights(...
            numHiddenUnits,recurrentWeights);

            [gateBias,stateBias]=...
            coder.internal.layer.rnnUtils.lstmUtils.getGateAndStateWeights(...
            numHiddenUnits,bias);

        end
    end

end
