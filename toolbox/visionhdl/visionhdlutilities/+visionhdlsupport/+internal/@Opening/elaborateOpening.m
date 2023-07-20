function elaborateOpening(this,topNet,blockInfo,inSig,outSig)






    dataIn=inSig(1);
    hstartIn=inSig(2);
    hendIn=inSig(3);
    vstartIn=inSig(4);
    vendIn=inSig(5);
    validIn=inSig(6);


    dataOut=outSig(1);
    hstartOut=outSig(2);
    hendOut=outSig(3);
    vstartOut=outSig(4);
    vendOut=outSig(5);
    validOut=outSig(6);




    boolType=pir_boolean_t();
    dI=struct(dataIn.Type);

    if isfield(dI,'Dimensions')
        inputDim=dataIn.Type.Dimensions;
    else
        inputDim=1;
    end

    dataInType=dataIn.Type;

    if inputDim==1
        lbufVType=pirelab.getPirVectorType(boolType,blockInfo.kHeight);
        blockInfo.NumberOfPixels=1;
    else
        lbufVType=pirelab.createPirArrayType(boolType,[blockInfo.kHeight,dataInType.Dimensions]);
        blockInfo.NumberOfPixels=dataInType.Dimensions;
    end
    blockInfo.lbufVType=lbufVType;

    pixelOType=pirelab.getPirVectorType(boolType,blockInfo.NumberOfPixels);








    lbufData=topNet.addSignal(lbufVType,'lbufData');
    lbufhs=topNet.addSignal(boolType,'lbufhstart');
    lbufhe=topNet.addSignal(boolType,'lbufhend');
    lbufvs=topNet.addSignal(boolType,'lbufvstart');
    lbufve=topNet.addSignal(boolType,'lbufvend');
    lbufvalid=topNet.addSignal(boolType,'lbufvalid');
    processData=topNet.addSignal(boolType,'processData');



    lbufInfo.KernelHeight=blockInfo.kHeight;
    lbufInfo.KernelWidth=blockInfo.kWidth;
    lbufInfo.PaddingMethod=blockInfo.PaddingMethod;
    if strcmpi(blockInfo.PaddingMethod,'None')
        lbufInfo.PaddingValue=0;
    else
        lbufInfo.PaddingValue=1;
    end
    lbufInfo.MaxLineSize=blockInfo.LinebufferSize;
    lbufInfo.BiasUp=true;



    if mod(blockInfo.kHeight,2)==0
        lbufInfo.effectiveKernelHeight=blockInfo.kHeight+1;
    else
        lbufInfo.effectiveKernelHeight=blockInfo.kHeight;
    end

    if mod(blockInfo.kWidth,2)==0

        lbufInfo.effectiveKernelWidth=blockInfo.kWidth+1;
    else
        lbufInfo.effectiveKernelWidth=blockInfo.kWidth;
    end

    inRate=dataIn.SimulinkRate;

    lbufNet=this.addLineBuffer(topNet,lbufInfo,inRate);

    pirelab.instantiateNetwork(topNet,lbufNet,[dataIn,hstartIn,hendIn,vstartIn,vendIn,validIn],...
    [lbufData,lbufhs,lbufhe,lbufvs,lbufve,lbufvalid,processData],'LineBuffer');






    epixelOut=topNet.addSignal(pixelOType,'epixelOut');
    ehsOut=topNet.addSignal(boolType,'ehsOut');
    eheOut=topNet.addSignal(boolType,'eheOut');
    evsOut=topNet.addSignal(boolType,'evsOut');
    eveOut=topNet.addSignal(boolType,'eveOut');
    evalidOut=topNet.addSignal(boolType,'evalidOut');

    if inputDim==1
        eNet=this.elabErosionCore(topNet,blockInfo,inRate);
    else
        eNet=this.elabMultiPixelErosionCore(topNet,blockInfo,inRate);
    end




    pirelab.instantiateNetwork(topNet,eNet,[lbufData,lbufhs,lbufhe,lbufvs,lbufve,lbufvalid,processData],...
    [epixelOut,ehsOut,eheOut,evsOut,eveOut,evalidOut],'ErosionCore');







    dlbufData=topNet.addSignal(lbufVType,'dlbufData');
    dlbufhs=topNet.addSignal(boolType,'dlbufhstart');
    dlbufhe=topNet.addSignal(boolType,'dlbufhend');
    dlbufvs=topNet.addSignal(boolType,'dlbufvstart');
    dlbufve=topNet.addSignal(boolType,'dlbufvend');
    dlbufvalid=topNet.addSignal(boolType,'dlbufvalid');
    dprocessData=topNet.addSignal(boolType,'dprocessData');



    lbufInfo.KernelHeight=blockInfo.kHeight;
    lbufInfo.KernelWidth=blockInfo.kWidth;
    lbufInfo.PaddingMethod=blockInfo.PaddingMethod;
    lbufInfo.PaddingValue=0;
    lbufInfo.MaxLineSize=blockInfo.LinebufferSize;
    lbufInfo.BiasUp=false;

    if mod(blockInfo.kHeight,2)==0
        lbufInfo.effectiveKernelHeight=blockInfo.kHeight+1;
    else
        lbufInfo.effectiveKernelHeight=blockInfo.kHeight;
    end

    if mod(blockInfo.kWidth,2)==0

        lbufInfo.effectiveKernelWidth=blockInfo.kWidth+1;
    else
        lbufInfo.effectiveKernelWidth=blockInfo.kWidth;
    end

    inRate=dataIn.SimulinkRate;

    dlbufNet=this.addLineBuffer(topNet,lbufInfo,inRate);

    pirelab.instantiateNetwork(topNet,dlbufNet,[epixelOut,ehsOut,eheOut,evsOut,eveOut,evalidOut],...
    [dlbufData,dlbufhs,dlbufhe,dlbufvs,dlbufve,dlbufvalid,dprocessData],'dLineBuffer');



    if inputDim==1
        dNet=this.elabDilationCore(topNet,blockInfo,inRate);
    else
        dNet=this.elabMultiPixelDilationCore(topNet,blockInfo,inRate);
    end


    pirelab.instantiateNetwork(topNet,dNet,[dlbufData,dlbufhs,dlbufhe,dlbufvs,dlbufve,dlbufvalid,dprocessData],...
    [dataOut,hstartOut,hendOut,vstartOut,vendOut,validOut],'DilationCore');

end
