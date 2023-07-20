%#codegen

function[Y,CS,HS]=forward(layer,X,numHiddenUnits,inputGateWeights,...
    inputStateWeights,recurrentGateWeights,recurrentStateWeights,gateBias,stateBias,...
    c0Unexpanded,y0Unexpanded)




































    coder.allowpcode('plain');


    stateActivationFcn=coder.const(coder.internal.layer.utils.getStateActivation(layer.StateActivationFcn));
    gateActivationFcn=coder.const(coder.internal.layer.utils.getGateActivation(layer.GateActivationFcn));
    inputFormat=layer.InputFormat;








    [N,batchDim]=coder.internal.layer.utils.getFormatSizeAndDimension(X,inputFormat,'B');
    if coder.const(coder.internal.coderNetworkUtils.canUseMultiThreading()&&...
        ~coder.internal.coderNetworkUtils.isBlasEnabled())






        [CS,YT]=coder.internal.layer.rnnUtils.lstmUtils.forwardExplicitLoops(X,numHiddenUnits,...
        inputGateWeights,inputStateWeights,recurrentGateWeights,recurrentStateWeights,...
        gateBias,stateBias,c0Unexpanded,y0Unexpanded,stateActivationFcn,gateActivationFcn,...
        inputFormat);
    else
        if coder.const(N==1)
            [CS,YT]=coder.internal.layer.rnnUtils.lstmUtils.forwardMatrixMultiplySingletonBatch(...
            coder.internal.layer.rnnUtils.prepareSingletonBatchDataForRnn(X,inputFormat),numHiddenUnits,...
            inputGateWeights,inputStateWeights,recurrentGateWeights,recurrentStateWeights,...
            gateBias,stateBias,c0Unexpanded,y0Unexpanded,stateActivationFcn,gateActivationFcn,...
            inputFormat,layer.ReturnLast);
        else
            [CS,YT]=coder.internal.layer.rnnUtils.lstmUtils.forwardMatrixMultiplyNonSingletonBatch(...
            X,numHiddenUnits,inputGateWeights,inputStateWeights,recurrentGateWeights,...
            recurrentStateWeights,gateBias,stateBias,c0Unexpanded,y0Unexpanded,...
            stateActivationFcn,gateActivationFcn,inputFormat,layer.ReturnLast);
        end
    end




    if coder.const(isempty(batchDim))

        HS=YT(:,end);
        CS=CS(:,end);
    else
        HS=YT(:,:,end);
        CS=CS(:,:,end);
    end

    if coder.const(layer.ReturnLast)
        Y=HS;
    else
        Y=YT;
    end

end
