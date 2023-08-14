%#codegen

classdef LSTMProjectedLayer<coder.internal.layer.RecurrentLayer&nnet.layer.Formattable


    properties(SetAccess=private)
StateActivationFunction
GateActivationFunction
ReturnLast
InputSize
NumHiddenUnits
InputProjectorSize
OutputProjectorSize
    end

    properties
InputGateWeights
InputStateWeights
RecurrentGateWeights
RecurrentStateWeights
GateBias
StateBias
InputProjector
OutputProjector
    end

    methods
        function layer=LSTMProjectedLayer(name,numHiddenUnits,inputSize,...
            outputProjectorSize,inputProjectorSize,...
            inputWeights,recurrentWeights,...
            bias,inputProjector,outputProjector,initCellState,initHiddenState,...
            stateActivationFcn,gateActivationFcn,outputMode)

            layer.Name=name;
            layer.NumHiddenUnits=numHiddenUnits;
            layer.OutputProjectorSize=outputProjectorSize;
            layer.InputProjectorSize=inputProjectorSize;

            layer.StateActivationFunction=stateActivationFcn;
            layer.GateActivationFunction=gateActivationFcn;
            layer.ReturnLast=strcmp(outputMode,'last');

            layer.NumStates=2;
            layer.State{1}=initCellState;
            layer.State{2}=initHiddenState;
            layer.InputSize=inputSize;

            layer.InputProjector=inputProjector';
            layer.OutputProjector=outputProjector';


            [layer.InputGateWeights,layer.InputStateWeights]=...
            coder.internal.layer.rnnUtils.lstmUtils.getGateAndStateWeights(...
            numHiddenUnits,inputWeights);

            [layer.RecurrentGateWeights,...
            layer.RecurrentStateWeights]=...
            coder.internal.layer.rnnUtils.lstmUtils.getGateAndStateWeights(...
            numHiddenUnits,recurrentWeights);

            [layer.GateBias,layer.StateBias]=...
            coder.internal.layer.rnnUtils.lstmUtils.getGateAndStateWeights(...
            numHiddenUnits,bias);
        end

        function[Y,CS,HS]=predict(layer,X,cellState,hiddenState)
            coder.allowpcode('plain');


            [Z,formatAfterFlattening]=iFlattenSpatialDimOfRecurrentInput(X);

            [Y,CS,HS]=nnet.internal.cnn.coder.layer.utils.rnnUtils.lstmProjectedUtils.forward(...
            extractdata(Z),layer.NumHiddenUnits,layer.OutputProjectorSize,...
            layer.InputSize,layer.InputProjectorSize,...
            layer.InputGateWeights,layer.InputStateWeights,layer.RecurrentGateWeights,...
            layer.RecurrentStateWeights,layer.GateBias,layer.StateBias,...
            layer.InputProjector,layer.OutputProjector,...
            coder.const(coder.internal.layer.utils.getStateActivation(layer.StateActivationFunction)),...
            coder.const(coder.internal.layer.utils.getGateActivation(layer.GateActivationFunction)),...
            cellState,hiddenState,...
            formatAfterFlattening,layer.ReturnLast);


            outputFormat=iPrepareOutputFormat(layer.ReturnLast,X);


            Y=dlarray(Y,outputFormat);
        end
    end

    methods(Static,Hidden)

        function n=matlabCodegenNontunableProperties(~)
            n={'StateActivationFunction','GateActivationFunction','ReturnLast','InputSize',...
            'NumHiddenUnits','InputProjectorSize','OutputProjectorSize'};
        end

        function[inputWeights,recurrentWeights,bias]=recombineWeights(...
            inputGateWeights,inputStateWeights,...
            recurrentGateWeights,recurrentStateWeights,...
            gateBias,stateBias,numHiddenUnits)


            inputWeights=[inputGateWeights(1:2*numHiddenUnits,:);inputStateWeights;inputGateWeights(2*numHiddenUnits+1:3*numHiddenUnits,:)];
            recurrentWeights=[recurrentGateWeights(1:2*numHiddenUnits,:);recurrentStateWeights;recurrentGateWeights(2*numHiddenUnits+1:3*numHiddenUnits,:)];
            bias=[gateBias(1:2*numHiddenUnits,:);stateBias;gateBias(2*numHiddenUnits+1:3*numHiddenUnits,:)];
        end

        function cgObj=matlabCodegenToRedirected(mlObj)
            cgObj=nnet.internal.cnn.coder.layer.LSTMProjectedLayer(mlObj.Name,...
            mlObj.NumHiddenUnits,mlObj.InputSize,...
            mlObj.OutputProjectorSize,mlObj.InputProjectorSize,...
            mlObj.InputWeights,mlObj.RecurrentWeights,mlObj.Bias,...
            mlObj.InputProjector,mlObj.OutputProjector,...
            mlObj.CellState,mlObj.HiddenState,...
            mlObj.StateActivationFunction,mlObj.GateActivationFunction,...
            mlObj.OutputMode);
        end

        function mlObj=matlabCodegenFromRedirected(cgObj)
            [inputWeights,recurrentWeights,bias]=nnet.internal.cnn.coder.layer.LSTMProjectedLayer.recombineWeights(...
            cgObj.InputGateWeights,cgObj.InputStateWeights,...
            cgObj.RecurrentGateWeights,cgObj.RecurrentStateWeights,...
            cgObj.GateBias,cgObj.StateBias,cgObj.NumHiddenUnits);

            if cgObj.ReturnLast
                outputMode="last";
            else
                outputMode="sequence";
            end

            mlObj=lstmProjectedLayer(cgObj.NumHiddenUnits,...
            cgObj.OutputProjectorSize,cgObj.InputProjectorSize,...
            "Name",cgObj.Name,...
            "InputWeights",inputWeights,"RecurrentWeights",recurrentWeights,...
            "Bias",bias,"InputProjector",cgObj.InputProjector',"OutputProjector",cgObj.OutputProjector',...
            "CellState",cgObj.State{1},"HiddenState",cgObj.State{2},...
            "StateActivationFunction",cgObj.StateActivationFunction,...
            "GateActivationFunction",cgObj.GateActivationFunction,...
            "OutputMode",outputMode);
        end
    end

