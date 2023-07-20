%#codegen


classdef BiLSTMLayer<coder.internal.layer.RecurrentLayer




    properties(SetAccess=private)
StateActivationFcn
GateActivationFcn
ReturnLast
InputFormat
NumHiddenUnits
    end

    properties

ForwardInputGateWeights
ForwardInputStateWeights
ForwardRecurrentGateWeights
ForwardRecurrentStateWeights
ForwardGateBias
ForwardStateBias
BackwardInputGateWeights
BackwardInputStateWeights
BackwardRecurrentGateWeights
BackwardRecurrentStateWeights
BackwardGateBias
BackwardStateBias
    end

    methods

        function layer=BiLSTMLayer(name,numHiddenUnits,inputWeights,recurrentWeights,bias,...
            initCellState,initHiddenState,stateActivationFcn,gateActivationFcn,...
            outputMode,inputFormat)
            layer.Name=name;
            layer.NumHiddenUnits=numHiddenUnits;

            [layer.ForwardInputGateWeights,layer.ForwardInputStateWeights,...
            layer.ForwardRecurrentGateWeights,layer.ForwardRecurrentStateWeights,...
            layer.ForwardGateBias,layer.ForwardStateBias,layer.BackwardInputGateWeights,...
            layer.BackwardInputStateWeights,layer.BackwardRecurrentGateWeights,...
            layer.BackwardRecurrentStateWeights,layer.BackwardGateBias,...
            layer.BackwardStateBias]=...
            coder.internal.layer.BiLSTMLayer.iSplitWeights(inputWeights,...
            recurrentWeights,bias,numHiddenUnits);

            layer.StateActivationFcn=stateActivationFcn;
            layer.GateActivationFcn=gateActivationFcn;
            layer.ReturnLast=strcmp(outputMode,'last');

            layer.NumStates=2;
            layer.State{1}=initCellState;
            layer.State{2}=initHiddenState;
            layer.InputFormat=inputFormat;
        end

        function[Y,CS,HS]=predict(layer,X,cellState,hiddenState)
            coder.allowpcode('plain');

            inputFormat=layer.InputFormat;

            [fwdIpCellState,fwdIpHiddenState,bwdIpCellState,bwdIpHiddenState]=...
            coder.internal.layer.BiLSTMLayer.iSplitStates(cellState,hiddenState);


            [Yf,CfS,HfS]=coder.internal.layer.rnnUtils.lstmUtils.forward(layer,X,...
            layer.NumHiddenUnits,layer.ForwardInputGateWeights,...
            layer.ForwardInputStateWeights,layer.ForwardRecurrentGateWeights,...
            layer.ForwardRecurrentStateWeights,layer.ForwardGateBias,...
            layer.ForwardStateBias,fwdIpCellState,fwdIpHiddenState);





            N=coder.internal.layer.utils.getFormatSizeAndDimension(X,inputFormat,'B');
            flipDimension=iGetFlipDimension(X,inputFormat);

            Yb=coder.internal.layer.rnnUtils.lstmUtils.forward(layer,flip(X,flipDimension),...
            layer.NumHiddenUnits,layer.BackwardInputGateWeights,...
            layer.BackwardInputStateWeights,layer.BackwardRecurrentGateWeights,...
            layer.BackwardRecurrentStateWeights,layer.BackwardGateBias,...
            layer.BackwardStateBias,bwdIpCellState,bwdIpHiddenState);


            if layer.ReturnLast
                Y=cat(1,Yf,Yb);
            else
                Y=cat(1,Yf,flip(Yb,flipDimension));
            end






            initialBackwardCellState=layer.State{1}(1+layer.NumHiddenUnits:end,:);
            initialForwardHiddenState=layer.State{2}(1+layer.NumHiddenUnits:end,:);

            if coder.const(N>1)&&size(initialBackwardCellState,2)==1
                CbS=repmat(initialBackwardCellState,[1,N]);
            else
                CbS=initialBackwardCellState;
            end

            if coder.const(N>1)&&size(initialForwardHiddenState,2)==1
                HbS=repmat(initialForwardHiddenState,[1,N]);
            else
                HbS=initialForwardHiddenState;
            end

            CS=[CfS;CbS];
            HS=[HfS;HbS];

        end
    end

    methods(Static,Hidden)

        function[fwdInputGateWeights,fwdInputStateWeights,fwdRecurrentGateWeights,...
            fwdRecurrentStateWeights,fwdGateBias,fwdStateBias,bwdInputGateWeights,...
            bwdInputStateWeights,bwdRecurrentGateWeights,bwdRecurrentStateWeights,...
            bwdGateBias,bwdStateBias]=...
            iSplitWeights(inputWeights,recurrentWeights,bias,numHiddenUnits)












            [fwdInputWeights,bwdInputWeights]=...
            coder.internal.layer.BiLSTMLayer.iSplitAcrossFirstDimension(inputWeights);
            [fwdRecurrentWeights,bwdRecurrentWeights]=...
            coder.internal.layer.BiLSTMLayer.iSplitAcrossFirstDimension(recurrentWeights);
            [fwdBias,bwdBias]=coder.internal.layer.BiLSTMLayer.iSplitAcrossFirstDimension(bias);


            [fwdInputGateWeights,fwdInputStateWeights]=...
            coder.internal.layer.rnnUtils.lstmUtils.getGateAndStateWeights(...
            numHiddenUnits,fwdInputWeights);
            [fwdRecurrentGateWeights,fwdRecurrentStateWeights]=...
            coder.internal.layer.rnnUtils.lstmUtils.getGateAndStateWeights(...
            numHiddenUnits,fwdRecurrentWeights);
            [fwdGateBias,fwdStateBias]=...
            coder.internal.layer.rnnUtils.lstmUtils.getGateAndStateWeights(...
            numHiddenUnits,fwdBias);

            [bwdInputGateWeights,bwdInputStateWeights]=...
            coder.internal.layer.rnnUtils.lstmUtils.getGateAndStateWeights(...
            numHiddenUnits,bwdInputWeights);
            [bwdRecurrentGateWeights,bwdRecurrentStateWeights]=...
            coder.internal.layer.rnnUtils.lstmUtils.getGateAndStateWeights(...
            numHiddenUnits,bwdRecurrentWeights);
            [bwdGateBias,bwdStateBias]=...
            coder.internal.layer.rnnUtils.lstmUtils.getGateAndStateWeights(...
            numHiddenUnits,bwdBias);
        end

        function[c0f,y0f,c0b,y0b]=iSplitStates(c0,y0)
            coder.inline('always');

            [c0f,c0b]=coder.internal.layer.BiLSTMLayer.iSplitAcrossFirstDimension(c0);
            [y0f,y0b]=coder.internal.layer.BiLSTMLayer.iSplitAcrossFirstDimension(y0);
        end

        function[Zf,Zb]=iSplitAcrossFirstDimension(Z)
            coder.inline('always');

            H=0.5*size(Z,1);
            fInd=1:H;
            bInd=H+fInd;
            Zf=Z(fInd,:,:);
            Zb=Z(bInd,:,:);
        end

        function n=matlabCodegenNontunableProperties(~)
            n={'StateActivationFcn','GateActivationFcn','ReturnLast','InputFormat','NumHiddenUnits'};
        end
    end

end

function flipDimension=iGetFlipDimension(X,inputFormat)



%#codegen
    coder.internal.prefer_const(inputFormat)
    coder.inline('always');

    if coder.const(strcmp(inputFormat,'CB'))

        flipDimension=3;
    else

        isExpectedFormat=coder.const(strcmp(inputFormat,'CT'))||...
        coder.const(strcmp(inputFormat,'CBT'));
        assert(isExpectedFormat,'Expected input format to be ''CT'' or ''CBT''');
        [~,flipDimension]=coder.internal.layer.utils.getFormatSizeAndDimension(X,inputFormat,'T');
    end
end
