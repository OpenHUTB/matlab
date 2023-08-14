function elaborateDemosaic(this,topNet,blockInfo,inSignals,outSignals)










    dataIn=inSignals(1);
    dataRate=dataIn.SimulinkRate;
    hStartIn=inSignals(2);
    hEndIn=inSignals(3);
    vStartIn=inSignals(4);
    vEndIn=inSignals(5);
    validIn=inSignals(6);


    RGB=outSignals(1);
    hStartOut=outSignals(2);
    hEndOut=outSignals(3);
    vStartOut=outSignals(4);
    vEndOut=outSignals(5);
    validOut=outSignals(6);


    inputWL=dataIn.Type.BaseType.WordLength;
    inputFL=dataIn.Type.BaseType.FractionLength;
    inType=dataIn.Type;
    booleanT=pir_boolean_t();
    sigInfo.inType=inType;
    sigInfo.booleanT=booleanT;
    sigInfo.inputWL=inputWL;
    sigInfo.inputFL=inputFL;


    dI=struct(dataIn.Type);
    if isfield(dI,'Dimensions')
        blockInfo.NumPixels=double(dataIn.Type.Dimensions);
    else
        blockInfo.NumPixels=1;
    end




    lineBufferIn=[dataIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn];

    hStartOutLB=topNet.addSignal2('Type',booleanT,'Name','hStartOutLB');
    hEndOutLB=topNet.addSignal2('Type',booleanT,'Name','hEndOutLB');
    vStartOutLB=topNet.addSignal2('Type',booleanT,'Name','vStartOutLB');
    vEndOutLB=topNet.addSignal2('Type',booleanT,'Name','vEndOutLB');
    validOutLB=topNet.addSignal2('Type',booleanT,'Name','validOutLB');
    processDataOut=topNet.addSignal2('Type',booleanT,'Name','processDataOut');

    if strcmpi(blockInfo.Algorithm,'Gradient-corrected linear')
        blockInfo.KernelHeight=5;
        blockInfo.KernelWidth=5;
        blockInfo.PaddingMethod='Symmetric';

        if blockInfo.NumPixels==1
            data1=topNet.addSignal2('Type',inType,'Name','data1');
            data2=topNet.addSignal2('Type',inType,'Name','data2');
            data3=topNet.addSignal2('Type',inType,'Name','data3');
            data4=topNet.addSignal2('Type',inType,'Name','data4');
            data5=topNet.addSignal2('Type',inType,'Name','data5');

            lbufVType=pirelab.getPirVectorType(inType,blockInfo.KernelHeight);
        else
            dataRType=pirelab.createPirArrayType(inType.BaseType,[1,blockInfo.NumPixels]);
            sigInfo.dataRType=dataRType;
            data1=topNet.addSignal2('Type',dataRType,'Name','data1');
            data2=topNet.addSignal2('Type',dataRType,'Name','data2');
            data3=topNet.addSignal2('Type',dataRType,'Name','data3');
            data4=topNet.addSignal2('Type',dataRType,'Name','data4');
            data5=topNet.addSignal2('Type',dataRType,'Name','data5');

            lbufVType=pirelab.createPirArrayType(inType.BaseType,[blockInfo.KernelHeight,blockInfo.NumPixels]);
        end

        dataOut=topNet.addSignal2('Type',lbufVType,'Name','dataOut');
        lineBufNet=this.addLineBuffer(topNet,blockInfo,dataRate,inType);
        lineBufferOut=[dataOut,hStartOutLB,hEndOutLB,vStartOutLB,vEndOutLB,validOutLB,processDataOut];
    else
        blockInfo.KernelHeight=3;
        blockInfo.KernelWidth=3;
        blockInfo.PaddingMethod='Symmetric';

        if blockInfo.NumPixels==1
            data1=topNet.addSignal2('Type',inType,'Name','data1');
            data2=topNet.addSignal2('Type',inType,'Name','data2');
            data3=topNet.addSignal2('Type',inType,'Name','data3');

            lbufVType=pirelab.getPirVectorType(inType,blockInfo.KernelHeight);
        else
            dataRType=pirelab.createPirArrayType(inType.BaseType,[1,blockInfo.NumPixels]);
            sigInfo.dataRType=dataRType;
            data1=topNet.addSignal2('Type',dataRType,'Name','data1');
            data2=topNet.addSignal2('Type',dataRType,'Name','data2');
            data3=topNet.addSignal2('Type',dataRType,'Name','data3');

            lbufVType=pirelab.createPirArrayType(inType.BaseType,[blockInfo.KernelHeight,blockInfo.NumPixels]);
        end

        dataOut=topNet.addSignal2('Type',lbufVType,'Name','dataOut');
        lineBufNet=this.addLineBuffer(topNet,blockInfo,dataRate,inType);
        lineBufferOut=[dataOut,hStartOutLB,hEndOutLB,vStartOutLB,vEndOutLB,validOutLB,processDataOut];
    end

    lB=pirelab.instantiateNetwork(topNet,lineBufNet,lineBufferIn,lineBufferOut,'lineBuffer');
    lB.addComment('LineBuffer');



    if strcmpi(blockInfo.Algorithm,'Gradient-corrected linear')
        if blockInfo.NumPixels==1
            pirelab.getDemuxComp(topNet,dataOut,[data1,data2,data3,data4,data5]);
        else
            pirelab.getSelectorComp(topNet,dataOut,data1,'one-based',{'Index vector (dialog)','Select all'},{1},{num2str(blockInfo.NumPixels)},'2',['dataOut_selector_(1,1:',num2str(blockInfo.NumPixels),')']);
            pirelab.getSelectorComp(topNet,dataOut,data2,'one-based',{'Index vector (dialog)','Select all'},{2},{num2str(blockInfo.NumPixels)},'2',['dataOut_selector_(2,1:',num2str(blockInfo.NumPixels),')']);
            pirelab.getSelectorComp(topNet,dataOut,data3,'one-based',{'Index vector (dialog)','Select all'},{3},{num2str(blockInfo.NumPixels)},'2',['dataOut_selector_(3,1:',num2str(blockInfo.NumPixels),')']);
            pirelab.getSelectorComp(topNet,dataOut,data4,'one-based',{'Index vector (dialog)','Select all'},{4},{num2str(blockInfo.NumPixels)},'2',['dataOut_selector_(4,1:',num2str(blockInfo.NumPixels),')']);
            pirelab.getSelectorComp(topNet,dataOut,data5,'one-based',{'Index vector (dialog)','Select all'},{5},{num2str(blockInfo.NumPixels)},'2',['dataOut_selector_(5,1:',num2str(blockInfo.NumPixels),')']);
        end
        coreNet=this.elaborateGradientCorrectedCore(topNet,blockInfo,sigInfo,dataRate);
        coreIn=[data1,data2,data3,data4,data5,hStartOutLB,hEndOutLB,vStartOutLB,vEndOutLB,validOutLB,processDataOut];
    else
        if blockInfo.NumPixels==1
            pirelab.getDemuxComp(topNet,dataOut,[data1,data2,data3]);
        else
            pirelab.getSelectorComp(topNet,dataOut,data1,'one-based',{'Index vector (dialog)','Select all'},{1},{num2str(blockInfo.NumPixels)},'2',['dataOut_selector_(1,1:',num2str(blockInfo.NumPixels),')']);
            pirelab.getSelectorComp(topNet,dataOut,data2,'one-based',{'Index vector (dialog)','Select all'},{2},{num2str(blockInfo.NumPixels)},'2',['dataOut_selector_(2,1:',num2str(blockInfo.NumPixels),')']);
            pirelab.getSelectorComp(topNet,dataOut,data3,'one-based',{'Index vector (dialog)','Select all'},{3},{num2str(blockInfo.NumPixels)},'2',['dataOut_selector_(3,1:',num2str(blockInfo.NumPixels),')']);
        end
        coreNet=this.elaborateBilinearCore(topNet,blockInfo,sigInfo,dataRate);
        coreIn=[data1,data2,data3,hStartOutLB,hEndOutLB,vStartOutLB,vEndOutLB,validOutLB,processDataOut];
    end

    if blockInfo.NumPixels==1
        R=topNet.addSignal2('Type',inType,'Name','R');
        G=topNet.addSignal2('Type',inType,'Name','G');
        B=topNet.addSignal2('Type',inType,'Name','B');
    else
        R=topNet.addSignal2('Type',dataRType,'Name','R');
        G=topNet.addSignal2('Type',dataRType,'Name','G');
        B=topNet.addSignal2('Type',dataRType,'Name','B');

        dataCType=pirelab.createPirArrayType(inType.BaseType,[blockInfo.NumPixels,1]);

        Rout=topNet.addSignal2('Type',dataCType,'Name','Rout');
        Gout=topNet.addSignal2('Type',dataCType,'Name','Gout');
        Bout=topNet.addSignal2('Type',dataCType,'Name','Bout');
    end












    coreOut=[R,G,B,hStartOut,hEndOut,vStartOut,vEndOut,validOut];
    core=pirelab.instantiateNetwork(topNet,coreNet,coreIn,coreOut,'demosaicCore');
    core.addComment('demosaicCore');

    if blockInfo.NumPixels==1
        pirelab.getMuxComp(topNet,[R,G,B],RGB);
    else
        pirelab.getTransposeComp(topNet,R,Rout);
        pirelab.getTransposeComp(topNet,G,Gout);
        pirelab.getTransposeComp(topNet,B,Bout);

        pirelab.getConcatenateComp(topNet,[Rout,Gout,Bout],RGB,'Multidimensional array','2');
    end