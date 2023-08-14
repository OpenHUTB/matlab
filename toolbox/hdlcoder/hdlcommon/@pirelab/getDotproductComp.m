function dotpComp=getDotproductComp(hN,hInSignals,hOutSignals,...
    compName,rndMode,satMode,architecture,nfpOptions,dspMode,...
    useCplxConj,traceComment)

















    narginchk(7,11);

    if nargin<11
        traceComment='';
    end

    if nargin<10
        useCplxConj=true;
    end

    if nargin<9
        dspMode=int8(0);
    end

    if nargin<8
        nfpOptions.Latency=int8(0);
        nfpOptions.MantMul=int8(0);
        nfpOptions.Denormals=int8(0);
        nfpOptions.Radix=int32(2);
    end

    treeArch=strcmpi(architecture,'tree');
    inType1=hInSignals(1).Type;
    inType2=hInSignals(2).Type;
    outType=hOutSignals(1).Type;

    mulCompName=['mul_',compName,'_dotp'];
    prodsigName=['tmp_',compName,'_dotp'];
    inDimLen=max(inType1.getDimensions,inType2.getDimensions);


    if useCplxConj&&pirelab.hasComplexType(inType1)
        if inType1.isArrayType
            signalA=hN.addSignal(inType1,['cconj_',compName,'_dotp']);
        else
            signalA=hN.addSignal(pirelab.getComplexType(inType1),['cconj_',compName,'_dotp']);
        end
        signalA.SimulinkRate=hInSignals(1).SimulinkRate;
        pirelab.getComplexConjugateComp(hN,-1,hInSignals(1),signalA,...
        satMode,compName,rndMode);
        hInSignals(1)=signalA;
    end

    if inDimLen==1

        dotpComp=pirelab.getMulComp(hN,hInSignals,hOutSignals,...
        rndMode,satMode,[mulCompName,'_mulcomp'],'**','',-1,dspMode,nfpOptions);
        dotpComp.addTraceabilityComment(traceComment);
        return
    end

    if treeArch




        if pirelab.hasComplexType(inType1)||pirelab.hasComplexType(inType2)
            prodType=pirelab.getPirVectorType(pirelab.getComplexType(outType),inDimLen);
        else
            prodType=pirelab.getPirVectorType(outType,inDimLen);
        end

        prodSignal=hN.addSignal(prodType,prodsigName);
        prodSignal.SimulinkRate=hOutSignals.SimulinkRate;



        if isInputOrientationMixed(inType1,inType2)
            hInTranspose=hN.addSignal(hInSignals(2).Type,'ip1_transpose');
            pirelab.getTransposeComp(hN,hInSignals(1),hInTranspose);
            hInSignal_1=hInTranspose;
        else
            hInSignal_1=hInSignals(1);
        end


        mulComp=pirelab.getMulComp(hN,[hInSignal_1,hInSignals(2)],prodSignal,...
        rndMode,satMode,mulCompName,'**','',-1,dspMode,nfpOptions);
        mulComp.addTraceabilityComment(traceComment);

        addCompName=['add_',compName,'_dotp'];
        if pirelab.hasComplexType(outType)
            addCompName=[addCompName,'_tree_cplx'];
        end


        dotpComp=pirelab.getTreeArch(hN,prodSignal,hOutSignals,'sum',...
        rndMode,satMode,addCompName,'Zero',false,true,false,'Value',...
        int8(0),nfpOptions);
        dotpComp.addTraceabilityComment(traceComment);

    else
        constsigName=['sum_',compName,'_dotp'];

        dotpOper1=hInSignals(1).split;
        dotpOper2=hInSignals(2).split;
        for itr=1:inDimLen

            mac_suffix=['_',int2str(itr-1)];
            if inDimLen>1
                prodSignal=hN.addSignal(outType,[prodsigName,mac_suffix]);
                prodSignal.SimulinkRate=hOutSignals.SimulinkRate;
            else
                prodSignal=hOutSignals;
            end

            tmpProdComp=pirelab.getMulComp(hN,[dotpOper1.PirOutputSignals(itr),...
            dotpOper2.PirOutputSignals(itr)],prodSignal,...
            rndMode,satMode,[mulCompName,mac_suffix],'**','',-1,...
            dspMode,nfpOptions);
            tmpProdComp.addTraceabilityComment(traceComment);
            if itr>1

                if itr<inDimLen
                    constNextSig=hN.addSignal(outType,[constsigName,mac_suffix]);
                    constNextSig.SimulinkRate=hOutSignals.SimulinkRate;
                else
                    constNextSig=hOutSignals;
                end
                dotpComp=pirelab.getAddComp(hN,[prodSignal,constPrevSig],...
                constNextSig,rndMode,satMode,compName,hOutSignals.Type,'++',...
                '',-1,nfpOptions,traceComment);
                constPrevSig=constNextSig;
            else

                dotpComp=tmpProdComp;
                constPrevSig=prodSignal;
            end
        end
    end
end

function flag=isInputOrientationMixed(inType1,inType2)
    flag=inType1.isArrayType&&inType2.isArrayType;
    flag=flag&&xor(inType1.isRowVector,inType2.isRowVector)&&...
    any([inType1.isColumnVector,inType2.isColumnVector]);
end


