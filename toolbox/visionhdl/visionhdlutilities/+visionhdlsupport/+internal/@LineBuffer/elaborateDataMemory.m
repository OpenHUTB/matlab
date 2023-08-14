function dataMemNet=elaborateDataMemory(this,topNet,blockInfo,sigInfo,dataRate)








    booleanT=sigInfo.booleanT;
    inType=sigInfo.inType;
    countT=sigInfo.countT;
    dataVType=sigInfo.dataVType;
    lineStartT=sigInfo.lineStartT;

    inPortNames={'Unloading','pixelIn','hStartIn','hEndIn','vStartIn','vEndIn','validIn','popEn'};
    inPortTypes=[booleanT,inType,booleanT,booleanT,booleanT,booleanT,booleanT,lineStartT];
    inPortRates=[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate];
    outPortNames={'dataVectorOut','popOut','AllAtEnd'};
    outPortTypes=[dataVType,booleanT,booleanT];

    dataMemNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','DATA_MEMORY',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    inSignals=dataMemNet.PirInputSignals;
    Unloading=inSignals(1);
    pixelIn=inSignals(2);
    hStartIn=inSignals(3);
    hEndIn=inSignals(4);
    vStartIn=inSignals(5);
    vEndIn=inSignals(6);
    validIn=inSignals(7);
    popEn=inSignals(8);




    validREG=dataMemNet.addSignal2('Type',booleanT,'Name','validREG');
    pirelab.getUnitDelayComp(dataMemNet,validIn,validREG);
    unloadPop=dataMemNet.addSignal2('Type',booleanT,'Name','unloadPop');
    unloadPopT=dataMemNet.addSignal2('Type',booleanT,'Name','unloadPopT');
    validPop=dataMemNet.addSignal2('Type',booleanT,'Name','validPop');
    hEndREG=dataMemNet.addSignal2('Type',booleanT,'Name','hEndREG');
    hEndREGT=dataMemNet.addSignal2('Type',booleanT,'Name','hEndREGT');


    pirelab.getUnitDelayComp(dataMemNet,validREG,unloadPop);

    pirelab.getLogicComp(dataMemNet,[unloadPop,Unloading,hEndREGT],unloadPopT,'and');
    pirelab.getLogicComp(dataMemNet,[validREG,unloadPopT],validPop,'or');


    pirelab.getUnitDelayComp(dataMemNet,hEndIn,hEndREG);
    pirelab.getUnitDelayComp(dataMemNet,hEndREG,hEndREGT);

    popArray(1)=validREG;
    endOfLineArray(1)=dataMemNet.addSignal2('Type',booleanT,'Name',['EndofLine',num2str(1)]);
    endofLineArray(1).SimulinkRate=dataRate;

    PushPopCounterNet=this.elaboratePushPopCounter(dataMemNet,blockInfo,...
    sigInfo,dataRate);

    PushPopCounterNetOne=this.elaboratePushPopCounterOne(dataMemNet,blockInfo,...
    sigInfo,dataRate);

    if blockInfo.KernelHeight>1
        for ii=1:1:blockInfo.KernelHeight-1
            if ii<=(floor(blockInfo.KernelHeight/2)-1)
                M=ii;
            else
                M=(floor(blockInfo.KernelHeight/2));
            end

            popArray(ii+1)=dataMemNet.addSignal2('Type',booleanT,'Name',['popFIFO_',num2str(ii+1)]);
            popArray(ii+1).SimulinkRate=dataRate;
            pushArray(ii)=dataMemNet.addSignal2('Type',booleanT,'Name',['pushFIFO',num2str(ii+1)]);
            pushArray(ii).SimulinkRate=dataRate;
            writeAddrArray(ii)=dataMemNet.addSignal2('Type',countT,'Name',['writeAddr',num2str(ii)]);
            writeAddrArray(ii).SimulinkRate=dataRate;
            pushOut(ii)=dataMemNet.addSignal2('Type',booleanT,'Name',['pushOut',num2str(ii)]);
            pushOut(ii).SimulinkRate=dataRate;
            writeAddrArrayREG(ii)=dataMemNet.addSignal2('Type',countT,'Name',['writeAddrREG',num2str(ii)]);
            writeAddrArrayREG(ii).SimulinkRate=dataRate;
            pushOutREG(ii)=dataMemNet.addSignal2('Type',booleanT,'Name',['pushOutREG',num2str(ii)]);
            pushOutREG(ii).SimulinkRate=dataRate;
            readAddrArray(ii)=dataMemNet.addSignal2('Type',countT,'Name',['readAddr',num2str(ii+1)]);
            readAddrArray(ii).SimulinkRate=dataRate;
            endOfLineArray(ii)=dataMemNet.addSignal2('Type',booleanT,'Name',['EndofLine',num2str(ii)]);
            endofLineArray(ii).SimulinkRate=dataRate;
            popEnSL(ii)=dataMemNet.addSignal2('Type',booleanT,'Name','PopEnSL');
            pirelab.getBitSliceComp(dataMemNet,popEn,popEnSL(ii),M-1,M-1);


            if ii==1
                PushPopCounterInOne=[hStartIn,validPop,popEnSL(ii),hEndREG];
                PushPopCounterOutOne=[writeAddrArray(ii),pushArray(ii),readAddrArray(ii),popArray(ii+1),endOfLineArray(ii)];
            else
                PushPopCounterIn=[hStartIn,validPop,popEnSL(ii),hEndREG,writeAddrArray(ii-1)];
                PushPopCounterOut=[writeAddrArray(ii),pushArray(ii),readAddrArray(ii),popArray(ii+1),endOfLineArray(ii)];
            end

            pirelab.getUnitDelayComp(dataMemNet,writeAddrArray(ii),writeAddrArrayREG(ii));
            pirelab.getUnitDelayComp(dataMemNet,pushArray(ii),pushOutREG(ii));

            if ii==1
                pirelab.instantiateNetwork(dataMemNet,PushPopCounterNetOne,PushPopCounterInOne,...
                PushPopCounterOutOne,'PushPopCounterOne');
            else
                pirelab.instantiateNetwork(dataMemNet,PushPopCounterNet,PushPopCounterIn,...
                PushPopCounterOut,['PushPopCounter',num2str(ii)]);

            end

        end
    end

    pixelREG=dataMemNet.addSignal2('Type',inType,'Name','pixelREG');
    pixelSwitchOut=dataMemNet.addSignal2('Type',inType,'Name','pixelMUXOut');
    pirelab.getIntDelayComp(dataMemNet,pixelIn,pixelREG,3);
    constantZero=dataMemNet.addSignal2('Type',inType,'Name','constantZero');
    constantZero.SimulinkRate=dataRate;
    pirelab.getConstComp(dataMemNet,constantZero,0);
    pirelab.getSwitchComp(dataMemNet,[pixelREG,constantZero],pixelSwitchOut,Unloading);


    if(blockInfo.NumPixels>1)&&(inType.BaseType.WordLength==1)

        RAMType=pir_ufixpt_t(inType.Dimensions,0);
        pixelArray(1)=dataMemNet.addSignal2('Type',RAMType,'Name','pixelColumn_0');
        RAM_Concat=dataMemNet.addSignal2('Type',RAMType,'Name','RAM_Concat');
        pixSplit=pixelIn.split.PirOutputSignals;
        pirelab.getBitConcatComp(dataMemNet,pixSplit,RAM_Concat);
        pirelab.getIntDelayComp(dataMemNet,RAM_Concat,pixelArray(1),4);
        numRAM=1;
    else

        if blockInfo.NumPixels>1
            RAMType=pirelab.createPirArrayType(inType.BaseType,[1,inType.Dimensions]);
        else
            RAMType=inType;
        end
        pixelArray(1)=dataMemNet.addSignal2('Type',RAMType,'Name','pixelColumn_0');
        pirelab.getIntDelayComp(dataMemNet,pixelIn,pixelArray(1),4);
        numRAM=blockInfo.NumPixels;
    end



    if blockInfo.KernelHeight>1
        for ii=1:1:blockInfo.KernelHeight-1
            pixelArray(ii+1)=dataMemNet.addSignal2('Type',RAMType,'Name',['pixelColumn',num2str(ii)]);
            pixelArray(ii+1).SimulinkRate=dataRate;
            pirelab.getSimpleDualPortRamComp(dataMemNet,[pixelArray(ii),writeAddrArrayREG(ii),pushOutREG(ii),readAddrArray(ii)],...
            pixelArray(ii+1),['SimpleDualPortRAM_Generic',num2str(ii)],numRAM);
        end
    end

    pixelArrayO(1)=dataMemNet.addSignal2('Type',RAMType,'Name',['pixelColumnO',num2str(1)]);
    pirelab.getWireComp(dataMemNet,pixelArray(1),pixelArrayO(1));

    if blockInfo.KernelHeight>1
        for ii=2:1:blockInfo.KernelHeight
            pixelArrayO(ii)=dataMemNet.addSignal2('Type',RAMType,'Name',['pixelColumnO',num2str(ii)]);
            pirelab.getWireComp(dataMemNet,pixelArray(ii),pixelArrayO(ii));
        end
    end

    outSignals=dataMemNet.PirOutputSignals;
    dataVectorOut=outSignals(1);
    popOut=outSignals(2);

    if blockInfo.KernelHeight>1
        pirelab.getUnitDelayComp(dataMemNet,popArray(2),popOut);
    else
        pirelab.getUnitDelayComp(dataMemNet,popArray(1),popOut);
    end

    AllAtEnd=outSignals(3);


    if(blockInfo.NumPixels>1)&&(inType.BaseType.WordLength==1)


        for jj=1:1:blockInfo.KernelHeight
            for kk=1:1:blockInfo.NumPixels
                pixelRAMBit(jj,kk)=dataMemNet.addSignal2('Type',booleanT,'Name',['pixelRAMBit_',num2str(jj),'_',num2str(kk)]);
                pirelab.getBitSliceComp(dataMemNet,pixelArrayO(jj),pixelRAMBit(jj,kk),kk-1,kk-1);
            end
            inRowType=pirelab.createPirArrayType(inType.BaseType,[1,inType.Dimensions]);
            pixelArrayOMV(jj)=dataMemNet.addSignal2('Type',inRowType,'Name','pixelArrayOMV');
            pirelab.getConcatenateComp(dataMemNet,pixelRAMBit(jj,blockInfo.NumPixels:-1:1),pixelArrayOMV(jj),'Multidimensional array','1');
        end


        pirelab.getConcatenateComp(dataMemNet,pixelArrayOMV,dataVectorOut,'Multidimensional array','1');


    else


        dataVecInt=dataMemNet.addSignal2('Type',dataVType,'Name','dataVecInt');


        pirelab.getConcatenateComp(dataMemNet,pixelArrayO,dataVecInt,'Multidimensional array','1');
        pirelab.getWireComp(dataMemNet,dataVecInt,outSignals(1));
    end

    if blockInfo.KernelHeight>1
        pirelab.getLogicComp(dataMemNet,endOfLineArray(:),AllAtEnd,'and');
    else
        endOfLineArray(1).SimulinkRate=dataRate;
        pirelab.getConstComp(dataMemNet,endOfLineArray(1),true)
        pirelab.getLogicComp(dataMemNet,endOfLineArray(1),AllAtEnd,'and');
    end









