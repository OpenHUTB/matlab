function elaborateGrayscaleOpening(this,topNet,blockInfo,inSignals,outSignals)












    dataIn=inSignals(1);
    dataRate=dataIn.SimulinkRate;
    hStartIn=inSignals(2);
    hEndIn=inSignals(3);
    vStartIn=inSignals(4);
    vEndIn=inSignals(5);
    validIn=inSignals(6);


    dataOut=outSignals(1);
    hStartOut=outSignals(2);
    hEndOut=outSignals(3);
    vStartOut=outSignals(4);
    vEndOut=outSignals(5);
    validOut=outSignals(6);


    inputWL=dataIn.Type.WordLength;
    inputFL=dataIn.Type.FractionLength;
    inType=dataIn.Type;
    booleanT=pir_boolean_t();
    sigInfo.inType=inType;
    sigInfo.booleanT=booleanT;
    sigInfo.inputWL=inputWL;
    sigInfo.inputFL=inputFL;


    pixelDilateOut=topNet.addSignal2('Type',inType,'Name','PixelErosionOut');
    hStartDilateOut=topNet.addSignal2('Type',booleanT','Name','HStartErosionOut');
    hEndDilateOut=topNet.addSignal2('Type',booleanT,'Name','hEndErosionOut');
    vStartDilateOut=topNet.addSignal2('Type',booleanT,'Name','vStartErosionOut');
    vEndDilateOut=topNet.addSignal2('Type',booleanT,'Name','vStartErosionOut');
    validDilateOut=topNet.addSignal2('Type',booleanT,'Name','vStartErosionOut');
    dilateOut=[pixelDilateOut,hStartDilateOut,hEndDilateOut,vStartDilateOut,vEndDilateOut,validDilateOut];



    erosionBlockInfo=blockInfo;
    dilationBlockInfo=blockInfo;
    if blockInfo.kHeight>1&&any(blockInfo.Neighborhood(:)==false)||(blockInfo.kWidth<8)
        erosionBlockInfo.Algorithm='fullTreeErosion';
        dilationBlockInfo.Algorithm='fullTreeDilation';
    elseif blockInfo.kHeight>1&&all(blockInfo.Neighborhood(:)==true)
        erosionBlockInfo.Algorithm='decompositionErosion';
        dilationBlockInfo.Algorithm='decompositionDilation';
    else
        erosionBlockInfo.Algorithm='vanHerkErosion';
        dilationBlockInfo.Algorithm='vanHerkDilation';

    end
    erosionBlockInfo.Neighborhood=rot90(rot90(blockInfo.Neighborhood));

    grayScaleDilateNet=this.addGrayscaleErosion(topNet,erosionBlockInfo,sigInfo,inSignals,dilateOut);
    gD=pirelab.instantiateNetwork(topNet,grayScaleDilateNet,inSignals,dilateOut,'ErosionCore');

    grayScaleErodeNet=this.addGrayscaleDilation(topNet,dilationBlockInfo,sigInfo,dilateOut,outSignals);
    gE=pirelab.instantiateNetwork(topNet,grayScaleErodeNet,dilateOut,outSignals,'DilationCore');







