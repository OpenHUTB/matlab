function elaborateGrayscaleDilation(this,topNet,blockInfo,inSignals,outSignals)











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






    lineBufferIn=[dataIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn];

    hStartOutLB=topNet.addSignal2('Type',booleanT,'Name','hStartOutLB');
    hEndOutLB=topNet.addSignal2('Type',booleanT,'Name','hEndOutLB');
    vStartOutLB=topNet.addSignal2('Type',booleanT,'Name','vStartOutLB');
    vEndOutLB=topNet.addSignal2('Type',booleanT,'Name','vEndOutLB');
    validOutLB=topNet.addSignal2('Type',booleanT,'Name','validOutLB');
    processDataOut=topNet.addSignal2('Type',booleanT,'Name','processDataOut');

    if strcmpi(blockInfo.Algorithm,'fullTreeDilation')
        lineBufferBlockInfo.KernelHeight=blockInfo.kHeight;
        lineBufferBlockInfo.KernelWidth=blockInfo.kWidth;
        lineBufferBlockInfo.PaddingMethod='Constant';
        lineBufferBlockInfo.PaddingValue=0;
        lineBufferBlockInfo.MaxLineSize=blockInfo.LineBufferSize;
        lineBufferBlockInfo.Algorithm=blockInfo.Algorithm;
        lineBufferBlockInfo.BiasUp=false;
        lbufVType=pirelab.getPirVectorType(inType,lineBufferBlockInfo.KernelHeight);
        sigInfo.lbufVType=lbufVType;
        dataVectorOut=topNet.addSignal2('Type',lbufVType,'Name','dataVectorOut');
        lineBufNet=this.addLineBuffer(topNet,lineBufferBlockInfo,dataRate,inType);
        lineBufferOut=[dataVectorOut,hStartOutLB,hEndOutLB,vStartOutLB,vEndOutLB,validOutLB,processDataOut];
    elseif strcmpi(blockInfo.Algorithm,'decompositionDilation')
        lineBufferBlockInfo.KernelHeight=1;
        lineBufferBlockInfo.KernelWidth=blockInfo.kWidth-1;
        lineBufferBlockInfo.PaddingMethod='Constant';
        lineBufferBlockInfo.PaddingValue=0;
        lineBufferBlockInfo.MaxLineSize=blockInfo.LineBufferSize;
        lineBufferBlockInfo.Algorithm='vanHerkDilation';
        lineBufferBlockInfo.BiasUp=false;
        lbufVType=pirelab.getPirVectorType(inType,blockInfo.kHeight);
        sigInfo.lbufVType=lbufVType;
        dataOutLB=topNet.addSignal2('Type',inType,'Name','dataVectorOut');
        lineBufNet=this.addLineBuffer(topNet,lineBufferBlockInfo,dataRate,inType);
        lineBufferOut=[dataOutLB,hStartOutLB,hEndOutLB,vStartOutLB,vEndOutLB,validOutLB,processDataOut];
    else
        lineBufferBlockInfo.KernelHeight=blockInfo.kHeight;
        lineBufferBlockInfo.KernelWidth=(blockInfo.kWidth-1);
        lineBufferBlockInfo.PaddingMethod='Constant';
        lineBufferBlockInfo.PaddingValue=0;
        lineBufferBlockInfo.Algorithm=blockInfo.Algorithm;
        lineBufferBlockInfo.MaxLineSize=blockInfo.LineBufferSize;
        lineBufferBlockInfo.BiasUp=false;
        dataOutLB=topNet.addSignal2('Type',inType,'Name','dataOut');
        lineBufNet=this.addLineBuffer(topNet,lineBufferBlockInfo,dataRate,inType);
        lineBufferOut=[dataOutLB,hStartOutLB,hEndOutLB,vStartOutLB,vEndOutLB,validOutLB,processDataOut];
    end

    lB=pirelab.instantiateNetwork(topNet,lineBufNet,lineBufferIn,lineBufferOut,'lineBuffer');
    lB.addComment('LineBuffer');



    if strcmpi(blockInfo.Algorithm,'fullTreeDilation')
        coreNet=this.elaboratefullTreeDilation(topNet,blockInfo,sigInfo,dataRate);
        coreIn=[dataVectorOut,hStartOutLB,hEndOutLB,vStartOutLB,vEndOutLB,validOutLB,processDataOut];
    elseif strcmpi(blockInfo.Algorithm,'decompositionDilation')
        coreNet=this.elaborateDecompositionDilation(topNet,blockInfo,sigInfo,dataRate);
        coreIn=[dataOutLB,hStartOutLB,hEndOutLB,vStartOutLB,vEndOutLB,validOutLB,processDataOut];
    else
        coreNet=this.elaborateVanHerkDilation(topNet,blockInfo,sigInfo,dataRate);
        coreIn=[dataOutLB,hStartOutLB,hEndOutLB,vStartOutLB,vEndOutLB,validOutLB,processDataOut];
    end



    coreOut=[dataOut,hStartOut,hEndOut,vStartOut,vEndOut,validOut];

    core=pirelab.instantiateNetwork(topNet,coreNet,coreIn,coreOut,'dilationCore');
    core.addComment('dilationCore');







