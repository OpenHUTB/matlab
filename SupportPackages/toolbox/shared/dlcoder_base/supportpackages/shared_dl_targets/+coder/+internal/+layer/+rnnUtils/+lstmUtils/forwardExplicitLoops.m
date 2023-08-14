function[CSout,YTout]=forwardExplicitLoops(X,numHiddenUnits,inputGateWeights,...
    inputStateWeights,recurrentGateWeights,recurrentStateWeights,gateBias,stateBias,c0,y0,...
    stateActivationFcn,gateActivationFcn,inputFormat)





%#codegen
    coder.allowpcode('plain');
    coder.inline('always');
    coder.internal.prefer_const(numHiddenUnits,inputFormat)


    N=coder.internal.layer.utils.getFormatSizeAndDimension(X,inputFormat,'B');
    S=coder.internal.layer.utils.getFormatSizeAndDimension(X,inputFormat,'T');






    isStateBatchExpanded=size(c0,2)>1;

    featureDims=coder.const(size(inputGateWeights,2));
    singleGateOpSize=coder.const(numHiddenUnits);
    numGates=4;
    allGatesOpSizePerBatch=coder.const(singleGateOpSize*numGates);


    G=zeros(allGatesOpSizePerBatch,N,S,'like',X);
    YT=coder.nullcopy(zeros(numHiddenUnits,N,S,'like',X));
    CS=coder.nullcopy(zeros(numHiddenUnits,N,S,'like',X));








    coder.internal.treatAsParfor();
    coder.internal.parallelRelax();
    for i=1:singleGateOpSize
        for tt=1:S
            for j=1:N
                for k=1:featureDims
                    tmpInput=coder.internal.layer.rnnUtils.getElementForExplicitLoopRnn(X,k,j,tt,inputFormat);
                    G(i,j,tt)=G(i,j,tt)+inputGateWeights(i,k)*tmpInput;
                    G(i+singleGateOpSize,j,tt)=G(i+singleGateOpSize,j,tt)+inputGateWeights(i+singleGateOpSize,k)*tmpInput;
                    G(i+singleGateOpSize*2,j,tt)=G(i+singleGateOpSize*2,j,tt)+inputStateWeights(i,k)*tmpInput;
                    G(i+singleGateOpSize*3,j,tt)=G(i+singleGateOpSize*3,j,tt)+inputGateWeights(i+singleGateOpSize*2,k)*tmpInput;
                end
            end
        end
    end


    if coder.const(N==1)
        coder.internal.treatAsParfor();
        coder.internal.parallelRelax();
        for i=1:singleGateOpSize
            for p=1:numHiddenUnits
                tmpHiddenState=y0(p);
                G(i,1,1)=G(i,1,1)+recurrentGateWeights(i,p)*tmpHiddenState;
                G(i+singleGateOpSize,1,1)=G(i+singleGateOpSize,1,1)+recurrentGateWeights(i+singleGateOpSize,p)*tmpHiddenState;
                G(i+singleGateOpSize*2,1,1)=G(i+singleGateOpSize*2,1,1)+recurrentStateWeights(i,p)*tmpHiddenState;
                G(i+singleGateOpSize*3,1,1)=G(i+singleGateOpSize*3,1,1)+recurrentGateWeights(i+singleGateOpSize*2,p)*tmpHiddenState;
            end
            G(i,1,1)=G(i,1,1)+gateBias(i);
            G(i+singleGateOpSize,1,1)=G(i+singleGateOpSize,1,1)+gateBias(i+singleGateOpSize);
            G(i+singleGateOpSize*2,1,1)=G(i+singleGateOpSize*2,1,1)+stateBias(i);
            G(i+singleGateOpSize*3,1,1)=G(i+singleGateOpSize*3,1,1)+gateBias(i+singleGateOpSize*2);
        end
    else
        if~isStateBatchExpanded
            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for i=1:singleGateOpSize
                for j=1:N
                    for p=1:numHiddenUnits
                        tmpHiddenState=y0(p);
                        G(i,j,1)=G(i,j,1)+recurrentGateWeights(i,p)*tmpHiddenState;
                        G(i+singleGateOpSize,j,1)=G(i+singleGateOpSize,j,1)+recurrentGateWeights(i+singleGateOpSize,p)*tmpHiddenState;
                        G(i+singleGateOpSize*2,j,1)=G(i+singleGateOpSize*2,j,1)+recurrentStateWeights(i,p)*tmpHiddenState;
                        G(i+singleGateOpSize*3,j,1)=G(i+singleGateOpSize*3,j,1)+recurrentGateWeights(i+singleGateOpSize*2,p)*tmpHiddenState;
                    end
                    G(i,j,1)=G(i,j,1)+gateBias(i);
                    G(i+singleGateOpSize,j,1)=G(i+singleGateOpSize,j,1)+gateBias(i+singleGateOpSize);
                    G(i+singleGateOpSize*2,j,1)=G(i+singleGateOpSize*2,j,1)+stateBias(i);
                    G(i+singleGateOpSize*3,j,1)=G(i+singleGateOpSize*3,j,1)+gateBias(i+singleGateOpSize*2);
                end
            end
        else
            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for i=1:singleGateOpSize
                for j=1:N
                    for p=1:numHiddenUnits
                        tmpHiddenState=y0(p,j);
                        G(i,j,1)=G(i,j,1)+recurrentGateWeights(i,p)*tmpHiddenState;
                        G(i+singleGateOpSize,j,1)=G(i+singleGateOpSize,j,1)+recurrentGateWeights(i+singleGateOpSize,p)*tmpHiddenState;
                        G(i+singleGateOpSize*2,j,1)=G(i+singleGateOpSize*2,j,1)+recurrentStateWeights(i,p)*tmpHiddenState;
                        G(i+singleGateOpSize*3,j,1)=G(i+singleGateOpSize*3,j,1)+recurrentGateWeights(i+singleGateOpSize*2,p)*tmpHiddenState;
                    end
                    G(i,j,1)=G(i,j,1)+gateBias(i);
                    G(i+singleGateOpSize,j,1)=G(i+singleGateOpSize,j,1)+gateBias(i+singleGateOpSize);
                    G(i+singleGateOpSize*2,j,1)=G(i+singleGateOpSize*2,j,1)+stateBias(i);
                    G(i+singleGateOpSize*3,j,1)=G(i+singleGateOpSize*3,j,1)+gateBias(i+singleGateOpSize*2);
                end
            end
        end
    end




    coder.internal.treatAsParfor();
    coder.internal.parallelRelax();
    for i=1:singleGateOpSize
        for j=1:N
            G(i,j,1)=gateActivationFcn(G(i,j,1));
            G(i+singleGateOpSize,j,1)=gateActivationFcn(G(i+singleGateOpSize,j,1));
            G(i+singleGateOpSize*2,j,1)=stateActivationFcn(G(i+singleGateOpSize*2,j,1));
            G(i+singleGateOpSize*3,j,1)=gateActivationFcn(G(i+singleGateOpSize*3,j,1));
        end
    end



    ipGateOp=G(1:singleGateOpSize,:,1);
    forgetGateOp=G(singleGateOpSize+1:singleGateOpSize*2,:,1);
    cellGateOp=G((singleGateOpSize*2)+1:singleGateOpSize*3,:,1);
    outputGateOp=G((singleGateOpSize*3)+1:singleGateOpSize*4,:,1);





    if coder.const(N==1)
        coder.internal.treatAsParfor();
        coder.internal.parallelRelax();
        for i=1:numHiddenUnits
            CS(i,1,1)=cellGateOp(i,1)*ipGateOp(i,1);
            CS(i,1,1)=CS(i,1,1)+forgetGateOp(i,1)*c0(i);
            YT(i,1,1)=stateActivationFcn(CS(i,1,1))*outputGateOp(i,1);
        end
    else
        if~isStateBatchExpanded
            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for i=1:numHiddenUnits
                for j=1:N
                    CS(i,j,1)=cellGateOp(i,j)*ipGateOp(i,j);
                    CS(i,j,1)=CS(i,j,1)+forgetGateOp(i,j)*c0(i);
                    YT(i,j,1)=stateActivationFcn(CS(i,j,1))*outputGateOp(i,j);
                end
            end
        else
            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for i=1:numHiddenUnits
                for j=1:N
                    CS(i,j,1)=cellGateOp(i,j)*ipGateOp(i,j);
                    CS(i,j,1)=CS(i,j,1)+forgetGateOp(i,j)*c0(i,j);
                    YT(i,j,1)=stateActivationFcn(CS(i,j,1))*outputGateOp(i,j);
                end
            end
        end
    end



    for tt=2:S


        coder.internal.treatAsParfor();
        coder.internal.parallelRelax();
        for i=1:singleGateOpSize
            for j=1:N
                for p=1:numHiddenUnits
                    tmpHiddenState=YT(p,j,tt-1);
                    G(i,j,tt)=G(i,j,tt)+recurrentGateWeights(i,p)*tmpHiddenState;
                    G(i+singleGateOpSize,j,tt)=G(i+singleGateOpSize,j,tt)+recurrentGateWeights(i+singleGateOpSize,p)*tmpHiddenState;
                    G(i+singleGateOpSize*2,j,tt)=G(i+singleGateOpSize*2,j,tt)+recurrentStateWeights(i,p)*tmpHiddenState;
                    G(i+singleGateOpSize*3,j,tt)=G(i+singleGateOpSize*3,j,tt)+recurrentGateWeights(i+singleGateOpSize*2,p)*tmpHiddenState;
                end
                G(i,j,tt)=G(i,j,tt)+gateBias(i);
                G(i+singleGateOpSize,j,tt)=G(i+singleGateOpSize,j,tt)+gateBias(i+singleGateOpSize);
                G(i+singleGateOpSize*2,j,tt)=G(i+singleGateOpSize*2,j,tt)+stateBias(i);
                G(i+singleGateOpSize*3,j,tt)=G(i+singleGateOpSize*3,j,tt)+gateBias(i+singleGateOpSize*2);
            end
        end




        coder.internal.treatAsParfor();
        coder.internal.parallelRelax();
        for i=1:singleGateOpSize
            for j=1:N
                G(i,j,tt)=gateActivationFcn(G(i,j,tt));
                G(i+singleGateOpSize,j,tt)=gateActivationFcn(G(i+singleGateOpSize,j,tt));
                G(i+singleGateOpSize*2,j,tt)=stateActivationFcn(G(i+singleGateOpSize*2,j,tt));
                G(i+singleGateOpSize*3,j,tt)=gateActivationFcn(G(i+singleGateOpSize*3,j,tt));
            end
        end



        ipGateOp=G(1:singleGateOpSize,:,tt);
        forgetGateOp=G(singleGateOpSize+1:singleGateOpSize*2,:,tt);
        cellGateOp=G((singleGateOpSize*2)+1:singleGateOpSize*3,:,tt);
        outputGateOp=G((singleGateOpSize*3)+1:singleGateOpSize*4,:,tt);






        coder.internal.treatAsParfor();
        coder.internal.parallelRelax();
        for i=1:numHiddenUnits
            for j=1:N
                CS(i,j,tt)=cellGateOp(i,j)*ipGateOp(i,j);
                CS(i,j,tt)=CS(i,j,tt)+forgetGateOp(i,j)*CS(i,j,tt-1);
                YT(i,j,tt)=stateActivationFcn(CS(i,j,tt))*outputGateOp(i,j);
            end
        end

    end

    [CSout,YTout]=coder.internal.layer.rnnUtils.prepareOutputDataForRnn(CS(:,:,end),YT,numHiddenUnits,inputFormat);
end
