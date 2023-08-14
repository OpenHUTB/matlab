function cptNet=elabhistCore(~,topNet,blockInfo,dataRate,inType)





    binWL=blockInfo.binWL;
    binType=pir_ufixpt_t(binWL,0);
    doutType=pir_ufixpt_t(blockInfo.outputWL,0);
    ctlType=pir_boolean_t();


    inportnames={'dataIn','resetRAM','cmptHist','readOut','rstwaddr','binaddr'};


    cptNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','HistCore',...
    'InportNames',inportnames,...
    'InportTypes',[inType,ctlType,ctlType,ctlType,binType,binType],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'OutportNames',{'histVal','readRDY','validOut'},...
    'OutportTypes',[doutType,ctlType,ctlType]...
    );


    dataIn=cptNet.PirInputSignals(1);
    resetRAM=cptNet.PirInputSignals(2);
    cmptHist=cptNet.PirInputSignals(3);
    readOut=cptNet.PirInputSignals(4);
    rstwaddr=cptNet.PirInputSignals(5);
    binaddr=cptNet.PirInputSignals(6);

    histVal=cptNet.PirOutputSignals(1);
    readRDY=cptNet.PirOutputSignals(2);
    validOut=cptNet.PirOutputSignal(3);


    wdata=cptNet.addSignal(doutType,'wdata');
    waddr=cptNet.addSignal(binType,'waddr');
    raddr=cptNet.addSignal(binType,'raddr');
    wenb=cptNet.addSignal(ctlType,'wenb');

    wdout=cptNet.addSignal(doutType,'wdout');
    rdout=cptNet.addSignal(doutType,'rdout');
    newhist=cptNet.addSignal(doutType,'newhist');
    oldhist=cptNet.addSignal(doutType,'oldhist');


    const0=cptNet.addSignal(doutType,'constZero');
    const1=cptNet.addSignal(doutType,'constOne');

    pirelab.getConstComp(cptNet,const0,0);
    pirelab.getConstComp(cptNet,const1,1);

    comp=pirelab.getSwitchComp(cptNet,[const0,newhist],wdata,resetRAM,'','==',1);
    comp.addComment('memory write data');

    dWL=dataIn.Type.WordLength;

    if dWL>binWL
        sliceddataIn=cptNet.addSignal(binType,'sliceddataIn');
        pirelab.getBitSliceComp(cptNet,dataIn,sliceddataIn,dWL-1,dWL-binWL);
    elseif dWL<binWL
        sliceddataIn=cptNet.addSignal(binType,'slicedataIn');
        pirelab.getDTCComp(cptNet,dataIn,sliceddataIn,'Floor','Wrap','SI');
    else
        sliceddataIn=dataIn;
    end

    histwaddr=cptNet.addSignal(binType,'histwaddr');
    pirelab.getUnitDelayComp(cptNet,sliceddataIn,histwaddr);

    comp=pirelab.getSwitchComp(cptNet,[rstwaddr,histwaddr],waddr,resetRAM,'','==',1);
    comp.addComment('memory write address');

    cmptHistreg=cptNet.addSignal(ctlType,'cmptHistReg');
    pirelab.getUnitDelayComp(cptNet,cmptHist,cmptHistreg);
    pirelab.getLogicComp(cptNet,[cmptHistreg,resetRAM],wenb,'or');

    vdataSel=cptNet.addSignal(ctlType,'vdataSel');
    pirelab.getUnitDelayComp(cptNet,readOut,vdataSel);
    comp=pirelab.getSwitchComp(cptNet,[binaddr,sliceddataIn],raddr,vdataSel,'','==',1);
    comp.addComment('memory read address');

    pirelab.getDualPortRamComp(cptNet,[wdata,waddr,wenb,raddr],[wdout,rdout],'HistMemory',1,1);

    repeatpixel=cptNet.addSignal(ctlType,'repeatpixel');
    repeatpixelreg=cptNet.addSignal(ctlType,'repeatpixelReg');
    comp=pirelab.getRelOpComp(cptNet,[sliceddataIn,histwaddr],repeatpixel,'==');
    comp.addComment('handle repeated pixel values');
    pirelab.getUnitDelayComp(cptNet,repeatpixel,repeatpixelreg);

    pirelab.getSwitchComp(cptNet,[wdout,rdout],oldhist,repeatpixelreg,'','==',1);

    comp=pirelab.getAddComp(cptNet,[oldhist,const1],newhist,'Floor','Saturate');
    comp.addComment('update histogram value');

    eqwraddr=cptNet.addSignal(ctlType,'eqwraddr');
    pirelab.getRelOpComp(cptNet,[waddr,raddr],eqwraddr,'==');

    firsthvalSel=cptNet.addSignal(ctlType,'firsthvalSel');
    firsthvalSelreg=cptNet.addSignal(ctlType,'firsthvalSelReg');
    pirelab.getLogicComp(cptNet,[eqwraddr,cmptHistreg,vdataSel],firsthvalSel,'and');
    pirelab.getUnitDelayComp(cptNet,firsthvalSel,firsthvalSelreg);

    vldhistval=cptNet.addSignal(doutType,'vldhistVal');
    dataout=cptNet.addSignal(doutType,'dataOut');

    pirelab.getSwitchComp(cptNet,[wdout,rdout],vldhistval,firsthvalSelreg,'','==',1);


    finalDataSel=cptNet.addSignal(ctlType,'finaldataSel');
    pirelab.getUnitDelayComp(cptNet,vdataSel,finalDataSel,1);

    pirelab.getSwitchComp(cptNet,[vldhistval,const0],dataout,finalDataSel,'','==',1);


    pirelab.getDTCComp(cptNet,vdataSel,readRDY);
    comp=pirelab.getIntDelayComp(cptNet,dataout,histVal,1);
    comp.addComment('output registers');
    pirelab.getUnitDelayComp(cptNet,finalDataSel,validOut,1);


