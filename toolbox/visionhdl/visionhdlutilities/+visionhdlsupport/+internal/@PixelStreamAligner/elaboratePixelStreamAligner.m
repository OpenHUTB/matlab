function topNet=elaboratePixelStreamAligner(this,topNet,blockInfo,inSig,outSig)







    pixelIn=inSig(1);
    hstartIn=inSig(2);
    hendIn=inSig(3);
    vstartIn=inSig(4);
    vendIn=inSig(5);
    validIn=inSig(6);


    refpixelIn=inSig(7);
    refhstartIn=inSig(8);
    refhendIn=inSig(9);
    refvstartIn=inSig(10);
    refvendIn=inSig(11);
    refvalidIn=inSig(12);



    pixelOut=outSig(1);
    refpixelOut=outSig(2);
    refhstartOut=outSig(3);
    refhendOut=outSig(4);
    refvstartOut=outSig(5);
    refvendOut=outSig(6);
    refvalidOut=outSig(7);


    inRate=inSig(1).SimulinkRate;
    for ii=1:numel(outSig)
        sig=outSig(ii);
        sig.SimulinkRate=inRate;
    end


    if inSig(1).Type.isArrayType
        inDim=length(pixelIn.Type.Dimensions);
    else
        inDim=1;
    end

    if inDim>1
        pixelInCompType=pirelab.createPirArrayType(pixelIn.Type.BaseType,[pixelIn.Type.Dimensions(1),1]);
        signal1=topNet.addSignal(pixelInCompType,'Signal1');
        signal1.SimulinkRate=inRate;
        signal2=topNet.addSignal(pixelInCompType,'Signal2');
        signal2.SimulinkRate=inRate;
        signal3=topNet.addSignal(pixelInCompType,'Signal3');
        signal3.SimulinkRate=inRate;
        pirelab.getSelectorComp(topNet,pixelIn,signal1,'One-based',{'Select all','Index vector (dialog)'},{1,1},{'Inherit from "Index"'},'2','Selector1');
        pirelab.getSelectorComp(topNet,pixelIn,signal2,'One-based',{'Select all','Index vector (dialog)'},{1,2},{'Inherit from "Index"'},'2','Selector2');
        pirelab.getSelectorComp(topNet,pixelIn,signal3,'One-based',{'Select all','Index vector (dialog)'},{1,3},{'Inherit from "Index"'},'2','Selector3');
        [pixelIn11,pixelIn11Type]=demuxComponents(topNet,signal1);
        [pixelIn22,pixelIn22Type]=demuxComponents(topNet,signal2);
        [pixelIn33,pixelIn33Type]=demuxComponents(topNet,signal3);
        if pixelIn.Type.Dimensions(2)==4
            signal4=topNet.addSignal(pixelInCompType,'Signal4');
            signal4.SimulinkRate=inRate;
            pirelab.getSelectorComp(topNet,pixelIn,signal4,'One-based',{'Select all','Index vector (dialog)'},{1,4},{'Inherit from "Index"'},'2','Selector4');
            [pixelIn44,pixelIn44Type]=demuxComponents(topNet,signal4);
        end
        refpixelInCompType=pirelab.createPirArrayType(refpixelIn.Type.BaseType,[refpixelIn.Type.Dimensions(1),1]);
        refsignal1=topNet.addSignal(refpixelInCompType,'refSignal1');
        refsignal1.SimulinkRate=inRate;
        refsignal2=topNet.addSignal(refpixelInCompType,'refSignal2');
        refsignal2.SimulinkRate=inRate;
        refsignal3=topNet.addSignal(refpixelInCompType,'refSignal3');
        refsignal3.SimulinkRate=inRate;
        pirelab.getSelectorComp(topNet,refpixelIn,refsignal1,'One-based',{'Select all','Index vector (dialog)'},{1,1},{'Inherit from "Index"'},'2','RefSelector1');
        pirelab.getSelectorComp(topNet,refpixelIn,refsignal2,'One-based',{'Select all','Index vector (dialog)'},{1,2},{'Inherit from "Index"'},'2','RefSelector2');
        pirelab.getSelectorComp(topNet,refpixelIn,refsignal3,'One-based',{'Select all','Index vector (dialog)'},{1,3},{'Inherit from "Index"'},'2','RefSelector3');
        [refpixelIn11,refpixelIn11Type]=demuxComponents(topNet,refsignal1);
        [refpixelIn22,refpixelIn22Type]=demuxComponents(topNet,refsignal2);
        [refpixelIn33,refpixelIn33Type]=demuxComponents(topNet,refsignal3);
        if refpixelIn.Type.Dimensions(2)==4
            refsignal4=topNet.addSignal(refpixelInCompType,'refSignal4');
            refsignal4.SimulinkRate=inRate;
            pirelab.getSelectorComp(topNet,refpixelIn,refsignal4,'One-based',{'Select all','Index vector (dialog)'},{1,4},{'Inherit from "Index"'},'2','RefSelector4');
            [refpixelIn44,refpixelIn44Type]=demuxComponents(topNet,refsignal4);
        end

    else
        [pixelIn,pixelInType]=demuxComponents(topNet,pixelIn);
        [refpixelIn,refpixelInType]=demuxComponents(topNet,refpixelIn);
    end




    RAMsize=double((ceil((log2(blockInfo.LineBufferSize)))))+...
    double((ceil((log2(blockInfo.MaximumNumberOfLines)))));
    RAMaddrtype=pir_ufixpt_t(RAMsize,0);

    lineStartSize=double((ceil((log2(blockInfo.MaximumNumberOfLines)))));
    lineaddrtype=pir_ufixpt_t(lineStartSize,0);




    if inDim>1
        pixelInReg1=newSignalLike(topNet,'pixelInReg1',pixelIn11);
        pixelInReg2=newSignalLike(topNet,'pixelInReg2',pixelIn22);
        pixelInReg3=newSignalLike(topNet,'pixelInReg3',pixelIn33);
        if pixelIn.Type.Dimensions(2)==4
            pixelInReg4=newSignalLike(topNet,'pixelInReg4',pixelIn44);
        end

    else
        pixelInReg=newSignalLike(topNet,'pixelInReg',pixelIn);
    end
    hStartInReg=newControlSignal(topNet,'pixelHStartInReg',inRate);
    hEndInReg=newControlSignal(topNet,'pixelHEndInReg',inRate);
    vStartInReg=newControlSignal(topNet,'pixelVStartInReg',inRate);
    vEndInReg=newControlSignal(topNet,'pixelVEndInReg',inRate);
    validInReg=newControlSignal(topNet,'pixelValidInReg',inRate);

    if inDim>1

        for ii=1:length(pixelIn11)
            pirelab.getUnitDelayComp(topNet,pixelIn11(ii),pixelInReg1(ii),'pixelIReg1',0);
            pirelab.getUnitDelayComp(topNet,pixelIn22(ii),pixelInReg2(ii),'pixelIReg2',0);
            pirelab.getUnitDelayComp(topNet,pixelIn33(ii),pixelInReg3(ii),'pixelIReg3',0);
        end
        if pixelIn.Type.Dimensions(2)==4
            for ii=1:length(pixelIn11)
                pirelab.getUnitDelayComp(topNet,pixelIn44(ii),pixelInReg4(ii),'pixelIReg4',0);
            end
        end
    else

        if length(pixelIn)>1
            for ii=1:length(pixelIn)
                pirelab.getUnitDelayComp(topNet,pixelIn(ii),pixelInReg(ii),'pixelIReg',0);
            end
        else

            pirelab.getUnitDelayComp(topNet,pixelIn,pixelInReg,'pixelIReg',0);
        end
    end
    pirelab.getUnitDelayComp(topNet,hstartIn,hStartInReg,'hSIReg',0);
    pirelab.getUnitDelayComp(topNet,hendIn,hEndInReg,'hEIReg',0);
    pirelab.getUnitDelayComp(topNet,vstartIn,vStartInReg,'vSIReg',0);
    pirelab.getUnitDelayComp(topNet,vendIn,vEndInReg,'vEIReg',0);
    pirelab.getUnitDelayComp(topNet,validIn,validInReg,'valIReg',0);

    if inDim>1

        refpixelInReg1=newSignalLike(topNet,'refpixelInReg1',refpixelIn11);
        refpixelInReg2=newSignalLike(topNet,'refpixelInReg2',refpixelIn22);
        refpixelInReg3=newSignalLike(topNet,'refpixelInReg3',refpixelIn33);
        if refpixelIn.Type.Dimensions(2)==4
            refpixelInReg4=newSignalLike(topNet,'refpixelInReg4',refpixelIn44);
        end
    else
        refpixelInReg=newSignalLike(topNet,'refpixelInReg',refpixelIn);
    end
    refhStartInReg=newControlSignal(topNet,'refHStartInReg',inRate);
    refhEndInReg=newControlSignal(topNet,'refHEndInReg',inRate);
    refvStartInReg=newControlSignal(topNet,'refVStartInReg',inRate);
    refvEndInReg=newControlSignal(topNet,'refVEndInReg',inRate);
    refvalidInReg=newControlSignal(topNet,'refValidInReg',inRate);

    if inDim>1

        for ii=1:length(refpixelIn11)
            pirelab.getUnitDelayComp(topNet,refpixelIn11(ii),refpixelInReg1(ii),'refpixelIReg1',0);
            pirelab.getUnitDelayComp(topNet,refpixelIn22(ii),refpixelInReg2(ii),'refpixelIReg2',0);
            pirelab.getUnitDelayComp(topNet,refpixelIn33(ii),refpixelInReg3(ii),'refpixelIReg3',0);
        end
        if refpixelIn.Type.Dimensions(2)==4
            for ii=1:length(refpixelIn11)
                pirelab.getUnitDelayComp(topNet,refpixelIn44(ii),refpixelInReg4(ii),'refpixelIReg4',0);
            end
        end
    else

        if length(refpixelIn)>1
            for ii=1:length(refpixelIn)
                pirelab.getUnitDelayComp(topNet,refpixelIn(ii),refpixelInReg(ii),'refpixelIReg',0);
            end
        else

            pirelab.getUnitDelayComp(topNet,refpixelIn,refpixelInReg,'refpixelIReg',0);
        end
    end
    pirelab.getUnitDelayComp(topNet,refhstartIn,refhStartInReg,'rhSIReg',0);
    pirelab.getUnitDelayComp(topNet,refhendIn,refhEndInReg,'rhEIReg',0);
    pirelab.getUnitDelayComp(topNet,refvstartIn,refvStartInReg,'rvSIReg',0);
    pirelab.getUnitDelayComp(topNet,refvendIn,refvEndInReg,'rvEIReg',0);
    pirelab.getUnitDelayComp(topNet,refvalidIn,refvalidInReg,'rvalIReg',0);


    if inDim>1

        refpixelOutReg1=newSignalLike(topNet,'refpixelOutReg1',refpixelIn11);
        refpixelOutReg2=newSignalLike(topNet,'refpixelOutReg2',refpixelIn22);
        refpixelOutReg3=newSignalLike(topNet,'refpixelOutReg3',refpixelIn33);
        if pixelIn.Type.Dimensions(2)==4
            refpixelOutReg4=newSignalLike(topNet,'refpixelOutReg4',refpixelIn44);
        end
    else

        pixelOutReg=newSignalLike(topNet,'pixelOutReg',pixelIn);
        refpixelOutReg=newSignalLike(topNet,'refpixelOutReg',refpixelIn);
    end
    hStartOutReg=newControlSignal(topNet,'pixelHStartOutReg',inRate);
    hEndOutReg=newControlSignal(topNet,'pixelHEndOutReg',inRate);
    vStartOutReg=newControlSignal(topNet,'pixelVStartOutReg',inRate);
    vEndOutReg=newControlSignal(topNet,'pixelVEndOutReg',inRate);
    validOutReg=newControlSignal(topNet,'pixelValidOutReg',inRate);


    if inDim==1
        if length(pixelIn)>1
            pixelRegOutMux=newSignalLike(topNet,'pixelRegOutMux',pixelIn);
            for ii=1:length(pixelIn)
                pirelab.getUnitDelayComp(topNet,pixelOutReg(ii),pixelRegOutMux(ii),'pixelOReg',0);
            end
            pirelab.getMuxComp(topNet,pixelRegOutMux,pixelOut);
        else

            pirelab.getUnitDelayComp(topNet,pixelOutReg,pixelOut,'pixelOReg',0);
        end
    end
    if inDim>1

        refpixelRegOutMux1=newSignalLike(topNet,'refpixelRegOutMux1',refpixelIn11);
        refpixelRegOutMux2=newSignalLike(topNet,'refpixelRegOutMux2',refpixelIn22);
        refpixelRegOutMux3=newSignalLike(topNet,'refpixelRegOutMux3',refpixelIn33);
        for ii=1:length(refpixelIn11)
            pirelab.getUnitDelayComp(topNet,refpixelOutReg1(ii),refpixelRegOutMux1(ii),'refpixelOReg1',0);
            pirelab.getUnitDelayComp(topNet,refpixelOutReg2(ii),refpixelRegOutMux2(ii),'refpixelOReg2',0);
            pirelab.getUnitDelayComp(topNet,refpixelOutReg3(ii),refpixelRegOutMux3(ii),'refpixelOReg3',0);
        end
        if refpixelIn.Type.Dimensions(2)==4
            refpixelRegOutMux4=newSignalLike(topNet,'refpixelRegOutMux4',refpixelIn44);
            for ii=1:length(refpixelIn11)
                pirelab.getUnitDelayComp(topNet,refpixelOutReg4(ii),refpixelRegOutMux4(ii),'refpixelOReg4',0);
            end
        end
        refpixelOut1=topNet.addSignal(refpixelInCompType,'refPixelOut1');
        refpixelOut1.SimulinkRate=inRate;
        refpixelOut2=topNet.addSignal(refpixelInCompType,'refpixelOut2');
        refpixelOut2.SimulinkRate=inRate;
        refpixelOut3=topNet.addSignal(refpixelInCompType,'refpixelOut3');
        refpixelOut3.SimulinkRate=inRate;
        pirelab.getMuxComp(topNet,refpixelRegOutMux1,refpixelOut1);
        pirelab.getMuxComp(topNet,refpixelRegOutMux2,refpixelOut2);
        pirelab.getMuxComp(topNet,refpixelRegOutMux3,refpixelOut3);
        if refpixelIn.Type.Dimensions(2)==4
            refpixelOut4=topNet.addSignal(pixelInCompType,'refpixelOut4');
            refpixelOut4.SimulinkRate=inRate;
            pirelab.getMuxComp(topNet,refpixelRegOutMux4,refpixelOut4);
            pirelab.getConcatenateComp(topNet,[refpixelOut1,refpixelOut2,refpixelOut3,refpixelOut4],refpixelOut,'Multidimensional array','2');
        else
            pirelab.getConcatenateComp(topNet,[refpixelOut1,refpixelOut2,refpixelOut3],refpixelOut,'Multidimensional array','2');
        end
    else

        if length(refpixelIn)>1
            refpixelRegOutMux=newSignalLike(topNet,'refpixelRegOutMux',refpixelIn);
            for ii=1:length(refpixelIn)
                pirelab.getUnitDelayComp(topNet,refpixelOutReg(ii),refpixelRegOutMux(ii),'refpixelOReg',0);
            end
            pirelab.getMuxComp(topNet,refpixelRegOutMux,refpixelOut);
        else

            pirelab.getUnitDelayComp(topNet,refpixelOutReg,refpixelOut,'refpixelOReg',0);
        end
    end

    pirelab.getUnitDelayComp(topNet,hStartOutReg,refhstartOut,'refhSOReg',0);
    pirelab.getUnitDelayComp(topNet,hEndOutReg,refhendOut,'refhEOReg',0);
    pirelab.getUnitDelayComp(topNet,vStartOutReg,refvstartOut,'refvSOReg',0);
    pirelab.getUnitDelayComp(topNet,vEndOutReg,refvendOut,'refvEOReg',0);
    pirelab.getUnitDelayComp(topNet,validOutReg,refvalidOut,'refvalOReg',0);



    [pixelInFrame,pixelInLine,pixelNewFrame,pixelNewLine,pixelInFramePrev,pixelInLinePrev]=...
    lineframeFSM(topNet,hStartInReg,hEndInReg,vStartInReg,vEndInReg,validInReg,inRate,'pixel');
    if inDim==1
        pixelInRegDly=newSignalLike(topNet,'pixelInRegDly',pixelIn);
    end
    validInRegDly=newControlSignal(topNet,'pixelValidInRegDly',inRate);
    if inDim==1
        if length(pixelIn)>1
            for ii=1:length(pixelIn)
                pirelab.getUnitDelayComp(topNet,pixelInReg(ii),pixelInRegDly(ii),'pixelIRegDly',0);
            end
        else
            pirelab.getUnitDelayComp(topNet,pixelInReg,pixelInRegDly,'pixelIRegDly',0);
        end
    end
    pirelab.getUnitDelayComp(topNet,validInReg,validInRegDly,'valIRegDly',0);

    ramwren=newControlSignal(topNet,'RAMwren',inRate);
    ramwrtone=newControlSignal(topNet,'RAMwtone',inRate);
    ramwrttwo=newControlSignal(topNet,'RAMwttwo',inRate);
    pirelab.getBitwiseOpComp(topNet,[pixelInFrame,pixelNewFrame],ramwrtone,'OR');
    pirelab.getBitwiseOpComp(topNet,[pixelInLine,pixelNewLine],ramwrttwo,'OR');
    pirelab.getBitwiseOpComp(topNet,[ramwrtone,ramwrttwo,validInReg],ramwren,'AND');

    ramrden=newControlSignal(topNet,'RAMrden',inRate);
    addrmatch=newControlSignal(topNet,'addrmatch',inRate);
    notholdaddr=newControlSignal(topNet,'notholdaddr',inRate);
    ramwraddr=newDataSignal(topNet,'RAMwraddr',RAMaddrtype,inRate);
    ramrdaddr=newDataSignal(topNet,'RAMrdaddr',RAMaddrtype,inRate);
    ramrdnextaddr=newDataSignal(topNet,'RAMrdnextaddr',RAMaddrtype,inRate);
    constone=newDataSignal(topNet,'constone',RAMaddrtype,inRate);
    pirelab.getConstComp(topNet,constone,1,'constoneadd');
    ramrdloadval=newDataSignal(topNet,'RAMrdloadval',RAMaddrtype,inRate);
    ramrdload=newControlSignal(topNet,'RAMrdload',inRate);


    ramrddata=newSignalLike(topNet,'RAMrddata',pixelIn);

    pirelab.getCounterComp(topNet,ramwren,ramwraddr,...
    'Count limited',...
    0.0,...
    1.0,...
    2^RAMsize-1,...
    false,...
    false,...
    true,...
    false,...
    'wraddrcounter');

    pirelab.getCounterComp(topNet,[ramrdload,ramrdloadval,ramrden],ramrdaddr,...
    'Count limited',...
    0.0,...
    1.0,...
    2^RAMsize-1,...
    false,...
    true,...
    true,...
    false,...
    'rdaddrcounter');

    pirelab.getAddComp(topNet,[ramrdaddr,constone],ramrdnextaddr,'Floor','Wrap');
    if inDim>1
        ramType=pirelab.createPirArrayType(pixelIn.Type.BaseType,[1,pixelIn.Type.Dimensions(2)]);
        ram_inData1=topNet.addSignal(ramType,'RAMInData1');
        ram_inData2=topNet.addSignal(ramType,'RAMInData2');


        if pixelIn.Type.Dimensions(1)==4||pixelIn.Type.Dimensions(1)==8
            ram_inData3=topNet.addSignal(ramType,'RAMInData3');
            ram_inData4=topNet.addSignal(ramType,'RAMInData4');
        end

        if pixelIn.Type.Dimensions(1)==8
            ram_inData5=topNet.addSignal(ramType,'RAMInData5');
            ram_inData6=topNet.addSignal(ramType,'RAMInData6');
            ram_inData7=topNet.addSignal(ramType,'RAMInData7');
            ram_inData8=topNet.addSignal(ramType,'RAMInData8');
        end
        ram_outData1=topNet.addSignal(ramType,'RAMOutData1');
        ram_outData1.SimulinkRate=inRate;
        ram_outData2=topNet.addSignal(ramType,'RAMOutData2');
        ram_outData2.SimulinkRate=inRate;


        if(pixelIn.Type.Dimensions(1)==4||pixelIn.Type.Dimensions(1)==8)
            ram_outData3=topNet.addSignal(ramType,'RAMOutData3');
            ram_outData3.SimulinkRate=inRate;
            ram_outData4=topNet.addSignal(ramType,'RAMOutData4');
            ram_outData4.SimulinkRate=inRate;
        end


        if pixelIn.Type.Dimensions(1)==8
            ram_outData5=topNet.addSignal(ramType,'RAMOutData5');
            ram_outData5.SimulinkRate=inRate;
            ram_outData6=topNet.addSignal(ramType,'RAMOutData6');
            ram_outData6.SimulinkRate=inRate;
            ram_outData7=topNet.addSignal(ramType,'RAMOutData7');
            ram_outData7.SimulinkRate=inRate;
            ram_outData8=topNet.addSignal(ramType,'RAMOutData8');
            ram_outData8.SimulinkRate=inRate;
        end
        if pixelIn.Type.Dimensions(2)==4
            pirelab.getConcatenateComp(topNet,[pixelInReg1(1),pixelInReg2(1),pixelInReg3(1),pixelInReg4(1)],ram_inData1,'Multidimensional array','2');
            pirelab.getConcatenateComp(topNet,[pixelInReg1(2),pixelInReg2(2),pixelInReg3(2),pixelInReg4(2)],ram_inData2,'Multidimensional array','2');
        else
            pirelab.getConcatenateComp(topNet,[pixelInReg1(1),pixelInReg2(1),pixelInReg3(1)],ram_inData1,'Multidimensional array','2');
            pirelab.getConcatenateComp(topNet,[pixelInReg1(2),pixelInReg2(2),pixelInReg3(2)],ram_inData2,'Multidimensional array','2');
        end
        ram_inSignal1=[ram_inData1,ramwraddr,ramwren,ramrdaddr];
        pirelab.getSimpleDualPortRamComp(topNet,ram_inSignal1,ram_outData1,'pixelRAM1');

        ram_inSignal2=[ram_inData2,ramwraddr,ramwren,ramrdaddr];
        pirelab.getSimpleDualPortRamComp(topNet,ram_inSignal2,ram_outData2,'pixelRAM2');

        if pixelIn.Type.Dimensions(1)==4||pixelIn.Type.Dimensions(1)==8
            if pixelIn.Type.Dimensions(2)==4
                pirelab.getConcatenateComp(topNet,[pixelInReg1(3),pixelInReg2(3),pixelInReg3(3),pixelInReg4(3)],ram_inData3,'Multidimensional array','2');
                pirelab.getConcatenateComp(topNet,[pixelInReg1(4),pixelInReg2(4),pixelInReg3(4),pixelInReg4(4)],ram_inData4,'Multidimensional array','2');
            else
                pirelab.getConcatenateComp(topNet,[pixelInReg1(3),pixelInReg2(3),pixelInReg3(3)],ram_inData3,'Multidimensional array','2');
                pirelab.getConcatenateComp(topNet,[pixelInReg1(4),pixelInReg2(4),pixelInReg3(4)],ram_inData4,'Multidimensional array','2');
            end

            ram_inSignal3=[ram_inData3,ramwraddr,ramwren,ramrdaddr];
            pirelab.getSimpleDualPortRamComp(topNet,ram_inSignal3,ram_outData3,'pixelRAM3');

            ram_inSignal4=[ram_inData4,ramwraddr,ramwren,ramrdaddr];
            pirelab.getSimpleDualPortRamComp(topNet,ram_inSignal4,ram_outData4,'pixelRAM4');
        end

        if pixelIn.Type.Dimensions(1)==8
            if pixelIn.Type.Dimensions(2)==4
                pirelab.getConcatenateComp(topNet,[pixelInReg1(5),pixelInReg2(5),pixelInReg3(5),pixelInReg4(5)],ram_inData5,'Multidimensional array','2');
                pirelab.getConcatenateComp(topNet,[pixelInReg1(6),pixelInReg2(6),pixelInReg3(6),pixelInReg4(6)],ram_inData6,'Multidimensional array','2');
                pirelab.getConcatenateComp(topNet,[pixelInReg1(7),pixelInReg2(7),pixelInReg3(7),pixelInReg4(7)],ram_inData7,'Multidimensional array','2');
                pirelab.getConcatenateComp(topNet,[pixelInReg1(8),pixelInReg2(8),pixelInReg3(8),pixelInReg4(8)],ram_inData8,'Multidimensional array','2');
            else
                pirelab.getConcatenateComp(topNet,[pixelInReg1(5),pixelInReg2(5),pixelInReg3(5)],ram_inData5,'Multidimensional array','2');
                pirelab.getConcatenateComp(topNet,[pixelInReg1(6),pixelInReg2(6),pixelInReg3(6)],ram_inData6,'Multidimensional array','2');
                pirelab.getConcatenateComp(topNet,[pixelInReg1(7),pixelInReg2(7),pixelInReg3(7)],ram_inData7,'Multidimensional array','2');
                pirelab.getConcatenateComp(topNet,[pixelInReg1(8),pixelInReg2(8),pixelInReg3(8)],ram_inData8,'Multidimensional array','2');
            end
            ram_inSignal5=[ram_inData5,ramwraddr,ramwren,ramrdaddr];
            pirelab.getSimpleDualPortRamComp(topNet,ram_inSignal5,ram_outData5,'pixelRAM5');

            ram_inSignal6=[ram_inData6,ramwraddr,ramwren,ramrdaddr];
            pirelab.getSimpleDualPortRamComp(topNet,ram_inSignal6,ram_outData6,'pixelRAM6');

            ram_inSignal7=[ram_inData7,ramwraddr,ramwren,ramrdaddr];
            pirelab.getSimpleDualPortRamComp(topNet,ram_inSignal7,ram_outData7,'pixelRAM7');

            ram_inSignal8=[ram_inData8,ramwraddr,ramwren,ramrdaddr];
            pirelab.getSimpleDualPortRamComp(topNet,ram_inSignal8,ram_outData8,'pixelRAM8');
        end
    else

        if length(pixelIn)>1
            for ii=1:length(pixelIn)
                ram_insigs=[pixelInReg(ii),ramwraddr,ramwren,ramrdaddr];
                pirelab.getSimpleDualPortRamComp(topNet,ram_insigs,ramrddata(ii),'pixelRAM');
            end
        else

            ram_insigs=[pixelInReg,ramwraddr,ramwren,ramrdaddr];
            pirelab.getSimpleDualPortRamComp(topNet,ram_insigs,ramrddata,'pixelRAM');
        end
    end

    if inDim>1

        refpixeldly1=newSignalLike(topNet,'refpixeldly1',refpixelIn11);
        refpixeldly2=newSignalLike(topNet,'refpixeldly2',refpixelIn22);
        refpixeldly3=newSignalLike(topNet,'refpixeldly3',refpixelIn33);
        if refpixelIn.Type.Dimensions(2)==4
            refpixeldly4=newSignalLike(topNet,'refpixeldly4',refpixelIn44);
        end
        refzeroconst=newDataSignal(topNet,'refzeroconst',refpixelIn11Type,inRate);
        pixzeroconst=newDataSignal(topNet,'pixzeroconst',ramType,inRate);
    else

        refpixeldly=newSignalLike(topNet,'refpixeldly',refpixelIn);
        refzeroconst=newDataSignal(topNet,'refzeroconst',refpixelInType,inRate);
        pixzeroconst=newDataSignal(topNet,'pixzeroconst',pixelInType,inRate);
    end
    trueconst=newControlSignal(topNet,'trueconst',inRate);

    hStartPreReg=newControlSignal(topNet,'pixelHStartPreReg',inRate);
    hEndPreReg=newControlSignal(topNet,'pixelHEndPreReg',inRate);
    vStartPreReg=newControlSignal(topNet,'pixelVStartPreReg',inRate);
    vEndPreReg=newControlSignal(topNet,'pixelVEndPreReg',inRate);
    validPreReg=newControlSignal(topNet,'pixelValidPreReg',inRate);

    pirelab.getConstComp(topNet,refzeroconst,0,'refzeroconst');
    pirelab.getConstComp(topNet,pixzeroconst,0,'refzeroconst');
    pirelab.getConstComp(topNet,trueconst,1,'tconst');
    if inDim>1

        for ii=1:length(refpixelIn11)
            pirelab.getIntDelayComp(topNet,refpixelInReg1(ii),refpixeldly1(ii),8,'refpixdlyline1');
            pirelab.getIntDelayComp(topNet,refpixelInReg2(ii),refpixeldly2(ii),8,'refpixdlyline2');
            pirelab.getIntDelayComp(topNet,refpixelInReg3(ii),refpixeldly3(ii),8,'refpixdlyline3');
        end
        if refpixelIn.Type.Dimensions(2)==4
            for ii=1:length(refpixelIn11)
                pirelab.getIntDelayComp(topNet,refpixelInReg4(ii),refpixeldly4(ii),8,'refpixdlyline4');
            end
        end
    else

        if length(refpixelIn)>1
            for ii=1:length(refpixelIn)
                pirelab.getIntDelayComp(topNet,refpixelInReg(ii),refpixeldly(ii),8,'refpixdlyline');
            end
        else

            pirelab.getIntDelayComp(topNet,refpixelInReg,refpixeldly,8,'refpixdlyline');
        end
    end
    pirelab.getIntDelayComp(topNet,refhStartInReg,hStartPreReg,6,'refhsdlyline');
    pirelab.getIntDelayComp(topNet,refhEndInReg,hEndPreReg,6,'refhedlyline');
    pirelab.getIntDelayComp(topNet,refvStartInReg,vStartPreReg,6,'refvsdlyline');
    pirelab.getIntDelayComp(topNet,refvEndInReg,vEndPreReg,6,'refvedlyline');
    pirelab.getIntDelayComp(topNet,refvalidInReg,validPreReg,6,'refvaldlyline');

    [refInFrame,refInLine,refNewFrame,refNewLine]=lineframeFSM(topNet,hStartPreReg,hEndPreReg,vStartPreReg,vEndPreReg,validPreReg,inRate,'ref');

    pirelab.getIntDelayComp(topNet,hStartPreReg,hStartOutReg,2,'rhSOReg',0);
    pirelab.getIntDelayComp(topNet,hEndPreReg,hEndOutReg,2,'rhEOReg',0);
    pirelab.getIntDelayComp(topNet,vStartPreReg,vStartOutReg,2,'rvSOReg',0);
    pirelab.getIntDelayComp(topNet,vEndPreReg,vEndOutReg,2,'rvEOReg',0);
    pirelab.getIntDelayComp(topNet,validPreReg,validOutReg,2,'rvalOReg',0);

    refNewFrameInv=newControlSignal(topNet,'refNewFrameInv',inRate);
    refNewLineNotFrame=newControlSignal(topNet,'refNewLineNotFrame',inRate);
    pirelab.getBitwiseOpComp(topNet,refNewFrame,refNewFrameInv,'NOT');
    pirelab.getBitwiseOpComp(topNet,[refNewLine,refNewFrameInv],refNewLineNotFrame,'AND');


    frameStart=newDataSignal(topNet,'frameStart',RAMaddrtype,inRate);
    frameStartValid=newControlSignal(topNet,'frameStartValid',inRate);
    refFrameValid=newControlSignal(topNet,'refFrameValid',inRate);

    refEarlyInLine=newControlSignal(topNet,'refEarlyInLine',inRate);
    refEarlyInFrame=newControlSignal(topNet,'refEarlyInFrame',inRate);

    linerdaddr=newDataSignal(topNet,'linerdaddr',lineaddrtype,inRate);
    linerden=newControlSignal(topNet,'linerden',inRate);
    linerddata=newDataSignal(topNet,'linerddata',RAMaddrtype,inRate);
    linerdvalid=newControlSignal(topNet,'linerdvalid',inRate);
    ramrdframe=newControlSignal(topNet,'ramrdframe',inRate);
    ramrdline=newControlSignal(topNet,'ramrdline',inRate);
    pixelNewFrameInv=newControlSignal(topNet,'pixelNewFrameInv',inRate);
    pixelNewLineNotFrame=newControlSignal(topNet,'pixelNewLineNotFrame',inRate);

    pirelab.getBitwiseOpComp(topNet,[pixelNewLine,pixelNewFrameInv],pixelNewLineNotFrame,'AND');

    pirelab.getUnitDelayEnabledComp(topNet,ramwraddr,frameStart,pixelNewFrame,'fsreg',0.0,'',false);
    pirelab.getUnitDelayEnabledComp(topNet,trueconst,frameStartValid,pixelNewFrame,'fsvreg',0.0,'',false);
    pirelab.getUnitDelayEnabledComp(topNet,frameStartValid,refFrameValid,refNewFrame,'rfvreg',0.0,'',false);


    for ii=1:blockInfo.MaximumNumberOfLines

        linewraddr(ii)=newControlSignal(topNet,sprintf('linewr%daddr',ii-1),inRate);%#ok
        lineStarts(ii)=newDataSignal(topNet,sprintf('line%dStarts',ii-1),RAMaddrtype,inRate);%#ok  %vector
        lineStartsValidNext(ii)=newControlSignal(topNet,sprintf('line%dStartsValidNext',ii-1),inRate);%#ok  % vector
        lineStartsValid(ii)=newControlSignal(topNet,sprintf('line%dStartsValid',ii-1),inRate);%#ok  % vector
        lineStartsEn(ii)=newControlSignal(topNet,sprintf('line%dStartsEn',ii-1),inRate);%#ok  % vector
        linerdaddrdecode(ii)=newControlSignal(topNet,sprintf('linerd%daddrdecode',ii-1),inRate);%#ok
        rdgate(ii)=newControlSignal(topNet,sprintf('rd%dgate',ii-1),inRate);%#ok
        wrgate(ii)=newControlSignal(topNet,sprintf('wr%dgate',ii-1),inRate);%#ok
    end

    for ii=1:blockInfo.MaximumNumberOfLines
        if(ii==1)
            pirelab.getUnitDelayEnabledComp(topNet,linewraddr(end),linewraddr(ii),pixelNewLineNotFrame,'linewrreg',1,'',false);
        else
            pirelab.getUnitDelayEnabledComp(topNet,linewraddr(ii-1),linewraddr(ii),pixelNewLineNotFrame,'linewrreg',0,'',false);
        end


        pirelab.getCompareToValueComp(topNet,linerdaddr,linerdaddrdecode(ii),'==',ii-1,'decodecomp');


        pirelab.getBitwiseOpComp(topNet,[frameStartValid,pixelNewLineNotFrame,linewraddr(ii)],wrgate(ii),'AND');
        pirelab.getBitwiseOpComp(topNet,[ramrdload,linerdaddrdecode(ii)],rdgate(ii),'AND');
        pirelab.getBitwiseOpComp(topNet,[rdgate(ii),wrgate(ii)],lineStartsEn(ii),'OR');


        pirelab.getBitwiseOpComp(topNet,[wrgate(ii),trueconst],lineStartsValidNext(ii),'AND');

        pirelab.getUnitDelayEnabledComp(topNet,ramwraddr,lineStarts(ii),lineStartsEn(ii),'lsreg',0.0,'',false);
        pirelab.getUnitDelayEnabledComp(topNet,lineStartsValidNext(ii),lineStartsValid(ii),lineStartsEn(ii),'lsvalreg',0.0,'',false);
    end

    pirelab.getBitwiseOpComp(topNet,pixelNewFrame,pixelNewFrameInv,'NOT');
    pirelab.getBitwiseOpComp(topNet,[frameStartValid,refFrameValid,refNewLineNotFrame],linerden,'AND');

    pirelab.getCounterComp(topNet,linerden,linerdaddr,...
    'Count limited',...
    0.0,...
    1.0,...
    blockInfo.MaximumNumberOfLines-1,...
    false,...
    false,...
    true,...
    false,...
    'rdlinecounter');

    pirelab.getMultiPortSwitchComp(topNet,[linerdaddr,lineStarts],...
    linerddata,...
    1,1,'floor','Wrap','linestmux');
    pirelab.getMultiPortSwitchComp(topNet,[linerdaddr,lineStartsValid],...
    linerdvalid,...
    1,1,'floor','Wrap','linestvmux');

    pirelab.getRelOpComp(topNet,[ramrdnextaddr,linerddata],addrmatch,'==');
    pirelab.getBitwiseOpComp(topNet,[addrmatch,linerdvalid],notholdaddr,'NAND');

    pirelab.getSwitchComp(topNet,[linerddata,frameStart],ramrdloadval,refNewFrame,'rdaddrmux');

    pirelab.getBitwiseOpComp(topNet,[frameStartValid,refFrameValid,validPreReg,refNewFrame],ramrdframe,'AND');
    pirelab.getBitwiseOpComp(topNet,[frameStartValid,refFrameValid,validPreReg,linerdvalid,refNewLine],ramrdline,'AND');
    pirelab.getBitwiseOpComp(topNet,[ramrdframe,ramrdline],ramrdload,'OR');

    pirelab.getBitwiseOpComp(topNet,[refInLine,refNewLine],refEarlyInLine,'OR');
    pirelab.getBitwiseOpComp(topNet,[refInFrame,refNewFrame],refEarlyInFrame,'OR');

    pirelab.getBitwiseOpComp(topNet,[frameStartValid,refFrameValid,validPreReg,refEarlyInFrame,refEarlyInLine,notholdaddr],ramrden,'AND');



    pixelOutValid=newControlSignal(topNet,'pixelOutValid',inRate);
    pirelab.getBitwiseOpComp(topNet,[validOutReg,refFrameValid],pixelOutValid,'AND');

    if inDim>1

        for ii=1:length(refpixelIn11)
            pirelab.getSwitchComp(topNet,[refzeroconst,refpixeldly1(ii)],refpixelOutReg1(ii),validOutReg,'refzeromux1');
            pirelab.getSwitchComp(topNet,[refzeroconst,refpixeldly2(ii)],refpixelOutReg2(ii),validOutReg,'refzeromux2');
            pirelab.getSwitchComp(topNet,[refzeroconst,refpixeldly3(ii)],refpixelOutReg3(ii),validOutReg,'refzeromux3');
        end
        if refpixelIn.Type.Dimensions(2)==4
            for ii=1:length(refpixelIn11)
                pirelab.getSwitchComp(topNet,[refzeroconst,refpixeldly4(ii)],refpixelOutReg4(ii),validOutReg,'refzeromux4');
            end
        end
    else

        if length(refpixelIn)>1
            for ii=1:length(refpixelIn)
                pirelab.getSwitchComp(topNet,[refzeroconst,refpixeldly(ii)],refpixelOutReg(ii),validOutReg,'refzeromux');
            end
        else

            pirelab.getSwitchComp(topNet,[refzeroconst,refpixeldly],refpixelOutReg,validOutReg,'refzeromux');
        end
    end

    if inDim>1
        pixelOutReg11=topNet.addSignal(ramType,'pixelOutReg11');
        pixelOutReg11.SimulinkRate=inRate;
        pixelOutReg22=topNet.addSignal(ramType,'pixelOutReg22');
        pixelOutReg22.SimulinkRate=inRate;


        if(pixelIn.Type.Dimensions(1)==4||pixelIn.Type.Dimensions(1)==8)
            pixelOutReg33=topNet.addSignal(ramType,'pixelOutReg33');
            pixelOutReg33.SimulinkRate=inRate;
            pixelOutReg44=topNet.addSignal(ramType,'pixelOutReg44');
            pixelOutReg44.SimulinkRate=inRate;
        end


        if pixelIn.Type.Dimensions(1)==8
            pixelOutReg55=topNet.addSignal(ramType,'pixelOutReg55');
            pixelOutReg55.SimulinkRate=inRate;
            pixelOutReg66=topNet.addSignal(ramType,'pixelOutReg66');
            pixelOutReg66.SimulinkRate=inRate;
            pixelOutReg77=topNet.addSignal(ramType,'pixelOutReg77');
            pixelOutReg77.SimulinkRate=inRate;
            pixelOutReg88=topNet.addSignal(ramType,'pixelOutReg88');
            pixelOutReg88.SimulinkRate=inRate;
        end
        pixzeroconst1=newDataSignal(topNet,'pixzeroconst1',ramType,inRate);
        pirelab.getConstComp(topNet,pixzeroconst1,0,'pixzeroconst1');
        pixelOut11=topNet.addSignal(pixelOut.Type,'PixelOut11');

        pirelab.getSwitchComp(topNet,[pixzeroconst1,ram_outData1],pixelOutReg11,pixelOutValid,'pixzeromux1');
        pirelab.getSwitchComp(topNet,[pixzeroconst1,ram_outData2],pixelOutReg22,pixelOutValid,'pixzeromux2');
        if(pixelIn.Type.Dimensions(1)==4||pixelIn.Type.Dimensions(1)==8)
            pirelab.getSwitchComp(topNet,[pixzeroconst1,ram_outData3],pixelOutReg33,pixelOutValid,'pixzeromux3');
            pirelab.getSwitchComp(topNet,[pixzeroconst1,ram_outData4],pixelOutReg44,pixelOutValid,'pixzeromux4');
        end

        if pixelIn.Type.Dimensions(1)==8
            pirelab.getSwitchComp(topNet,[pixzeroconst1,ram_outData5],pixelOutReg55,pixelOutValid,'pixzeromux5');
            pirelab.getSwitchComp(topNet,[pixzeroconst1,ram_outData6],pixelOutReg66,pixelOutValid,'pixzeromux6');
            pirelab.getSwitchComp(topNet,[pixzeroconst1,ram_outData7],pixelOutReg77,pixelOutValid,'pixzeromux7');
            pirelab.getSwitchComp(topNet,[pixzeroconst1,ram_outData8],pixelOutReg88,pixelOutValid,'pixzeromux8');
            pirelab.getConcatenateComp(topNet,[pixelOutReg11,pixelOutReg22,pixelOutReg33,pixelOutReg44,pixelOutReg55,pixelOutReg66,pixelOutReg77,pixelOutReg88],pixelOut11,'Multidimensional array','1');
        elseif pixelIn.Type.Dimensions(1)==4
            pirelab.getConcatenateComp(topNet,[pixelOutReg11,pixelOutReg22,pixelOutReg33,pixelOutReg44],pixelOut11,'Multidimensional array','1');
        else
            pirelab.getConcatenateComp(topNet,[pixelOutReg11,pixelOutReg22],pixelOut11,'Multidimensional array','1');
        end
        pirelab.getIntDelayComp(topNet,pixelOut11,pixelOut,1,'pixelOut');
    else

        if length(pixelIn)>1
            for ii=1:length(pixelIn)
                pirelab.getSwitchComp(topNet,[pixzeroconst,ramrddata(ii)],pixelOutReg(ii),pixelOutValid,'pixzeromux');
            end
        else

            pirelab.getSwitchComp(topNet,[pixzeroconst,ramrddata],pixelOutReg,pixelOutValid,'pixzeromux');
        end
    end

