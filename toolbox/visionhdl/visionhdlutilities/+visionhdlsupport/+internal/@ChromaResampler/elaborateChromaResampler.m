function topNet=elaborateChromaResampler(this,topNet,blockInfo,insignals,outsignals)


















    pixelIn=insignals(1);
    hStartIn=insignals(2);
    hEndIn=insignals(3);
    vStartIn=insignals(4);
    vEndIn=insignals(5);
    validIn=insignals(6);

    pixelInSplit=pixelIn.split;
    YIn=pixelInSplit.PirOutputSignals(1);
    CbIn=pixelInSplit.PirOutputSignals(2);
    CrIn=pixelInSplit.PirOutputSignals(3);

    inRate=YIn.SimulinkRate;










    hStartOut=outsignals(2);
    hEndOut=outsignals(3);
    vStartOut=outsignals(4);
    vEndOut=outsignals(5);
    validOut=outsignals(6);


    dataType=YIn.Type;
    ctrlType=pir_boolean_t();

    YInReg=topNet.addSignal(dataType,'YInReg');
    CbInReg=topNet.addSignal(dataType,'CbInReg');
    CrInReg=topNet.addSignal(dataType,'CrInReg');
    hStartInReg=topNet.addSignal(ctrlType,'hStartInReg');
    hEndInReg=topNet.addSignal(ctrlType,'hEndInReg');
    vStartInReg=topNet.addSignal(ctrlType,'vStartInReg');
    vEndInReg=topNet.addSignal(ctrlType,'vEndInReg');
    validInReg=topNet.addSignal(ctrlType,'validInReg');

    pirelab.getUnitDelayComp(topNet,YIn,YInReg);
    pirelab.getUnitDelayComp(topNet,CbIn,CbInReg);
    pirelab.getUnitDelayComp(topNet,CrIn,CrInReg);
    pirelab.getUnitDelayComp(topNet,hStartIn,hStartInReg);
    pirelab.getUnitDelayComp(topNet,hEndIn,hEndInReg);
    pirelab.getUnitDelayComp(topNet,vStartIn,vStartInReg);
    pirelab.getUnitDelayComp(topNet,vEndIn,vEndInReg);
    pirelab.getUnitDelayComp(topNet,validIn,validInReg);


    TripletOut(1)=topNet.addSignal(dataType,'YComp');
    TripletOut(2)=topNet.addSignal(dataType,'CbComp');
    TripletOut(3)=topNet.addSignal(dataType,'CrComp');
    hStartO=topNet.addSignal(ctrlType,'hs');
    hEndO=topNet.addSignal(ctrlType,'he');
    vStartO=topNet.addSignal(ctrlType,'vs');
    vEndO=topNet.addSignal(ctrlType,'ve');
    validO=topNet.addSignal(ctrlType,'valid');





    switch blockInfo.OperationMode
    case 0
        SGNet=this.elabPixelFormatter(topNet,blockInfo,inRate);
        SGNet.addComment(['This module is used in the case of 4:4:4 to 4:2:2 downsample without',char(10)...
        ,'using an antialiasing filter or 4:2:2 to 4:4:4 upsample with pixel',char(10)...
        ,'replication']);
        SGNet.addComment(['Input stream of Cb or Cr : a b c d e f g h i j ...',char(10)...
        ,'Output stream of Cb or Cr: a a c c e e g g i i ...']);
        pirelab.instantiateNetwork(topNet,SGNet,[YInReg,CbInReg,CrInReg,hStartInReg,hEndInReg,vStartInReg,vEndInReg,validInReg],...
        [TripletOut(1),TripletOut(2),TripletOut(3),hStartO,hEndO,vStartO,vEndO,validO],'PixelFormatNet_inst');
    case 1
        Out1=topNet.addSignal(dataType,'YConv');
        Out2=topNet.addSignal(dataType,'CbConv');
        Out3=topNet.addSignal(dataType,'CrConv');
        hSOut=topNet.addSignal(ctrlType,'hs');
        hEOut=topNet.addSignal(ctrlType,'he');
        vSOut=topNet.addSignal(ctrlType,'vs');
        vEOut=topNet.addSignal(ctrlType,'ve');
        vOut=topNet.addSignal(ctrlType,'valid');

        OneDFIRNet=this.elab1DFIR(topNet,blockInfo,inRate);
        OneDFIRNet.addComment('Apply Antialiasing Filter');
        pirelab.instantiateNetwork(topNet,OneDFIRNet,[YInReg,CbInReg,CrInReg,hStartInReg,hEndInReg,vStartInReg,vEndInReg,validInReg],...
        [Out1,Out2,Out3,hSOut,hEOut,vSOut,vEOut,vOut],'OneDFIRNet_inst');

        dswoFilterNet=this.elabPixelFormatter(topNet,blockInfo,inRate);
        dswoFilterNet.addComment(['Input stream of Cb or Cr : a b c d e f g h i j ...',char(10)...
        ,'Output stream of Cb or Cr: a a c c e e g g i i ...']);
        pirelab.instantiateNetwork(topNet,dswoFilterNet,[Out1,Out2,Out3,hSOut,hEOut,vSOut,vEOut,vOut],...
        [TripletOut(1),TripletOut(2),TripletOut(3),hStartO,hEndO,vStartO,vEndO,validO],'PixelFormatNet_inst');
    case 2
        Out1=topNet.addSignal(dataType,'YConv');
        Out2=topNet.addSignal(dataType,'CbConv');
        Out3=topNet.addSignal(dataType,'CrConv');
        hSOut=topNet.addSignal(ctrlType,'hs');
        hEOut=topNet.addSignal(ctrlType,'he');
        vSOut=topNet.addSignal(ctrlType,'vs');
        vEOut=topNet.addSignal(ctrlType,'ve');
        vOut=topNet.addSignal(ctrlType,'valid');

        usprNet=this.elabPixelFormatter(topNet,blockInfo,inRate);
        usprNet.addComment(['Input stream of Cb or Cr : a b c d e f g h i j ...',char(10)...
        ,'Output stream of Cb or Cr: a a c c e e g g i i ...']);
        pirelab.instantiateNetwork(topNet,usprNet,[YInReg,CbInReg,CrInReg,hStartInReg,hEndInReg,vStartInReg,vEndInReg,validInReg],...
        [Out1,Out2,Out3,hSOut,hEOut,vSOut,vEOut,vOut],'PixelFormatNet_inst');

        uslinearNet=this.elabUpSampleLinear(topNet,blockInfo,inRate);
        uslinearNet.addComment(['Input stream of Cb or Cr : a a c c e e g ...',char(10)...
        ,'Output stream of Cb or Cr: a x c y e z g ...',char(10)...
        ,'Here x is the mean of a and c, y is the mean of c and e, and so on.']);
        pirelab.instantiateNetwork(topNet,uslinearNet,[Out1,Out2,Out3,hSOut,hEOut,vSOut,vEOut,vOut],...
        [TripletOut(1),TripletOut(2),TripletOut(3),hStartO,hEndO,vStartO,vEndO,validO],'UpSampleLinearNet_inst');
    end


    zeroconst=topNet.addSignal(dataType,'const_zero');
    pirelab.getConstComp(topNet,zeroconst,0);
    OutMux(1)=topNet.addSignal(dataType,'YOutComp');
    OutMux(2)=topNet.addSignal(dataType,'CbOutComp');
    OutMux(3)=topNet.addSignal(dataType,'CrOutComp');
    for ii=1:3
        switchout=topNet.addSignal(dataType,'SwitchOut');
        pirelab.getSwitchComp(topNet,[zeroconst,TripletOut(ii)],switchout,validO);
        pirelab.getUnitDelayComp(topNet,switchout,OutMux(ii));
    end


    pirelab.getMuxComp(topNet,[OutMux(1),OutMux(2),OutMux(3)],outsignals(1));

    hStartNext=topNet.addSignal(ctrlType,'hsNext');
    pirelab.getLogicComp(topNet,[validO,hStartO],hStartNext,'and');
    hEndNext=topNet.addSignal(ctrlType,'heNext');
    pirelab.getLogicComp(topNet,[validO,hEndO],hEndNext,'and');
    vStartNext=topNet.addSignal(ctrlType,'vsNext');
    pirelab.getLogicComp(topNet,[validO,vStartO],vStartNext,'and');
    vEndNext=topNet.addSignal(ctrlType,'veNext');
    pirelab.getLogicComp(topNet,[validO,vEndO],vEndNext,'and');

    pirelab.getUnitDelayComp(topNet,hStartNext,hStartOut);
    pirelab.getUnitDelayComp(topNet,hEndNext,hEndOut);
    pirelab.getUnitDelayComp(topNet,vStartNext,vStartOut);
    pirelab.getUnitDelayComp(topNet,vEndNext,vEndOut);
    pirelab.getUnitDelayComp(topNet,validO,validOut);





