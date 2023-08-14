%#codegen


function[Yout,HSout]=gruForwardSingletonBatch(layer,X,numHiddenUnits,inputGateWeights,...
    inputStateWeights,recurrentGateWeights,recurrentStateWeights,inputGateBias,...
    inputStateBias,recurrentGateBias,recurrentStateBias,h0Unexpanded)































    coder.allowpcode('plain');

    coder.inline('never');


    N=1;
    S=size(X,2);







    coder.extrinsic('coder.internal.layer.rnnUtils.gruUtils.gruGateIndices');
    [rInd,zInd]=coder.const(@coder.internal.layer.rnnUtils.gruUtils.gruGateIndices,numHiddenUnits);



    if coder.const(layer.ReturnLast)
        h=coder.nullcopy(zeros(numHiddenUnits,N,1,'like',X));
    else
        h=coder.nullcopy(zeros(numHiddenUnits,N,S,'like',X));
    end

    stateActivationFunction=coder.const(coder.internal.layer.utils.getStateActivation(layer.StateActivationFcn));
    gateActivationFunction=coder.const(coder.internal.layer.utils.getGateActivation(layer.GateActivationFcn));



    if coder.const(strcmp(layer.ResetGateMode,'recurrent-bias-after-multiplication'))
        rz=coder.internal.layer.optimized.matMulAdd(inputGateWeights,X(:,1),...
        coder.internal.layer.optimized.matMulAdd(recurrentGateWeights,h0Unexpanded,...
        inputGateBias+recurrentGateBias),gateActivationFunction);
    else

        rz=coder.internal.layer.optimized.matMulAdd(inputGateWeights,X(:,1),...
        coder.internal.layer.optimized.matMulAdd(recurrentGateWeights,h0Unexpanded,inputGateBias),...
        gateActivationFunction);
    end

    r=rz(rInd,:);
    z=rz(zInd,:);


    if coder.const(strcmp(layer.ResetGateMode,'recurrent-bias-after-multiplication'))
        hs=coder.internal.layer.optimized.matMulAdd(inputStateWeights,X(:,1),...
        r.*(coder.internal.layer.optimized.matMulAdd(recurrentStateWeights,h0Unexpanded,recurrentStateBias))...
        +inputStateBias,stateActivationFunction);
    elseif coder.const(strcmp(layer.ResetGateMode,'after-multiplication'))
        hs=coder.internal.layer.optimized.matMulAdd(inputStateWeights,X(:,1),...
        r.*coder.internal.layer.optimized.matMul(recurrentStateWeights,h0Unexpanded)+inputStateBias,...
        stateActivationFunction);
    else

        hs=coder.internal.layer.optimized.matMulAdd(inputStateWeights,X(:,1),...
        coder.internal.layer.optimized.matMulAdd(recurrentStateWeights,(r.*h0Unexpanded),inputStateBias),...
        stateActivationFunction);
    end


    h(:,:,1)=(1-z).*hs+z.*h0Unexpanded;


    for tt=2:S

        if coder.const(layer.ReturnLast)
            hPrev=h(:,:,1);
        else
            hPrev=h(:,:,tt-1);
        end


        if coder.const(strcmp(layer.ResetGateMode,'recurrent-bias-after-multiplication'))
            rz=coder.internal.layer.optimized.matMulAdd(inputGateWeights,X(:,tt),...
            coder.internal.layer.optimized.matMulAdd(recurrentGateWeights,hPrev,...
            inputGateBias+recurrentGateBias),gateActivationFunction);
        else

            rz=coder.internal.layer.optimized.matMulAdd(inputGateWeights,X(:,tt),...
            coder.internal.layer.optimized.matMulAdd(recurrentGateWeights,hPrev,inputGateBias),...
            gateActivationFunction);
        end

        r=rz(rInd,:);
        z=rz(zInd,:);


        if coder.const(strcmp(layer.ResetGateMode,'recurrent-bias-after-multiplication'))
            hs=coder.internal.layer.optimized.matMulAdd(inputStateWeights,X(:,tt),...
            r.*(coder.internal.layer.optimized.matMulAdd(recurrentStateWeights,...
            hPrev,recurrentStateBias))+inputStateBias,stateActivationFunction);
        elseif coder.const(strcmp(layer.ResetGateMode,'after-multiplication'))
            hs=coder.internal.layer.optimized.matMulAdd(inputStateWeights,X(:,tt),...
            (r.*coder.internal.layer.optimized.matMul(recurrentStateWeights,hPrev)+inputStateBias),...
            stateActivationFunction);
        else

            hs=coder.internal.layer.optimized.matMulAdd(inputStateWeights,X(:,tt),...
            coder.internal.layer.optimized.matMulAdd(recurrentStateWeights,(r.*hPrev),inputStateBias),...
            stateActivationFunction);
        end


        if coder.const(layer.ReturnLast)
            h(:,:,1)=(1-z).*hs+z.*hPrev;
        else
            h(:,:,tt)=(1-z).*hs+z.*hPrev;
        end
    end

    HS=h(:,:,end);
    Y=h;


    [HSout,Yout]=coder.internal.layer.rnnUtils.prepareOutputDataForRnn(HS,Y,numHiddenUnits,layer.InputFormat);

end


