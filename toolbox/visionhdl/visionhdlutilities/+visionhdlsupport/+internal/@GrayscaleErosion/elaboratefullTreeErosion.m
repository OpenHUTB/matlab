function cNet=elaboratefullTreeErosion(this,topNet,blockInfo,sigInfo,inRate)










    inputWL=sigInfo.inputWL;
    inputFL=sigInfo.inputFL;
    inType=sigInfo.inType;
    boolType=pir_boolean_t();
    pixelVType=sigInfo.lbufVType;
    Neighborhood=blockInfo.Neighborhood;



    inPortNames={'DataVectorIn','hStartIn','hEndIn','vStartIn','vEndIn','validIn','processDataIn'};
    inPortTypes=[pixelVType,boolType,boolType,boolType,boolType,boolType,boolType];
    inPortRates=[inRate,inRate,inRate,inRate,inRate,inRate,inRate];
    outPortNames={'dataOut','hStartOut','hEndOut','vStartOut','vEndOut','validOut'};
    outPortTypes=[inType,boolType,boolType,boolType,boolType,boolType];


    cNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','ErosionCore',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);

    cNet.addComment('Find local minima in grayscale image');



    inSignals=cNet.PirInputSignals;
    dataVectorIn=inSignals(1);
    hStartIn=inSignals(2);
    hEndIn=inSignals(3);
    vStartIn=inSignals(4);
    vEndIn=inSignals(5);
    validIn=inSignals(6);
    processDataIn=inSignals(7);

    outSignals=cNet.PirOutputSignals;
    dataOut=outSignals(1);
    hStartOut=outSignals(2);
    hEndOut=outSignals(3);
    vStartOut=outSignals(4);
    vEndOut=outSignals(5);
    validOut=outSignals(6);

    notValid=cNet.addSignal2('Type',boolType,'Name','NOTVALID');
    validOutREG=cNet.addSignal2('Type',boolType,'Name','NOTVALID');

    hStartPre=cNet.addSignal2('Type',boolType,'Name','hStartPre');
    hEndPre=cNet.addSignal2('Type',boolType,'Name','hEndPre');
    vStartPre=cNet.addSignal2('Type',boolType,'Name','vStartPre');
    vEndPre=cNet.addSignal2('Type',boolType,'Name','vEndPre');
    validPre=cNet.addSignal2('Type',boolType,'Name','validPre');
    hStartGate=cNet.addSignal2('Type',boolType,'Name','hStartPre');
    hEndGate=cNet.addSignal2('Type',boolType,'Name','hEndPre');
    vStartGate=cNet.addSignal2('Type',boolType,'Name','vStartPre');
    vEndGate=cNet.addSignal2('Type',boolType,'Name','vEndPre');
    validGate=cNet.addSignal2('Type',boolType,'Name','validPre');
    processDataD=cNet.addSignal2('Type',boolType,'Name','processDataD');








    if blockInfo.kHeight>1
        pixelInSplit=dataVectorIn.split;
    else
        pixelInSplit=dataVectorIn;
    end



    for ii=1:blockInfo.kHeight

        for jj=1:1:blockInfo.kWidth
            dataTap{ii,jj}=cNet.addSignal2('Type',inType,'Name',['dataTap',num2str(ii),num2str(jj)]);
            if jj==1
                if blockInfo.kHeight>1
                    REG=pirelab.getUnitDelayEnabledComp(cNet,pixelInSplit.PirOutputSignals(ii),dataTap{ii,jj},processDataIn,['DELAY',num2str(ii)]);
                else
                    REG=pirelab.getUnitDelayEnabledComp(cNet,pixelInSplit,dataTap{ii,jj},processDataIn,['DELAY',num2str(ii)]);
                end
            else
                REG=pirelab.getUnitDelayEnabledComp(cNet,dataTap{ii,jj-1},dataTap{ii,jj},processDataIn,['DELAY',num2str(ii)]);
            end
        end

    end



    for ii=1:1:blockInfo.kHeight
        indicesOfInterest=find(blockInfo.Neighborhood(ii,:));


        kk=1;
        clear minArray;
        for jj=1:1:max(indicesOfInterest)
            if jj==indicesOfInterest(kk)
                minArray(kk)=dataTap{ii,jj};
                kk=kk+1;
            end





        end
        if kk>1
            rowVType=pirelab.getPirVectorType(inType,kk-1);
            rowMinIn{ii}=cNet.addSignal2('Type',rowVType,'Name','rowMinVec');
            pirelab.getMuxComp(cNet,minArray,rowMinIn{ii});


            MinMaxBlockInfo.compType='Min';
            MinMaxBlockInfo.rndMode='Floor';
            MinMaxBlockInfo.satMode='Wrap';
            rowMinOutput(ii)=cNet.addSignal2('Type',inType,'Name','RowMinOutput');
            minMaxOutput(ii)=cNet.addSignal2('Type',inType,'Name','minOutput');
            rowMinOutput(ii).SimulinkRate=rowMinIn{ii}.SimulinkRate;
            minMaxOutput(ii).SimulinkRate=rowMinIn{ii}.SimulinkRate;
            rowMinNet{ii}=this.addMinMaxTree(cNet,MinMaxBlockInfo,sigInfo,inRate,rowMinIn{ii},...
            minMaxOutput(ii),kk-1);
            pirelab.instantiateNetwork(cNet,rowMinNet{ii},rowMinIn{ii},minMaxOutput(ii),'rowMin');

            pipelineBalance=ceil(log2(blockInfo.kWidth))-ceil(log2(kk-1));

            if pipelineBalance>0
                pirelab.getIntDelayComp(cNet,minMaxOutput(ii),rowMinOutput(ii),pipelineBalance,'PipelineBalanceREG');
            else
                pirelab.getWireComp(cNet,minMaxOutput(ii),rowMinOutput(ii));
            end



        else
            rowMinOutput(ii)=cNet.addSignal2('Type',inType,'Name','RowMinOutput');
            rowMinOutput(ii).SimulinkRate=validIn.SimulinkRate;
            pirelab.getConstComp(cNet,rowMinOutput(ii),realmax);
        end


    end

    colVType=pirelab.getPirVectorType(inType,blockInfo.kHeight);
    colMinIn=cNet.addSignal2('Type',colVType,'Name','colMinVec');
    pirelab.getMuxComp(cNet,rowMinOutput(:),colMinIn);

    dataOutREGIn=cNet.addSignal2('Type',inType,'Name','dataOutREG');
    dataOutREGOut=cNet.addSignal2('Type',inType,'Name','dataOutREGOut');



    dataOut.SimulinkRate=rowMinOutput(1).SimulinkRate;
    colMinNet=this.addMinMaxTree(cNet,MinMaxBlockInfo,sigInfo,inRate,colMinIn,dataOut,blockInfo.kHeight);
    pirelab.instantiateNetwork(cNet,colMinNet,colMinIn,dataOutREGIn,'colMin');



    if blockInfo.kWidth==2
        pipeDelay=2+ceil(log2(blockInfo.kWidth))+ceil(log2(blockInfo.kHeight));
    else
        pipeDelay=3+ceil(log2(blockInfo.kWidth))+ceil(log2(blockInfo.kHeight));
    end


    if blockInfo.kWidth==1
        pipeDelay=ceil(log2(blockInfo.kHeight))+1;
    end


    if blockInfo.kHeight<=2
        pipeDelay=pipeDelay+1;
    end


    pirelab.getIntDelayEnabledComp(cNet,hStartIn,hStartPre,processDataIn,ceil(blockInfo.kWidth/2));
    pirelab.getIntDelayEnabledComp(cNet,hEndIn,hEndPre,processDataIn,ceil(blockInfo.kWidth/2));
    pirelab.getIntDelayEnabledComp(cNet,vStartIn,vStartPre,processDataIn,ceil(blockInfo.kWidth/2));
    pirelab.getIntDelayEnabledComp(cNet,vEndIn,vEndPre,processDataIn,ceil(blockInfo.kWidth/2));
    pirelab.getIntDelayEnabledComp(cNet,validIn,validPre,processDataIn,ceil(blockInfo.kWidth/2));

    pirelab.getUnitDelayComp(cNet,processDataIn,processDataD);

    pirelab.getLogicComp(cNet,[hStartPre,processDataD],hStartGate,'and');
    pirelab.getLogicComp(cNet,[hEndPre,processDataD],hEndGate,'and');
    pirelab.getLogicComp(cNet,[vStartPre,processDataD],vStartGate,'and');
    pirelab.getLogicComp(cNet,[vEndPre,processDataD],vEndGate,'and');
    pirelab.getLogicComp(cNet,[validPre,processDataD],validGate,'and');


    pirelab.getIntDelayComp(cNet,hStartGate,hStartOut,(pipeDelay));
    pirelab.getIntDelayComp(cNet,hEndGate,hEndOut,(pipeDelay));
    pirelab.getIntDelayComp(cNet,vStartGate,vStartOut,(pipeDelay));
    pirelab.getIntDelayComp(cNet,vEndGate,vEndOut,(pipeDelay));
    pirelab.getIntDelayComp(cNet,validGate,validOutREG,(pipeDelay-1));
    pirelab.getUnitDelayComp(cNet,validOutREG,validOut);
    pirelab.getBitwiseOpComp(cNet,validOutREG,notValid,'not');


    constLow=cNet.addSignal2('Type',inType,'Name','CONSTANT_LOW');
    pirelab.getConstComp(cNet,constLow,fi(0,0,inType.WordLength,inType.FractionLength));

    clkEnbGate=cNet.addSignal2('Type',boolType,'Name','clkEnbGate');





    if blockInfo.kHeight>1&&blockInfo.kWidth==1


        pirelab.getUnitDelayComp(cNet,dataOutREGIn,dataOutREGOut);
        pirelab.getUnitDelayResettableComp(cNet,dataOutREGIn,dataOut,notValid);
    elseif mod(blockInfo.kWidth,2)==0&&mod(blockInfo.kHeight,2)==0



        pirelab.getUnitDelayComp(cNet,dataOutREGIn,dataOutREGOut);
        pirelab.getUnitDelayResettableComp(cNet,dataOutREGOut,dataOut,notValid);
    elseif(mod(blockInfo.kWidth,2)==0)&&mod(blockInfo.kHeight,2)==1





        pirelab.getUnitDelayComp(cNet,dataOutREGIn,dataOutREGOut);
        pirelab.getUnitDelayResettableComp(cNet,dataOutREGOut,dataOut,notValid);

    else

        pirelab.getIntDelayComp(cNet,dataOutREGIn,dataOutREGOut,2);
        pirelab.getUnitDelayResettableComp(cNet,dataOutREGOut,dataOut,notValid);
    end

















