function[CS,YT]=forwardMatrixMultiplyNonSingletonBatch(X,numHiddenUnits,inputGateWeights,...
    inputStateWeights,recurrentGateWeights,recurrentStateWeights,gateBias,stateBias,...
    c0Unexpanded,y0Unexpanded,stateActivationFcn,gateActivationFcn,inputFormat,returnLast)




%#codegen
    coder.allowpcode('plain');
    coder.inline('always');
    coder.internal.prefer_const(numHiddenUnits,inputFormat,returnLast);


    N=coder.internal.layer.utils.getFormatSizeAndDimension(X,inputFormat,'B');
    S=coder.internal.layer.utils.getFormatSizeAndDimension(X,inputFormat,'T');

    if coder.const(returnLast)
        YT=coder.nullcopy(zeros(numHiddenUnits,N,1,'like',X));
    else
        YT=coder.nullcopy(zeros(numHiddenUnits,N,S,'like',X));
    end

    CS=coder.nullcopy(zeros(numHiddenUnits,N,1,'like',X));


    ignoreStateIndices=true;
    [iInd,fInd,oInd]=coder.const(@feval,...
    'coder.internal.layer.rnnUtils.lstmUtils.computeGateAndStateIndices',numHiddenUnits,...
    ignoreStateIndices);


    if coder.const(size(y0Unexpanded,2)==1)
        y0=repmat(y0Unexpanded,1,N);
    else
        y0=y0Unexpanded;
    end

    if coder.const(size(c0Unexpanded,2)==1)
        c0=repmat(c0Unexpanded,1,N);
    else
        c0=c0Unexpanded;
    end




    gateValues=coder.internal.layer.optimized.matMulAdd(inputGateWeights,X(:,:,1),...
    coder.internal.layer.optimized.matMulAdd(recurrentGateWeights,y0,gateBias),gateActivationFcn);
    stateValues=coder.internal.layer.optimized.matMulAdd(inputStateWeights,X(:,:,1),...
    coder.internal.layer.optimized.matMulAdd(recurrentStateWeights,y0,stateBias),stateActivationFcn);


    CS(:,:,1)=stateValues.*gateValues(iInd,:)+gateValues(fInd,:).*c0;

    YT(:,:,1)=stateActivationFcn(CS(:,:,1)).*gateValues(oInd,:);



    for tt=2:S


        if coder.const(returnLast)
            yPrev=YT(:,:,1);
        else
            yPrev=YT(:,:,tt-1);
        end

        gateValues=coder.internal.layer.optimized.matMulAdd(inputGateWeights,X(:,:,tt),...
        coder.internal.layer.optimized.matMulAdd(recurrentGateWeights,yPrev,gateBias),...
        gateActivationFcn);
        stateValues=coder.internal.layer.optimized.matMulAdd(inputStateWeights,X(:,:,tt),...
        coder.internal.layer.optimized.matMulAdd(recurrentStateWeights,yPrev,stateBias),...
        stateActivationFcn);


        CS(:,:,1)=stateValues.*gateValues(iInd,:,1)+gateValues(fInd,:).*CS;


        if coder.const(returnLast)
            YT(:,:,1)=stateActivationFcn(CS).*gateValues(oInd,:);
        else
            YT(:,:,tt)=stateActivationFcn(CS).*gateValues(oInd,:);
        end
    end

end
