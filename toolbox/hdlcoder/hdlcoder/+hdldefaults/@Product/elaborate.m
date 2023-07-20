function mulComp=elaborate(this,hN,hC)






    [rndMode,satMode,inputSigns,dspMode,nfpOptions,blockOptions,isPOE]=this.getBlockInfo(hC);
    mulKind=blockOptions.mulKind;
    hCInputSignals=hC.PirInputSignals;
    hCOutputSignals=hC.PirOutputSignals(1);
    outType=hCOutputSignals.Type;
    matMulKind=this.getMatMulKind;
    numInputPorts=hC.NumberOfPirInputPorts;
    targetMode=targetmapping.mode(hCOutputSignals);

    if hCOutputSignals(1).Type.isMatrix
        traceComment=hC.getComment;
    else
        if~isempty(hC.getComment)
            traceComment=hC.getComment;
        else
            traceComment='';
        end
    end


    recipComp=[];


    if(targetMode&&(strcmp(inputSigns,'/')||strcmp(inputSigns,'/*')))
        matrixMode=strcmpi(mulKind,'Matrix(*)');
        in1Type=hC.PirInputSignals(1).Type;
        in1Dim=in1Type.getDimensions;


        isMatrix1x1=in1Dim(1)==1;
        if(matrixMode&&~isMatrix1x1)
            isMatrix2x2=(in1Dim(1)==2&&in1Dim(2)==2);
            if isMatrix2x2
                mulComp=pirelab.getMathMatrixInverse2x2Comp(this,hN,hC,hCInputSignals,hCOutputSignals);
                return;
            end
        else


            if(strcmp(inputSigns,'/*'))
                recipInSig=hC.PirInputSignals(1);
                recipOutSig=hN.addSignal(hC.PirInputSignals(1).Type,[hC.Name,'_recip_out']);
                recipOutSig.SimulinkRate=hC.PirInputSignals(1).SimulinkRate;
                mulInSig=[hC.PirInputSignals(2),recipOutSig];
                mulOutSig=hCOutputSignals;
            else
                prod_out=hN.addSignal(outType,[hC.Name,'_recip_out']);
                prod_out.SimulinkRate=hC.PirOutputSignals(1).SimulinkRate;
                recipInSig=prod_out;
                recipOutSig=hCOutputSignals;
                mulInSig=hCInputSignals;
                mulOutSig=prod_out;

            end
            name=[hC.Name,'_recip'];
            recipComp=pirelab.getMathComp(hN,recipInSig,recipOutSig,name,-1,...
            'reciprocal',nfpOptions);
            inputSigns=repmat('*',1,numInputPorts);
            hCInputSignals=mulInSig;
            hCOutputSignals=mulOutSig;
        end
    else

        if(blockOptions.firstInputSignDivide)

            hCInputSignals=[hC.PirInputSignals(2),hC.PirInputSignals(1)];
        end
        hCOutputSignals=hC.PirOutputSignals;
    end

    if isPOE
        hNewNet=createNetworkWithComponent(hN,hC);
        pirelab.getMulComp(hNewNet,hNewNet.PirInputSignals,hNewNet.PirOutputSignals,...
        rndMode,satMode,hC.Name,inputSigns,'',-1,dspMode,nfpOptions,...
        mulKind,matMulKind,traceComment);
        mulComp=pirelab.instantiateNetwork(hN,hNewNet,hCInputSignals,hCOutputSignals,hC.Name);
    else
        mulComp=pirelab.getMulComp(hN,hCInputSignals,hCOutputSignals,...
        rndMode,satMode,hC.Name,inputSigns,'',-1,dspMode,nfpOptions,...
        mulKind,matMulKind,traceComment);
    end


    if~isempty(recipComp)
        mulComp=recipComp;
    end
end

function hNewNet=createNetworkWithComponent(hN,hC)

    hNewNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC);



    for ii=1:length(hC.PirInputSignals)
        hNewNet.PirInputSignals(ii).SimulinkRate=hC.PirInputSignals(ii).SimulinkRate;
    end

    for ii=1:length(hC.PirOutputSignals)
        hNewNet.PirOutputSignals(ii).SimulinkRate=hC.PirOutputSignals(ii).SimulinkRate;
    end
    hNewNet.setFlattenHierarchy('on');
end

