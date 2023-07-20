function elaborateErosion(this,topNet,blockInfo,inSig,outSig)






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



















    if inputDim==1
        cNet=this.elabErosionCore(topNet,blockInfo,inRate);
        cNet.addComment('Find local minima in binary image');
    else
        cNet=this.elabMultiPixelErosionCore(topNet,blockInfo,inRate);
        cNet.addComment('Find local minima in binary image');
    end



    pirelab.instantiateNetwork(topNet,cNet,[lbufData,lbufhs,lbufhe,lbufvs,lbufve,lbufvalid,processData],...
    [dataOut,hstartOut,hendOut,vstartOut,vendOut,validOut],'ErosionCore');




end
