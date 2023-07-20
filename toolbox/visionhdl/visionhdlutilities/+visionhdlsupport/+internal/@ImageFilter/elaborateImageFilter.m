function topNet=elaborateImageFilter(this,topNet,blockInfo,inSig,outSig)







    dataIn=inSig(1);
    inRate=dataIn.SimulinkRate;
    hstartIn=inSig(2);
    hendIn=inSig(3);
    vstartIn=inSig(4);
    vendIn=inSig(5);
    validIn=inSig(6);
    dI=struct(dataIn.Type);

    if isfield(dI,'Dimensions')
        inputDim=dataIn.Type.Dimensions;
    else
        inputDim=1;
    end

    blockInfo.NumberOfPixels=inputDim;
    if blockInfo.coeffFromPort
        coeffIn=inSig(7);
    end

    dataOut=outSig(1);
    hstartOut=outSig(2);
    hendOut=outSig(3);
    vstartOut=outSig(4);
    vendOut=outSig(5);
    validOut=outSig(6);


    dataOut.SimulinkRate=inRate;
    hstartOut.SimulinkRate=inRate;
    hendOut.SimulinkRate=inRate;
    vstartOut.SimulinkRate=inRate;
    vendOut.SimulinkRate=inRate;
    validOut.SimulinkRate=inRate;



    ctlType=pir_boolean_t();
    dataInType=dataIn.Type;

    if inputDim==1
        LMKDataOutType=pirelab.getPirVectorType(dataInType,blockInfo.KernelHeight);
    else
        LMKDataOutType=pirelab.createPirArrayType(dataInType.BaseType,[blockInfo.KernelHeight,dataInType.Dimensions]);
    end
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...



    dataInReg=topNet.addSignal(dataIn.Type,'dataInReg');
    hstartInReg=topNet.addSignal(ctlType,'hStartInReg');
    hendInReg=topNet.addSignal(ctlType,'hendInReg');
    vstartInReg=topNet.addSignal(ctlType,'vStartInReg');
    vendInReg=topNet.addSignal(ctlType,'vendInReg');
    validInReg=topNet.addSignal(ctlType,'validInReg');

    pirelab.getUnitDelayComp(topNet,dataIn,dataInReg);
    pirelab.getUnitDelayComp(topNet,hstartIn,hstartInReg);
    pirelab.getUnitDelayComp(topNet,hendIn,hendInReg);
    pirelab.getUnitDelayComp(topNet,vstartIn,vstartInReg);
    pirelab.getUnitDelayComp(topNet,vendIn,vendInReg);
    pirelab.getUnitDelayComp(topNet,validIn,validInReg);
    if blockInfo.coeffFromPort
        coeffInReg=topNet.addSignal(coeffIn.Type,'coeffInReg');
        pirelab.getUnitDelayComp(topNet,coeffIn,coeffInReg);


        vStartValidSig=topNet.addSignal(ctlType,'vStartValidInReg');
        pirelab.getLogicComp(topNet,[vstartInReg,validInReg],vStartValidSig,'and');
        coeffInReg2=topNet.addSignal(coeffIn.Type,'coeffInReg2');

        pirelab.getIntDelayEnabledComp(topNet,coeffInReg,coeffInReg2,vStartValidSig,1,'vStartValid');
    end



    LMKData=topNet.addSignal(LMKDataOutType,'LMKDataOut');
    LMKhs=topNet.addSignal(ctlType,'LMKhStartOut');
    LMKhe=topNet.addSignal(ctlType,'LMKhEndOut');
    LMKvs=topNet.addSignal(ctlType,'LMKvStartOut');
    LMKve=topNet.addSignal(ctlType,'LMKvEndOut');
    LMKvl=topNet.addSignal(ctlType,'LMKvalidOut');
    LMKproc=topNet.addSignal(ctlType,'LMKprocessOut');

    LMKInfo.KernelHeight=blockInfo.KernelHeight;
    LMKInfo.KernelWidth=blockInfo.KernelWidth;
    LMKInfo.MaxLineSize=blockInfo.LineBufferSize;
    LMKInfo.PaddingMethod=blockInfo.PaddingMethodString;
    LMKInfo.PaddingValue=blockInfo.PaddingValue;
    LMKInfo.DataType=dataInType;
    LMKInfo.BiasUp=true;

    LMKNet=this.addLineBuffer(topNet,LMKInfo,inRate);
    pirelab.instantiateNetwork(topNet,LMKNet,[dataInReg,hstartInReg,hendInReg,vstartInReg,vendInReg,validInReg],...
    [LMKData,LMKhs,LMKhe,LMKvs,LMKve,LMKvl,LMKproc],'LineBuffer');




    sigInfo.DataInType=dataIn.Type;
    sigInfo.DataInvType=LMKDataOutType;
    sigInfo.ctlType=ctlType;
    sigInfo.inRate=inRate;
    sigInfo.DataOutType=dataOut.Type;
    if blockInfo.coeffFromPort
        sigInfo.coeffType=coeffInReg2.Type;
    end

    blockInfo.Coefficients=flipud(blockInfo.Coefficients);



    if inputDim(1)==1

        filterKernelNet=this.elabFIRFilterKernel(topNet,blockInfo,sigInfo);
    else
        filterKernelNet=this.elabFIRFilterKernelMultiPixel(topNet,blockInfo,sigInfo);
    end


    filtervalue=topNet.addSignal(dataOut.Type,'preFilterDataOut');
    preDataOut=topNet.addSignal(dataOut.Type,'preDataOut');
    prehStartOut=topNet.addSignal(ctlType,'prehStartOut');
    prehEndOut=topNet.addSignal(ctlType,'prehEndOut');
    prevStartOut=topNet.addSignal(ctlType,'prevStartOut');
    prevEndOut=topNet.addSignal(ctlType,'prevEndOut');
    preValidOut=topNet.addSignal(ctlType,'preValidOut');





    if~blockInfo.coeffFromPort
        pirelab.instantiateNetwork(topNet,filterKernelNet,...
        [LMKData,LMKhs,LMKhe,LMKvs,LMKve,LMKvl,LMKproc],...
        [filtervalue,prehStartOut,prehEndOut,prevStartOut,prevEndOut,preValidOut],...
        'imagekernel_inst');
    else
        pirelab.instantiateNetwork(topNet,filterKernelNet,...
        [LMKData,LMKhs,LMKhe,LMKvs,LMKve,LMKvl,LMKproc,coeffInReg2],...
        [filtervalue,prehStartOut,prehEndOut,prevStartOut,prevEndOut,preValidOut],...
        'imagekernel_inst');
    end


    zeroOut=topNet.addSignal(dataOut.Type,'zeroOut');
    pirelab.getConstComp(topNet,zeroOut,0,'zeroOut');
    pirelab.getSwitchComp(topNet,[filtervalue,zeroOut],preDataOut,preValidOut,'','==',1);


    pirelab.getIntDelayComp(topNet,preDataOut,dataOut,4);




    pirelab.getIntDelayComp(topNet,prehStartOut,hstartOut,4);
    pirelab.getIntDelayComp(topNet,prehEndOut,hendOut,4);
    pirelab.getIntDelayComp(topNet,prevStartOut,vstartOut,4);
    pirelab.getIntDelayComp(topNet,prevEndOut,vendOut,4);
    pirelab.getIntDelayComp(topNet,preValidOut,validOut,4);
