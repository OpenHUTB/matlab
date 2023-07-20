function elaborateHistogram(this,topNet,blockInfo,insignals,outsignals)













    dataIn=insignals(1);
    inRate=dataIn.SimulinkRate;
    hstartIn=insignals(2);
    hendIn=insignals(3);
    vstartIn=insignals(4);
    vendIn=insignals(5);
    validIn=insignals(6);
    binAddr=insignals(7);
    binReset=insignals(8);



    dataOut=outsignals(1);
    readReady=outsignals(2);
    validOut=outsignals(3);


    binWL=blockInfo.binWL;
    binType=pir_ufixpt_t(binWL,0);
    ctlType=pir_boolean_t();
    outputWL=blockInfo.outputWL;
    histType=pir_ufixpt_t(outputWL,0);



    dataInReg=topNet.addSignal(dataIn.Type,'dataInReg');
    hstartInReg=topNet.addSignal(ctlType,'hStartInReg');
    hendInReg=topNet.addSignal(ctlType,'hendInReg');
    vendInReg=topNet.addSignal(ctlType,'vendInReg');
    validInReg=topNet.addSignal(ctlType,'validInReg');
    binResetReg=topNet.addSignal(ctlType,'binResetReg');

    pirelab.getUnitDelayComp(topNet,dataIn,dataInReg);
    pirelab.getUnitDelayComp(topNet,hstartIn,hstartInReg);
    pirelab.getUnitDelayComp(topNet,hendIn,hendInReg);
    pirelab.getUnitDelayComp(topNet,vendIn,vendInReg);
    pirelab.getUnitDelayComp(topNet,validIn,validInReg);
    pirelab.getUnitDelayComp(topNet,binReset,binResetReg);


    signalType=dataIn.Type;
    if signalType.isArrayType
        for ii=1:dataIn.Type.Dimensions
            signal(ii)=newDataSignal(topNet,sprintf('signal%d',ii),signalType.BaseType,inRate);
            pirelab.getSelectorComp(topNet,dataInReg,signal(ii),'One-based',{'Index vector (dialog)','Select all'},{ii},{'Inherit from "Index"'},'2',sprintf('Selector%d',ii));
        end
    end


    resetRAM=topNet.addSignal(ctlType,'resetRAM');
    cmptHist=topNet.addSignal(ctlType,'cmptHist');
    readOut=topNet.addSignal(ctlType,'readOut');
    wraddr=topNet.addSignal(binType,'wraddr');


    hctNet=this.elabhistController(topNet,blockInfo,inRate);
    hctNet.addComment('Histogram Controller');

    pirelab.instantiateNetwork(topNet,hctNet,[hstartInReg,hendInReg,vstartIn,vendInReg,validInReg,binReset],...
    [resetRAM,cmptHist,readOut,wraddr],'hctNet_inst');


    if signalType.isArrayType
        for ii=1:dataIn.Type.Dimensions
            histVal(ii)=topNet.addSignal(histType,sprintf('histVal%d',ii));
            readRDY(ii)=topNet.addSignal(ctlType,sprintf('readRDY%d',ii));
            vOut(ii)=topNet.addSignal(ctlType,sprintf('vldOut%d',ii));
        end
    else
        histVal=topNet.addSignal(dataOut.Type,'histVal');
        readRDY=topNet.addSignal(ctlType,'readRDY');
        vOut=topNet.addSignal(ctlType,'vldOut');
    end

    if signalType.isArrayType
        for ii=1:dataIn.Type.Dimensions

            hcpNet=this.elabhistCore(topNet,blockInfo,inRate,dataIn.Type.BaseType);
            hcpNet.addComment('Histogram Core');

            pirelab.instantiateNetwork(topNet,hcpNet,[signal(ii),resetRAM,cmptHist,readOut,wraddr,binAddr],...
            [histVal(ii),readRDY(ii),vOut(ii)],sprintf('hcpNet_inst%d',ii));
        end

    else

        hcpNet=this.elabhistCore(topNet,blockInfo,inRate,dataIn.Type);
        hctNet.addComment('Histogram Core');


        pirelab.instantiateNetwork(topNet,hcpNet,[dataInReg,resetRAM,cmptHist,readOut,wraddr,binAddr],...
        [histVal,readRDY,validOut],'hcpNet_inst');
    end


    if signalType.isArrayType
        hist_comb=topNet.addSignal(histType,'hist_comb');
        readRDY_comb=topNet.addSignal(ctlType,'readRDY_comb');
        if dataIn.Type.Dimensions==2
            pirelab.getAddComp(topNet,[histVal(1),histVal(2)],hist_comb,'Round','Saturate','adder',[],'++');
            pirelab.getBitwiseOpComp(topNet,[readRDY(1),readRDY(2)],readRDY_comb,'AND');
            pirelab.getBitwiseOpComp(topNet,[vOut(1),vOut(2)],validOut,'AND');
        end
        if dataIn.Type.Dimensions==4
            pirelab.getAddComp(topNet,[histVal(1),histVal(2),histVal(3),histVal(4)],hist_comb,'Round','Saturate','adder',[],'++++');
            pirelab.getBitwiseOpComp(topNet,[readRDY(1),readRDY(2),readRDY(3),readRDY(4)],readRDY_comb,'AND');
            pirelab.getBitwiseOpComp(topNet,[vOut(1),vOut(2),vOut(3),vOut(4)],validOut,'AND');
        end
        if dataIn.Type.Dimensions==8
            pirelab.getAddComp(topNet,[histVal(1),histVal(2),histVal(3),histVal(4),histVal(5),histVal(6),histVal(7),histVal(8)],hist_comb,'Round','Saturate','adder',[],'++++++++');
            pirelab.getBitwiseOpComp(topNet,[readRDY(1),readRDY(2),readRDY(3),readRDY(4),readRDY(5),readRDY(6),readRDY(7),readRDY(8)],readRDY_comb,'AND');
            pirelab.getBitwiseOpComp(topNet,[vOut(1),vOut(2),vOut(3),vOut(4),vOut(5),vOut(6),vOut(7),vOut(8)],validOut,'AND');
        end
    end


    if signalType.isArrayType
        pirelab.getDTCComp(topNet,hist_comb,dataOut);
        pirelab.getDTCComp(topNet,readRDY_comb,readReady);
    else
        pirelab.getDTCComp(topNet,histVal,dataOut);
        pirelab.getDTCComp(topNet,readRDY,readReady);
    end
end


function signal=newDataSignal(topNet,name,inType,rate)
    signal=topNet.addSignal(inType,name);
    signal.SimulinkRate=rate;
end