end


function signal=newControlSignal(topNet,name,rate)
    controlType=pir_ufixpt_t(1,0);
    signal=topNet.addSignal(controlType,name);
    signal.SimulinkRate=rate;
end

function signal=newDataSignal(topNet,name,inType,rate)
    signal=topNet.addSignal(inType,name);
    signal.SimulinkRate=rate;
end

function signal=newSignalLike(topNet,name,refSignal)
    inType=refSignal(1).Type;
    rate=refSignal(1).SimulinkRate;

    if length(refSignal)>1
        for ii=1:length(refSignal)
            signal(ii)=topNet.addSignal(inType,[name,num2str(ii),'comp']);%#ok
            signal(ii).SimulinkRate=rate;%#ok
        end
    else
        signal=topNet.addSignal(inType,name);
        signal.SimulinkRate=rate;
    end
end




function[inFrame,inLine,newFrame,newLine,inFramePrev,inLinePrev]=lineframeFSM(topNet,hS,hE,vS,vE,val,inRate,nameprefix)

    if nargin<8
        nameprefix='';
    end

    inFrame=newControlSignal(topNet,[nameprefix,'inFrame'],inRate);
    inLine=newControlSignal(topNet,[nameprefix,'inLine'],inRate);

    inFramePrev=newControlSignal(topNet,[nameprefix,'inFramePrev'],inRate);
    inLinePrev=newControlSignal(topNet,[nameprefix,'inLinePrev'],inRate);

    newLine=newControlSignal(topNet,[nameprefix,'newLine'],inRate);
    newFrame=newControlSignal(topNet,[nameprefix,'newFrame'],inRate);

    inFrameNext=newControlSignal(topNet,[nameprefix,'inFrameNext'],inRate);
    inFrameTerm1=newControlSignal(topNet,[nameprefix,'inFrame1Term'],inRate);
    inFrameTerm2=newControlSignal(topNet,[nameprefix,'inFrame2Term'],inRate);
    inFrameTerm3=newControlSignal(topNet,[nameprefix,'inFrame3Term'],inRate);

    inLineNext=newControlSignal(topNet,[nameprefix,'inLineNext'],inRate);
    inLineTerm1=newControlSignal(topNet,[nameprefix,'inLine1Term'],inRate);
    inLineTerm2=newControlSignal(topNet,[nameprefix,'inLine2Term'],inRate);
    inLineTerm3=newControlSignal(topNet,[nameprefix,'inLine3Term'],inRate);
    inLineTerm4=newControlSignal(topNet,[nameprefix,'inLine4Term'],inRate);
    inLineTerm5=newControlSignal(topNet,[nameprefix,'inLine5Term'],inRate);
    inLineTerm6=newControlSignal(topNet,[nameprefix,'inLine6Term'],inRate);

    vEndInv=newControlSignal(topNet,[nameprefix,'vEndInv'],inRate);
    pirelab.getBitwiseOpComp(topNet,vE,vEndInv,'NOT');

    hEndInv=newControlSignal(topNet,[nameprefix,'hEndInv'],inRate);
    pirelab.getBitwiseOpComp(topNet,hE,hEndInv,'NOT');

    validInv=newControlSignal(topNet,[nameprefix,'ValidInv'],inRate);
    pirelab.getBitwiseOpComp(topNet,val,validInv,'NOT');

    inFrameInv=newControlSignal(topNet,[nameprefix,'inFrameInv'],inRate);
    pirelab.getBitwiseOpComp(topNet,inFrame,inFrameInv,'NOT');

    inLineInv=newControlSignal(topNet,[nameprefix,'inLineInv'],inRate);
    pirelab.getBitwiseOpComp(topNet,inLine,inLineInv,'NOT');

    pirelab.getUnitDelayComp(topNet,inFrameNext,inFrame,'inFReg',0);
    pirelab.getUnitDelayComp(topNet,inLineNext,inLine,'inLReg',0);

    pirelab.getUnitDelayComp(topNet,inFrame,inFramePrev,'inFPReg',0);
    pirelab.getUnitDelayComp(topNet,inLine,inLinePrev,'inLPReg',0);

    pirelab.getBitwiseOpComp(topNet,[inFrameTerm1,...
    inFrameTerm2,...
    inFrameTerm3],...
    inFrameNext,'OR');
    pirelab.getBitwiseOpComp(topNet,[inLineTerm1,...
    inLineTerm2,...
    inLineTerm3,...
    inLineTerm4,...
    inLineTerm5,...
    inLineTerm6],...
    inLineNext,'OR');

    pirelab.getBitwiseOpComp(topNet,[vEndInv,inFrame],inFrameTerm1,'AND');
    pirelab.getBitwiseOpComp(topNet,[val,vS],inFrameTerm2,'AND');
    pirelab.getBitwiseOpComp(topNet,[validInv,inFrame],inFrameTerm3,'AND');

    pirelab.getBitwiseOpComp(topNet,[hEndInv,inLine],inLineTerm1,'AND');
    pirelab.getBitwiseOpComp(topNet,[val,hS,vS],inLineTerm2,'AND');
    pirelab.getBitwiseOpComp(topNet,[vS,inLine],inLineTerm3,'AND');
    pirelab.getBitwiseOpComp(topNet,[inFrameInv,inLine],inLineTerm4,'AND');
    pirelab.getBitwiseOpComp(topNet,[validInv,inLine],inLineTerm5,'AND');
    pirelab.getBitwiseOpComp(topNet,[val,hS,vEndInv,inFrame,inLineInv],inLineTerm6,'AND');

    pirelab.getBitwiseOpComp(topNet,[inFrameNext,inFrameInv],newFrame,'AND');
    pirelab.getBitwiseOpComp(topNet,[inLineNext,inLineInv],newLine,'AND');
end




function[outSignals,hBT]=demuxComponents(hN,inSignal)
    [indim,hBT]=pirelab.getVectorTypeInfo(inSignal);

    if indim>1
        sname=inSignal.Name;
        dmuxout=[];
        for ii=1:indim
            outSignals(ii)=hN.addSignal(hBT,[sname,num2str(ii),'comp']);%#ok
            dmuxout=[dmuxout,outSignals(ii)];%#ok
        end
        pirelab.getDemuxComp(hN,inSignal,dmuxout);
    else
        outSignals=inSignal;
    end
end