end

function[dlY,formatAfterFlattening]=iFlattenSpatialDimOfRecurrentInput(dlX)


    cIdx=finddim(dlX,'C');
    inputFormat=dims(dlX);
    formatAfterFlattening=inputFormat(cIdx:end);

    if coder.const(~isempty(finddim(dlX,'S')))


        sz=size(dlX);
        flatChannels=prod(sz(1:cIdx));
        bIdx=finddim(dlX,'B');
        tIdx=finddim(dlX,'T');
        numDims=coder.const(numel([cIdx,bIdx,tIdx]));
        cellArraySz=cell(1,numDims);
        cellArraySz{1}=coder.const(flatChannels);
        if coder.const(~isempty(bIdx))

            cellArraySz{2}=coder.const(size(dlX,bIdx));
            if coder.const(~isempty(tIdx))

                cellArraySz{3}=size(dlX,tIdx);
            end
        else

            cellArraySz{2}=size(dlX,tIdx);
        end
        dlY=reshape(dlX,cellArraySz{:});
    else
        dlY=dlX;
    end
end

function outputFormat=iPrepareOutputFormat(returnLast,X)

    if coder.const(returnLast)

        if coder.const(isempty(finddim(X,'B')))
            outputFormat='CU';
        else
            outputFormat='CB';
        end
    else

        if coder.const(isempty(finddim(X,'B')))
            outputFormat='CT';
        elseif coder.const(isempty(finddim(X,'T')))
            outputFormat='CB';
        else
            outputFormat='CBT';
        end
    end
end