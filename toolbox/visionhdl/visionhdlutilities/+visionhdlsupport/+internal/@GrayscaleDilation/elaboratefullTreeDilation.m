function cNet=elaboratefullTreeDilation(this,topNet,blockInfo,sigInfo,inRate)










    inputWL=sigInfo.inputWL;
    inputFL=sigInfo.inputFL;
    inType=sigInfo.inType;
    boolType=pir_boolean_t();
    pixelVType=sigInfo.lbufVType;



    inPortNames={'DataVectorIn','hStartIn','hEndIn','vStartIn','vEndIn','validIn','processDataIn'};
    inPortTypes=[pixelVType,boolType,boolType,boolType,boolType,boolType,boolType];
    inPortRates=[inRate,inRate,inRate,inRate,inRate,inRate,inRate];
    outPortNames={'dataOut','hStartOut','hEndOut','vStartOut','vEndOut','validOut'};
    outPortTypes=[inType,boolType,boolType,boolType,boolType,boolType];


    cNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','DilationCore',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);

    cNet.addComment('Find local maxima in grayscale image');



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
        clear maxArray;
        for jj=1:1:max(indicesOfInterest)
            if jj==indicesOfInterest(kk)
                maxArray(kk)=dataTap{ii,jj};
                kk=kk+1;
            end





        end

        if kk>1
            rowVType=pirelab.getPirVectorType(inType,kk-1);
            rowMaxIn{ii}=cNet.addSignal2('Type',rowVType,'Name','rowMaxVec');
            pirelab.getMuxComp(cNet,maxArray,rowMaxIn{ii});


            MinMaxBlockInfo.compType='Max';
            MinMaxBlockInfo.rndMode='Floor';
            MinMaxBlockInfo.satMode='Wrap';
            rowMaxOutput(ii)=cNet.addSignal2('Type',inType,'Name','RowMaxOutput');
            minMaxOutput(ii)=cNet.addSignal2('Type',inType,'Name','maxOutput');
            rowMaxOutput(ii).SimulinkRate=rowMaxIn{ii}.SimulinkRate;
            minMaxOutput(ii).SimulinkRate=rowMaxIn{ii}.SimulinkRate;
            rowMaxNet{ii}=this.addMinMaxTree(cNet,MinMaxBlockInfo,sigInfo,inRate,rowMaxIn{ii},...
            minMaxOutput(ii),kk-1);
            pirelab.instantiateNetwork(cNet,rowMaxNet{ii},rowMaxIn{ii},minMaxOutput(ii),'rowMax');

            pipelineBalance=ceil(log2(blockInfo.kWidth))-ceil(log2(kk-1));

            if pipelineBalance>0
                pirelab.getIntDelayComp(cNet,minMaxOutput(ii),rowMaxOutput(ii),pipelineBalance,'PipelineBalanceREG');
            else
                pirelab.getWireComp(cNet,minMaxOutput(ii),rowMaxOutput(ii));
            end

        else
            rowMaxOutput(ii)=cNet.addSignal2('Type',inType,'Name','RowMaxOutput');
            rowMaxOutput(ii).SimulinkRate=validIn.SimulinkRate;
            pirelab.getConstComp(cNet,rowMaxOutput(ii),0);
        end



    end

    if blockInfo.kHeight>1
        colVType=pirelab.getPirVectorType(inType,blockInfo.kHeight);
    else
        colVType=inType;
    end

    colMaxIn=cNet.addSignal2('Type',colVType,'Name','colMaxVec');
    pirelab.getMuxComp(cNet,rowMaxOutput(:),colMaxIn);

    dataOutREGIn=cNet.addSignal2('Type',inType,'Name','dataOutREG');
    dataOutMux=cNet.addSignal2('Type',inType,'Name','dataOutREG');
    dataOutPre=cNet.addSignal2('Type',inType,'Name','dataOutPre');



    dataOut.SimulinkRate=rowMaxOutput(1).SimulinkRate;
    colMaxNet=this.addMinMaxTree(cNet,MinMaxBlockInfo,sigInfo,inRate,colMaxIn,dataOut,blockInfo.kHeight);
    pirelab.instantiateNetwork(cNet,colMaxNet,colMaxIn,dataOutREGIn,'colMax');




    pipeDelay=ceil(log2(blockInfo.kWidth))+ceil(log2(blockInfo.kHeight))+1;


    if blockInfo.kWidth==1&&all(blockInfo.Neighborhood(:,:))
        pipeDelay=ceil(log2(blockInfo.kHeight));
    elseif blockInfo.kWidth==1
        pipeDelay=ceil(log2(blockInfo.kHeight));
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

    pirelab.getIntDelayComp(cNet,hStartGate,hStartOut,pipeDelay);
    pirelab.getIntDelayComp(cNet,hEndGate,hEndOut,pipeDelay);
    pirelab.getIntDelayComp(cNet,vStartGate,vStartOut,pipeDelay);
    pirelab.getIntDelayComp(cNet,vEndGate,vEndOut,pipeDelay);
    pirelab.getIntDelayComp(cNet,validGate,validOutREG,pipeDelay-1);
    pirelab.getUnitDelayComp(cNet,validOutREG,validOut);
    pirelab.getBitwiseOpComp(cNet,validOutREG,notValid,'not');

    clkEnbGate=cNet.addSignal2('Type',boolType,'Name','clkEnbGate');


    constLow=cNet.addSignal2('Type',inType,'Name','CONSTANT_LOW');
    pirelab.getConstComp(cNet,constLow,fi(0,0,inType.WordLength,inType.FractionLength));


    if blockInfo.kWidth==1
        pirelab.getSwitchComp(cNet,[constLow,dataOutREGIn],dataOut,validOut);

    else
        pirelab.getUnitDelayResettableComp(cNet,dataOutREGIn,dataOut,notValid);
    end

















