%#codegen
%#internal


function[Yout,HSout]=gruForwardUsingExplicitLoops(layer,X,numHiddenUnits,inputGateWeights,...
    inputStateWeights,recurrentGateWeights,recurrentStateWeights,inputGateBias,...
    inputStateBias,recurrentGateBias,recurrentStateBias,h0)

























    coder.allowpcode('plain');
    coder.internal.prefer_const('numHiddenUnits');

    inputFormat=layer.InputFormat;

    stateActivationFunction=coder.const(coder.internal.layer.utils.getStateActivation(layer.StateActivationFcn));
    gateActivationFunction=coder.const(coder.internal.layer.utils.getGateActivation(layer.GateActivationFcn));

    N=coder.internal.layer.utils.getFormatSizeAndDimension(X,inputFormat,'B');
    S=coder.internal.layer.utils.getFormatSizeAndDimension(X,inputFormat,'T');

    isStateBatchExpanded=size(h0,2)>1;

    featureDims=coder.const(size(inputGateWeights,2));
    singleGateOpSizePerBatchAndPerSeq=coder.const(numHiddenUnits);
    allGatesOpSizePerBatchAndPerSeq=coder.const(singleGateOpSizePerBatchAndPerSeq*3);





    G=zeros(allGatesOpSizePerBatchAndPerSeq,N,S,'like',X);
    YT=coder.nullcopy(zeros(singleGateOpSizePerBatchAndPerSeq,N,S,'like',X));
    tmpRxhTerm=coder.nullcopy(zeros(singleGateOpSizePerBatchAndPerSeq,N,'like',X));





    coder.internal.treatAsParfor();
    coder.internal.parallelRelax();
    for i=1:singleGateOpSizePerBatchAndPerSeq
        br=inputGateBias(i);
        bu=inputGateBias(i+singleGateOpSizePerBatchAndPerSeq);
        bc=inputStateBias(i);
        for tt=1:S
            for j=1:N
                tmpGR=G(i,j,tt);
                tmpGU=G(i+singleGateOpSizePerBatchAndPerSeq,j,tt);
                tmpGC=G(i+singleGateOpSizePerBatchAndPerSeq*2,j,tt);
                for k=1:featureDims
                    xk=coder.internal.layer.rnnUtils.getElementForExplicitLoopRnn(X,k,j,tt,inputFormat);
                    tmpGR=tmpGR+inputGateWeights(i,k)*xk;
                    tmpGU=tmpGU+inputGateWeights(i+singleGateOpSizePerBatchAndPerSeq,k)*xk;
                    tmpGC=tmpGC+inputStateWeights(i,k)*xk;
                end
                G(i,j,tt)=tmpGR+br;
                G(i+singleGateOpSizePerBatchAndPerSeq,j,tt)=tmpGU+bu;
                G(i+singleGateOpSizePerBatchAndPerSeq*2,j,tt)=tmpGC+bc;
            end
        end
    end


    if coder.const(strcmp(layer.ResetGateMode,'recurrent-bias-after-multiplication'))


        coder.internal.treatAsParfor();
        coder.internal.parallelRelax();
        for i=1:singleGateOpSizePerBatchAndPerSeq
            br=recurrentGateBias(i);
            bu=recurrentGateBias(i+singleGateOpSizePerBatchAndPerSeq);
            for tt=1:S
                for j=1:N
                    G(i,j,tt)=G(i,j,tt)+br;
                    G(i+singleGateOpSizePerBatchAndPerSeq,j,tt)=G(i+singleGateOpSizePerBatchAndPerSeq,j,tt)+bu;
                end
            end
        end
    end










    if coder.const(N==1)
        coder.internal.treatAsParfor();
        coder.internal.parallelRelax();
        for i=1:singleGateOpSizePerBatchAndPerSeq
            tmpGR=G(i,1,1);
            tmpGU=G(i+singleGateOpSizePerBatchAndPerSeq,1,1);
            for p=1:numHiddenUnits
                tmph0=h0(p);
                tmpGR=tmpGR+recurrentGateWeights(i,p)*tmph0;
                tmpGU=tmpGU+recurrentGateWeights(i+singleGateOpSizePerBatchAndPerSeq,p)*tmph0;
            end
            G(i,1,1)=gateActivationFunction(tmpGR);
            G(i+singleGateOpSizePerBatchAndPerSeq,1,1)=gateActivationFunction(tmpGU);
        end
    else
        if~isStateBatchExpanded
            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for i=1:singleGateOpSizePerBatchAndPerSeq
                for j=1:N
                    tmpGR=G(i,j,1);
                    tmpGU=G(i+singleGateOpSizePerBatchAndPerSeq,j,1);
                    for p=1:numHiddenUnits
                        tmph0=h0(p);
                        tmpGR=tmpGR+recurrentGateWeights(i,p)*tmph0;
                        tmpGU=tmpGU+recurrentGateWeights(i+singleGateOpSizePerBatchAndPerSeq,p)*tmph0;
                    end
                    G(i,j,1)=gateActivationFunction(tmpGR);
                    G(i+singleGateOpSizePerBatchAndPerSeq,j,1)=gateActivationFunction(tmpGU);
                end
            end
        else
            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for i=1:singleGateOpSizePerBatchAndPerSeq
                for j=1:N
                    tmpGR=G(i,j,1);
                    tmpGU=G(i+singleGateOpSizePerBatchAndPerSeq,j,1);
                    for p=1:numHiddenUnits
                        tmph0=h0(p,j);
                        tmpGR=tmpGR+recurrentGateWeights(i,p)*tmph0;
                        tmpGU=tmpGU+recurrentGateWeights(i+singleGateOpSizePerBatchAndPerSeq,p)*tmph0;
                    end
                    G(i,j,1)=gateActivationFunction(tmpGR);
                    G(i+singleGateOpSizePerBatchAndPerSeq,j,1)=gateActivationFunction(tmpGU);
                end
            end
        end
    end








    resetGateOpAtFirstTimeStep=G(1:singleGateOpSizePerBatchAndPerSeq,:,1);
    updateGateOpAtFirstTimeStep=G(singleGateOpSizePerBatchAndPerSeq+1:singleGateOpSizePerBatchAndPerSeq*2,:,1);
    candidateStateOpAtFirstTimeStep=G((singleGateOpSizePerBatchAndPerSeq*2)+1:singleGateOpSizePerBatchAndPerSeq*3,:,1);
    if coder.const(strcmp(layer.ResetGateMode,'recurrent-bias-after-multiplication'))
        if coder.const(N==1)
            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for i=1:singleGateOpSizePerBatchAndPerSeq
                tmp=zeros(1,'like',X);
                for p=1:numHiddenUnits
                    tmp=tmp+recurrentStateWeights(i,p)*h0(p);
                end
                candidateStateOpAtFirstTimeStep(i,1,1)=stateActivationFunction(candidateStateOpAtFirstTimeStep(i,1,1)+(tmp+recurrentStateBias(i))*resetGateOpAtFirstTimeStep(i));
            end
        else
            if~isStateBatchExpanded
                coder.internal.treatAsParfor();
                coder.internal.parallelRelax();
                for i=1:singleGateOpSizePerBatchAndPerSeq
                    for j=1:N
                        tmp=zeros(1,'like',X);
                        for p=1:numHiddenUnits
                            tmp=tmp+recurrentStateWeights(i,p)*h0(p);
                        end
                        candidateStateOpAtFirstTimeStep(i,j,1)=stateActivationFunction(candidateStateOpAtFirstTimeStep(i,j,1)+(tmp+recurrentStateBias(i))*resetGateOpAtFirstTimeStep(i,j));
                    end
                end
            else
                coder.internal.treatAsParfor();
                coder.internal.parallelRelax();
                for i=1:singleGateOpSizePerBatchAndPerSeq
                    for j=1:N
                        tmp=zeros(1,'like',X);
                        for p=1:numHiddenUnits
                            tmp=tmp+recurrentStateWeights(i,p)*h0(p,j);
                        end
                        candidateStateOpAtFirstTimeStep(i,j,1)=stateActivationFunction(candidateStateOpAtFirstTimeStep(i,j,1)+(tmp+recurrentStateBias(i))*resetGateOpAtFirstTimeStep(i,j));
                    end
                end
            end
        end
    elseif coder.const(strcmp(layer.ResetGateMode,'after-multiplication'))

        if coder.const(N==1)
            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for i=1:singleGateOpSizePerBatchAndPerSeq
                tmp=zeros(1,'like',X);
                for p=1:numHiddenUnits
                    tmp=tmp+recurrentStateWeights(i,p)*h0(p);
                end
                candidateStateOpAtFirstTimeStep(i,1,1)=stateActivationFunction(candidateStateOpAtFirstTimeStep(i,1,1)+(tmp*resetGateOpAtFirstTimeStep(i)));
            end
        else
            if~isStateBatchExpanded
                coder.internal.treatAsParfor();
                coder.internal.parallelRelax();
                for i=1:singleGateOpSizePerBatchAndPerSeq
                    for j=1:N
                        tmp=zeros(1,'like',X);
                        for p=1:numHiddenUnits
                            tmp=tmp+recurrentStateWeights(i,p)*h0(p);
                        end
                        candidateStateOpAtFirstTimeStep(i,j,1)=stateActivationFunction(candidateStateOpAtFirstTimeStep(i,j,1)+(tmp*resetGateOpAtFirstTimeStep(i,j)));
                    end
                end
            else
                coder.internal.treatAsParfor();
                coder.internal.parallelRelax();
                for i=1:singleGateOpSizePerBatchAndPerSeq
                    for j=1:N
                        tmp=zeros(1,'like',X);
                        for p=1:numHiddenUnits
                            tmp=tmp+recurrentStateWeights(i,p)*h0(p,j);
                        end
                        candidateStateOpAtFirstTimeStep(i,j,1)=stateActivationFunction(candidateStateOpAtFirstTimeStep(i,j,1)+(tmp*resetGateOpAtFirstTimeStep(i,j)));
                    end
                end
            end
        end

    else


        if coder.const(N==1)
            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for i=1:singleGateOpSizePerBatchAndPerSeq
                tmpRxhTerm(i,1)=h0(i)*resetGateOpAtFirstTimeStep(i,1);
            end

            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for i=1:singleGateOpSizePerBatchAndPerSeq
                tmp=zeros(1,'like',X);
                for p=1:numHiddenUnits
                    tmp=tmp+recurrentStateWeights(i,p)*tmpRxhTerm(p);
                end
                candidateStateOpAtFirstTimeStep(i,1,1)=stateActivationFunction(candidateStateOpAtFirstTimeStep(i,1,1)+tmp);
            end
        else
            if~isStateBatchExpanded
                coder.internal.treatAsParfor();
                coder.internal.parallelRelax();
                for i=1:singleGateOpSizePerBatchAndPerSeq
                    for j=1:N
                        tmpRxhTerm(i,j)=h0(i)*resetGateOpAtFirstTimeStep(i,j);
                    end
                end

                coder.internal.treatAsParfor();
                coder.internal.parallelRelax();
                for i=1:singleGateOpSizePerBatchAndPerSeq
                    for j=1:N
                        tmp=zeros(1,'like',X);
                        for p=1:numHiddenUnits
                            tmp=tmp+recurrentStateWeights(i,p)*tmpRxhTerm(p,j);
                        end
                        candidateStateOpAtFirstTimeStep(i,j,1)=stateActivationFunction(candidateStateOpAtFirstTimeStep(i,j,1)+tmp);
                    end
                end
            else
                coder.internal.treatAsParfor();
                coder.internal.parallelRelax();
                for i=1:singleGateOpSizePerBatchAndPerSeq
                    for j=1:N
                        tmpRxhTerm(i,j)=h0(i,j)*resetGateOpAtFirstTimeStep(i,j);
                    end
                end

                coder.internal.treatAsParfor();
                coder.internal.parallelRelax();
                for i=1:singleGateOpSizePerBatchAndPerSeq
                    for j=1:N
                        tmp=zeros(1,'like',X);
                        for p=1:numHiddenUnits
                            tmp=tmp+recurrentStateWeights(i,p)*tmpRxhTerm(p,j);
                        end
                        candidateStateOpAtFirstTimeStep(i,j,1)=stateActivationFunction(candidateStateOpAtFirstTimeStep(i,j,1)+tmp);
                    end
                end
            end
        end

    end

    if coder.const(N==1)
        coder.internal.treatAsParfor();
        coder.internal.parallelRelax();
        for i=1:singleGateOpSizePerBatchAndPerSeq
            tmp=updateGateOpAtFirstTimeStep(i,1);
            YT(i,1,1)=(1-tmp)*candidateStateOpAtFirstTimeStep(i,1)+tmp*h0(i);
        end
    else
        if~isStateBatchExpanded
            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for i=1:singleGateOpSizePerBatchAndPerSeq
                for j=1:N
                    tmp=updateGateOpAtFirstTimeStep(i,j);
                    YT(i,j,1)=(1-tmp)*candidateStateOpAtFirstTimeStep(i,j)+tmp*h0(i);

                end
            end
        else
            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for i=1:singleGateOpSizePerBatchAndPerSeq
                for j=1:N

                    tmp=updateGateOpAtFirstTimeStep(i,j);
                    YT(i,j,1)=(1-tmp)*candidateStateOpAtFirstTimeStep(i,j)+tmp*h0(i,j);

                end
            end
        end
    end


    for tt=2:S



        coder.internal.treatAsParfor();
        coder.internal.parallelRelax();
        for i=1:singleGateOpSizePerBatchAndPerSeq
            for j=1:N
                tmpGR=G(i,j,tt);
                tmpGU=G(i+singleGateOpSizePerBatchAndPerSeq,j,tt);
                for p=1:numHiddenUnits
                    tmpPrevYt=YT(p,j,tt-1);
                    tmpGR=tmpGR+recurrentGateWeights(i,p)*tmpPrevYt;
                    tmpGU=tmpGU+recurrentGateWeights(i+singleGateOpSizePerBatchAndPerSeq,p)*tmpPrevYt;
                end
                G(i,j,tt)=gateActivationFunction(tmpGR);
                G(i+singleGateOpSizePerBatchAndPerSeq,j,tt)=gateActivationFunction(tmpGU);
            end
        end



        resetGateOpAtCurrentTimeStep=G(1:singleGateOpSizePerBatchAndPerSeq,:,tt);
        updateGateOpAtCurrentTimeStep=G(singleGateOpSizePerBatchAndPerSeq+1:singleGateOpSizePerBatchAndPerSeq*2,:,tt);
        candidateStateOpAtCurrentTimeStep=G((singleGateOpSizePerBatchAndPerSeq*2)+1:singleGateOpSizePerBatchAndPerSeq*3,:,tt);
        if coder.const(strcmp(layer.ResetGateMode,'recurrent-bias-after-multiplication'))
            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for i=1:singleGateOpSizePerBatchAndPerSeq
                for j=1:N
                    tmp=zeros(1,'like',X);
                    for p=1:numHiddenUnits
                        tmp=tmp+recurrentStateWeights(i,p)*YT(p,j,tt-1);
                    end
                    candidateStateOpAtCurrentTimeStep(i,j)=stateActivationFunction(candidateStateOpAtCurrentTimeStep(i,j)+(tmp+recurrentStateBias(i))*resetGateOpAtCurrentTimeStep(i,j));
                end
            end
        elseif coder.const(strcmp(layer.ResetGateMode,'after-multiplication'))
            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for i=1:singleGateOpSizePerBatchAndPerSeq
                for j=1:N
                    tmp=zeros(1,'like',X);
                    for p=1:numHiddenUnits
                        tmp=tmp+recurrentStateWeights(i,p)*YT(p,j,tt-1);
                    end
                    candidateStateOpAtCurrentTimeStep(i,j)=stateActivationFunction(candidateStateOpAtCurrentTimeStep(i,j)+(tmp*resetGateOpAtCurrentTimeStep(i,j)));
                end
            end
        else
            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for i=1:singleGateOpSizePerBatchAndPerSeq
                for j=1:N
                    tmpRxhTerm(i,j)=YT(i,j,tt-1)*resetGateOpAtCurrentTimeStep(i,j);
                end
            end

            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for i=1:singleGateOpSizePerBatchAndPerSeq
                for j=1:N
                    tmp=zeros(1,'like',X);
                    for p=1:numHiddenUnits
                        tmp=tmp+recurrentStateWeights(i,p)*tmpRxhTerm(p,j);
                    end
                    candidateStateOpAtCurrentTimeStep(i,j,1)=stateActivationFunction(candidateStateOpAtCurrentTimeStep(i,j,1)+tmp);
                end
            end

        end



        coder.internal.treatAsParfor();
        coder.internal.parallelRelax();
        for i=1:singleGateOpSizePerBatchAndPerSeq
            for j=1:N
                tmp=updateGateOpAtCurrentTimeStep(i,j);
                YT(i,j,tt)=(1-tmp)*candidateStateOpAtCurrentTimeStep(i,j)+tmp*YT(i,j,tt-1);
            end
        end

    end



    HS=YT(:,:,end);
    if coder.const(layer.ReturnLast)
        Y=HS;
    else
        Y=YT;
    end


    [HSout,Yout]=coder.internal.layer.rnnUtils.prepareOutputDataForRnn(HS,Y,numHiddenUnits,inputFormat);

end


