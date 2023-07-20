function elaborateLineBuffer(this,topNet,blockInfo,varargin)












    if(mod(blockInfo.KernelHeight,2))==0
        blockInfo.effectiveKernelHeight=blockInfo.KernelHeight+1;
    else
        blockInfo.effectiveKernelHeight=blockInfo.KernelHeight;
    end

    if(mod(blockInfo.KernelWidth,2))==0
        blockInfo.effectiveKernelWidth=blockInfo.KernelWidth+1;
    else
        blockInfo.effectiveKernelWidth=blockInfo.KernelWidth;
    end










    if~isfield(blockInfo,'Exposed')
        blockInfo.Exposed=false;
    end

    if~isfield(blockInfo,'BiasUp')
        blockInfo.BiasUp=true;
    end

    if nargin==3
        inSignals=topNet.PirInputSignals;
        outSignals=topNet.PirOutputSignals;
    else
        inSignals=varargin{1};
        outSignals=varargin{2};

    end

    dataIn=inSignals(1);
    hStartIn=inSignals(2);
    hEndIn=inSignals(3);
    vStartIn=inSignals(4);
    vEndIn=inSignals(5);
    validIn=inSignals(6);


    dataRate=dataIn.SimulinkRate;


    hStartOut=outSignals(2);
    hEndOut=outSignals(3);
    vStartOut=outSignals(4);
    vEndOut=outSignals(5);
    validOut=outSignals(6);
    processDataOut=outSignals(7);


    booleanT=pir_boolean_t();

    inType=dataIn.Type;

    dI=struct(dataIn.Type);

    if isfield(dI,'Dimensions')
        blockInfo.NumPixels=double(dataIn.Type.Dimensions);
    else
        blockInfo.NumPixels=1;
    end
    aveType=pir_ufixpt_t(16,0);
    STAGE1T=pir_ufixpt_t(17,0);
    STAGE2T=pir_ufixpt_t(18,0);
    loadCountT=pir_ufixpt_t(8,0);

    if blockInfo.KernelHeight<=4
        lineStartT=pir_ufixpt_t(2,0);
    else
        lineStartT=pir_ufixpt_t(floor(blockInfo.KernelHeight/2),0);
    end

    countT=pir_ufixpt_t(ceil(log2(blockInfo.MaxLineSize)),0);

    if blockInfo.KernelHeight==2
        if blockInfo.NumPixels==1
            dataVType=pirelab.getPirVectorType(inType,[3,1],1);
            dataOType=pirelab.getPirVectorType(inType,[2,1],1);
        else
            dataVType=pirelab.createPirArrayType(inType.BaseType,[3,blockInfo.NumPixels]);
            dataOType=pirelab.createPirArrayType(inType.BaseType,[2,blockInfo.NumPixels]);

        end
        blockInfo.KernelHeight=3;
        blockInfo.KernelTwo=true;
    elseif blockInfo.KernelHeight==1
        dataVType=dataIn.Type;
        blockInfo.KernelTwo=false;
    elseif blockInfo.KernelHeight>2&&mod(blockInfo.KernelHeight,2)==0&&strcmpi(blockInfo.PaddingMethod,'Reflection')
        blockInfo.KernelHeight=blockInfo.KernelHeight+1;
        dataVType=pirelab.createPirArrayType(inType.BaseType,[blockInfo.KernelHeight,blockInfo.NumPixels]);
        dataOType=pirelab.createPirArrayType(inType.BaseType,[(blockInfo.KernelHeight-1),blockInfo.NumPixels]);
        blockInfo.KernelTwo=true;
    else
        dataVType=pirelab.createPirArrayType(inType.BaseType,[blockInfo.KernelHeight,blockInfo.NumPixels]);
        blockInfo.KernelTwo=false;
    end


    if blockInfo.KernelWidth==2
        blockInfo.KernelWidth=3;
        blockInfo.KernelWidthTwo=true;
    else
        blockInfo.KernelWidthTwo=false;
    end

    sigInfo.booleanT=booleanT;
    sigInfo.inType=inType;
    sigInfo.aveType=aveType;
    sigInfo.STAGE1T=STAGE1T;
    sigInfo.STAGE2T=STAGE2T;
    sigInfo.countT=countT;
    sigInfo.loadCountT=loadCountT;
    sigInfo.lineStartT=lineStartT;
    sigInfo.dataVType=dataVType;

    hStartInV=topNet.addSignal2('Type',booleanT,'Name','hStartV');
    hEndInV=topNet.addSignal2('Type',booleanT,'Name','hEndV');
    vStartInV=topNet.addSignal2('Type',booleanT,'Name','vStartV');
    vEndInV=topNet.addSignal2('Type',booleanT,'Name','vEndV');
    vEndInV.SimulinkRate=dataRate;
    vEndInREG=topNet.addSignal2('Type',booleanT,'Name','vEndREG');

    hStartInD=topNet.addSignal2('Type',booleanT,'Name','hStartInD');
    hEndInD=topNet.addSignal2('Type',booleanT,'Name','hEndInD');
    vStartInD=topNet.addSignal2('Type',booleanT,'Name','vStartInD');
    vEndInD=topNet.addSignal2('Type',booleanT,'Name','vEndInD');
    validInD=topNet.addSignal2('Type',booleanT,'Name','vEndInD');

    validInV=topNet.addSignal2('Type',booleanT,'Name','validInV');
    InBetween=topNet.addSignal2('Type',booleanT,'Name','InBetween');

    hEndInVREG=topNet.addSignal2('Type',booleanT,'Name','hEndV');
    vStartInVREG=topNet.addSignal2('Type',booleanT,'Name','vStartV');
    validInVREG=topNet.addSignal2('Type',booleanT,'Name','validInV');
    dataInREG=topNet.addSignal2('Type',inType,'Name','dataInREG');
    pirelab.getIntDelayComp(topNet,dataIn,dataInREG,4);



    InBetweenREG=topNet.addSignal2('Type',booleanT,'Name','InBetweenREG');
    hStartInVREG=topNet.addSignal2('Type',booleanT,'Name','hStartVREG');

    pirelab.getUnitDelayComp(topNet,InBetween,InBetweenREG);
    pirelab.getUnitDelayComp(topNet,hStartInV,hStartInVREG);

    pirelab.getIntDelayComp(topNet,vEndInV,vEndInREG,2);

    pirelab.getIntDelayComp(topNet,hStartIn,hStartInD,3);
    pirelab.getIntDelayComp(topNet,hEndIn,hEndInD,3);
    pirelab.getIntDelayComp(topNet,vStartIn,vStartInD,3);
    pirelab.getIntDelayComp(topNet,vEndIn,vEndInD,3);
    pirelab.getIntDelayComp(topNet,validIn,validInD,3);



    InputControlValidationNet=this.elaborateInputControlValidation(topNet,blockInfo,sigInfo,dataRate);

    InputControlValidationNetIn=[hStartInD,hEndInD,vStartInD,vEndInD,validInD];


    InputControlValidationNetOut=[hStartInV,hEndInV,vStartInV,vEndInV,validInV,InBetween];


    pirelab.instantiateNetwork(topNet,InputControlValidationNet,InputControlValidationNetIn,...
    InputControlValidationNetOut,'INPUT CONTROL VALIDATION');


    dataReadNet=this.elaborateDataReadController(topNet,blockInfo,sigInfo,dataRate);

    lineStartV=topNet.addSignal2('Type',lineStartT,'Name','LineStartV');
    lineAverage=topNet.addSignal2('Type',aveType,'Name','LineAverage');
    lineAveragePlus=topNet.addSignal2('Type',aveType,'Name','LineAveragePlus');
    ConstOne=topNet.addSignal2('Type',aveType,'Name','ConstOne');
    ConstOne.SimulinkRate=dataRate;
    lineAverageREG=topNet.addSignal2('Type',aveType,'Name','LineAverageREG');
    allEndOfLine=topNet.addSignal2('Type',booleanT,'Name','AllEndOfLine');
    allEndOfLineREG=topNet.addSignal2('Type',booleanT,'Name','AllEndOfLineREG');
    pirelab.getUnitDelayComp(topNet,allEndOfLine,allEndOfLineREG);
    blankCount=topNet.addSignal2('Type',aveType,'Name','BlankingCount');
    blankCount.SimulinkRate=dataRate;

    allEndOfLine.SimulinkRate=dataRate;
    lineStartV.SimulinkRate=dataRate;

    pirelab.getConstComp(topNet,ConstOne,1);
    pirelab.getAddComp(topNet,[lineAverage,ConstOne],lineAveragePlus);

    pirelab.getUnitDelayComp(topNet,lineAveragePlus,lineAverageREG);



    pirelab.getUnitDelayComp(topNet,hEndInV,hEndInVREG);
    pirelab.getUnitDelayComp(topNet,vStartInV,vStartInVREG);
    pirelab.getUnitDelayComp(topNet,validInV,validInVREG);



    dataReadNetIn=[hStartInVREG,hEndInVREG,vStartInVREG,vEndInREG,validInVREG,lineStartV,...
    lineAverageREG,allEndOfLineREG,blankCount,vStartIn];



    hStartR=topNet.addSignal2('Type',booleanT,'Name','hStartR');
    hEndR=topNet.addSignal2('Type',booleanT,'Name','hEndR');
    hEndRDT=topNet.addSignal2('Type',booleanT,'Name','hEndRDT');
    vStartR=topNet.addSignal2('Type',booleanT,'Name','vStartR');
    vEndR=topNet.addSignal2('Type',booleanT,'Name','vEndR');
    validR=topNet.addSignal2('Type',booleanT,'Name','validR');

    hStartRREG=topNet.addSignal2('Type',booleanT,'Name','hStartDRC');
    hEndRREG=topNet.addSignal2('Type',booleanT,'Name','hEndRREG');
    vStartRREG=topNet.addSignal2('Type',booleanT,'Name','vStartDRC');
    vEndRREG=topNet.addSignal2('Type',booleanT,'Name','vEndRREG');
    EndOrStart=topNet.addSignal2('Type',booleanT,'Name','EndOrStart');
    validRREG=topNet.addSignal2('Type',booleanT,'Name','validRREG');


    outputData=topNet.addSignal2('Type',booleanT,'Name','outputData');
    unloading=topNet.addSignal2('Type',booleanT,'Name','unloading');
    blankCountEn=topNet.addSignal2('Type',booleanT,'Name','blankCountEn');
    Running=topNet.addSignal2('Type',booleanT,'Name','Running');
    runOrUnload=topNet.addSignal2('Type',booleanT,'Name','runOrUnload');

    pirelab.getLogicComp(topNet,[unloading,Running],runOrUnload,'or');

    pirelab.getCounterComp(topNet,[hStartR,blankCountEn],blankCount,'Free running',...
    0,1,[],true,false,true,false,'Blank Count',0);


    dataReadNetOut=[hStartR,hEndR,vStartR,vEndR,validR,...
    outputData,unloading,blankCountEn,Running];


    pirelab.instantiateNetwork(topNet,dataReadNet,dataReadNetIn,...
    dataReadNetOut,'DATA_READ_CONTROLLER');




    pirelab.getUnitDelayComp(topNet,hStartR,hStartRREG);
    pirelab.getUnitDelayComp(topNet,hEndR,hEndRREG);
    pirelab.getUnitDelayComp(topNet,vStartR,vStartRREG);
    pirelab.getUnitDelayComp(topNet,vEndR,vEndRREG);
    pirelab.getUnitDelayComp(topNet,validR,validRREG);




    LineSpaceAverageNet=this.elaborateLineSpaceAverager(topNet,blockInfo,...
    sigInfo,dataRate);

    LineSpaceAverageNetIn=[InBetweenREG,hStartInVREG];

    pirelab.instantiateNetwork(topNet,LineSpaceAverageNet,LineSpaceAverageNetIn,...
    lineAverage,'LineSpaceAverager');


    lineInfoStoreNet=this.elaborateLineInfoStore(topNet,blockInfo,sigInfo,dataRate);


    pirelab.getLogicComp(topNet,[vStartIn,vEndRREG],EndOrStart,'or');

    lineInfoStoreIn=[hStartRREG,unloading,EndOrStart];


    lineInfoStoreOut=lineStartV;


    pirelab.instantiateNetwork(topNet,lineInfoStoreNet,lineInfoStoreIn,...
    lineInfoStoreOut,'LINE_INFO_STORE');


    dataMemoryNet=this.elaborateDataMemory(topNet,blockInfo,sigInfo,dataRate);


    popEn=topNet.addSignal2('Type',lineStartT,'Name','popEn');
    popEnREG=topNet.addSignal2('Type',lineStartT,'Name','popEnREG');
    popEn.SimulinkRate=dataRate;

    lineStartZero=topNet.addSignal2('Type',lineStartT,'Name','BooleanZero');
    lineStartZero.SimulinkRate=dataRate;
    pirelab.getConstComp(topNet,lineStartZero,2^blockInfo.KernelHeight);
    pirelab.getSwitchComp(topNet,[lineStartV,lineStartZero],popEn,unloading);

    pirelab.getUnitDelayComp(topNet,popEn,popEnREG);

    DataMemNetIn=[unloading,dataInREG,hStartRREG,hEndRREG,vStartRREG,vEndRREG,validRREG,popEn];



    popReg=topNet.addSignal2('Type',booleanT,'Name','popReg');
    AllAtEnd=topNet.addSignal2('Type',booleanT,'Name','AllAtEnd');







    DataVec=topNet.addSignal2('Type',dataVType,'Name','DataMemVector');
    DataVecValid=topNet.addSignal2('Type',dataVType,'Name','DataMemVectorValid');
    DataVecZero=topNet.addSignal2('Type',dataVType,'Name','DataMemVectorZero');
    DataVecZero.SimulinkRate=dataRate;
    pirelab.getConstComp(topNet,DataVecZero,0);
    DataVec.SimulinkRate=dataRate;
    popReg.SimulinkRate=dataRate;
    AllAtEnd.SimulinkRate=dataRate;
    DataMemNetOut=[DataVec,popReg,allEndOfLine];

    pirelab.instantiateNetwork(topNet,dataMemoryNet,DataMemNetIn,DataMemNetOut,'DATA_MEMORY');

    ctrlOutZero=topNet.addSignal2('Type',booleanT,'Name','ctrlOutZero');
    validRPre=topNet.addSignal2('Type',booleanT,'Name','validRPre');
    validRPreOutput=topNet.addSignal2('Type',booleanT,'Name','validRPreOutput');
    validRPreOutput.SimulinkRate=dataRate;
    ctrlOutZero.SimulinkRate=dataRate;
    pirelab.getConstComp(topNet,ctrlOutZero,0);

    pirelab.getSwitchComp(topNet,[DataVecZero,DataVec],DataVecValid,validRPreOutput);


    if blockInfo.KernelWidth>1&&~(strcmpi(blockInfo.PaddingMethod,'None'))



        stateFlagGenNet=this.elaborateStateFlagGen(topNet,blockInfo,sigInfo,dataRate);


        dumpControl=topNet.addSignal2('Type',booleanT,'Name','dumpControl');
        preProcess=topNet.addSignal2('Type',booleanT,'Name','preProcess');
        pirelab.getIntDelayComp(topNet,hEndR,hEndRDT,2);
        StateFlagGenIn=[hStartRREG,hEndRDT,vStartRREG,vEndRREG,validRREG,dumpControl,preProcess];


        PrePadFlag=topNet.addSignal2('Type',booleanT,'Name','PrePadFlag');
        OnLineFlag=topNet.addSignal2('Type',booleanT,'Name','OnLineFlag');
        PostPadFlag=topNet.addSignal2('Type',booleanT,'Name','PostPadFlag');
        DumpingFlag=topNet.addSignal2('Type',booleanT,'Name','DumpingFlag');
        BlankingFlag=topNet.addSignal2('Type',booleanT,'Name','BlankingFlag');
        hStartOutFG=topNet.addSignal2('Type',booleanT,'Name','hStartOutFG');
        hEndOutFG=topNet.addSignal2('Type',booleanT,'Name','hEndOutFG');
        vStartOutFG=topNet.addSignal2('Type',booleanT,'Name','vStartOutFG');
        vEndOutFG=topNet.addSignal2('Type',booleanT,'Name','vEndOutFG');
        validOutFG=topNet.addSignal2('Type',booleanT,'Name','validOutFG');
        StateFlagGenOut=[PrePadFlag,OnLineFlag,PostPadFlag,DumpingFlag,BlankingFlag,...
        hStartOutFG,hEndOutFG,vStartOutFG,vEndOutFG,validOutFG];




        pirelab.instantiateNetwork(topNet,stateFlagGenNet,StateFlagGenIn,StateFlagGenOut,'State Transition Flag Gen');





        padControlNet=this.elaboratePaddingController(topNet,blockInfo,sigInfo,dataRate);


        padControlNetIn=[PrePadFlag,OnLineFlag,PostPadFlag,DumpingFlag,BlankingFlag];


        processDataPC=topNet.addSignal2('Type',booleanT,'Name','processDataPC');
        countResetHC=topNet.addSignal2('Type',booleanT,'Name','countResetHC');
        countEnHC=topNet.addSignal2('Type',booleanT,'Name','countEnHC');
        padControlNetOut=[processDataPC,countResetHC,countEnHC,dumpControl,preProcess];


        pirelab.instantiateNetwork(topNet,padControlNet,padControlNetIn,padControlNetOut,'Padding Controller');




        gateProcessNet=this.elaborateGateProcessData(topNet,blockInfo,sigInfo,dataRate);


        gateProcessNetIn=[processDataPC,validRREG,dumpControl,outputData];


        processDataGated=topNet.addSignal2('Type',booleanT,'Name','processDataGated');
        processDataGatedD=topNet.addSignal2('Type',booleanT,'Name','processDataGatedD');
        processDataGatedRU=topNet.addSignal2('Type',booleanT,'Name','processDataGatedRU');



        dumpOrControl=topNet.addSignal2('Type',booleanT,'Name','dumpOrControl');

        gateProcessNetOut=[processDataGated,dumpOrControl];
        pirelab.getLogicComp(topNet,[processDataGated,DumpingFlag],processDataGatedD,'or');
        pirelab.getLogicComp(topNet,[runOrUnload,processDataGatedD],processDataGatedRU,'and');

        pirelab.instantiateNetwork(topNet,gateProcessNet,gateProcessNetIn,gateProcessNetOut,'Gate Process Data');



        countEnGate=topNet.addSignal2('Type',booleanT,'Name','countEnHC');
        horPadCount=topNet.addSignal2('Type',countT,'Name','horPadCount');
        horPadCountREG=topNet.addSignal2('Type',countT,'Name','horPadCountREG');
        pirelab.getLogicComp(topNet,[dumpOrControl,countEnHC],countEnGate,'and');

        pirelab.getCounterComp(topNet,[countResetHC,countEnGate],horPadCount,'Free running',...
        0,1,[],true,false,true,false,'Horizontal Pad Counter',0);




        horPadNet=this.elaborateHorizontalPadding(topNet,blockInfo,sigInfo,dataRate);

    else
        processDataGatedRU=topNet.addSignal2('Type',booleanT,'Name','processDataGatedRU');
        processDataGatedRU.SimulinkRate=dataRate;
        hStartOutFG=topNet.addSignal2('Type',booleanT,'Name','hStartOutFG');
        hEndOutFG=topNet.addSignal2('Type',booleanT,'Name','hEndOutFG');
        vStartOutFG=topNet.addSignal2('Type',booleanT,'Name','vStartOutFG');
        vEndOutFG=topNet.addSignal2('Type',booleanT,'Name','vEndOutFG');
        validOutFG=topNet.addSignal2('Type',booleanT,'Name','validOutFG');



        pirelab.getWireComp(topNet,validR,processDataGatedRU);

        pirelab.getWireComp(topNet,hStartR,hStartOutFG);
        pirelab.getWireComp(topNet,hEndR,hEndOutFG);
        pirelab.getWireComp(topNet,vStartR,vStartOutFG);
        pirelab.getWireComp(topNet,vEndR,vEndOutFG);
        pirelab.getWireComp(topNet,validR,validOutFG);

    end





    if blockInfo.KernelWidth>1&&~(strcmpi(blockInfo.PaddingMethod,'None'))

        padShift=topNet.addSignal2('Type',booleanT,'Name','padShift');
        DataVecREG=topNet.addSignal2('Type',dataVType,'Name','DataMemVectorREG');

        pirelab.getIntDelayEnabledComp(topNet,DataVec,DataVecREG,padShift,1);

        pirelab.getUnitDelayComp(topNet,horPadCount,horPadCountREG);

        pirelab.getLogicComp(topNet,[popReg,dumpControl],padShift,'or');
        horPadNetIn=[DataVecREG,horPadCountREG,padShift];


        DataVecPadded=topNet.addSignal2('Type',dataVType,'Name','DataMemVectorPadded');


        pirelab.instantiateNetwork(topNet,horPadNet,horPadNetIn,DataVecPadded,'Horizontal Padder');
    else
        DataVecPadded=topNet.addSignal2('Type',dataVType,'Name','DataMemVectorPadded');
        DataVecPadded.SimulinkRate=dataRate;
        DataVecREG=topNet.addSignal2('Type',dataVType,'Name','DataMemVectorREG');

        pirelab.getUnitDelayComp(topNet,DataVec,DataVecREG);

        pirelab.getWireComp(topNet,DataVecREG,DataVecPadded);

    end

    if blockInfo.KernelHeight>1&&~(strcmpi(blockInfo.PaddingMethod,'None'))


        verCountNet=this.elaborateVerticalCounter(topNet,blockInfo,sigInfo,dataRate);


        verCountIn=[vStartIn,unloading,Running,hStartR];


        verCountOut=topNet.addSignal2('Type',countT,'Name','VerCountOut');


        pirelab.instantiateNetwork(topNet,verCountNet,verCountIn,verCountOut,'Vertical Counter');
    end


    verPadOut=topNet.addSignal2('Type',dataVType,'Name','verPadOut');
    verPadD=topNet.addSignal2('Type',dataVType,'Name','verPadD');
    constZero=topNet.addSignal2('Type',dataVType,'Name','constZero');
    constZero.SimulinkRate=dataRate;
    dataSigOut=topNet.addSignal2('Type',dataVType,'Name','dataSigOut');
    dataSigPre=topNet.addSignal2('Type',dataVType,'Name','dataSigPre');
    dataSigPreOD=topNet.addSignal2('Type',dataVType,'Name','dataSigPreOD');

    pirelab.getConstComp(topNet,constZero,0);

    if blockInfo.KernelHeight>1&&~(strcmpi(blockInfo.PaddingMethod,'None'))



        verPadNet=this.elaborateVerticalPadding(topNet,blockInfo,sigInfo,dataRate);


        verPadIn=[DataVecPadded,verCountOut];

        if blockInfo.KernelTwo
            dataVecCast=topNet.addSignal2('Type',dataOType,'Name','dataVecCast');
        end

        processDataGatedTwo=topNet.addSignal2('Type',booleanT,'Name','processDataGatedTwo');




        pirelab.instantiateNetwork(topNet,verPadNet,verPadIn,verPadOut,'Vertical Padder');



    else


        lineCountF=topNet.addSignal2('Type',countT,'Name','lineCountF');
        lineCountF.SimulinkRate=dataRate;
        initLine=topNet.addSignal2('Type',booleanT,'Name','initLine');
        initLine.SimulinkRate=dataRate;
        firstNLine=topNet.addSignal2('Type',booleanT,'Name','firstNLine');
        firstNLine.SimulinkRate=dataRate;
        initLineN=topNet.addSignal2('Type',booleanT,'Name','initLineN');
        pirelab.getLogicComp(topNet,[Running,hStartR],initLine,'and');
        if blockInfo.KernelTwo
            dataVecCast=topNet.addSignal2('Type',dataOType,'Name','dataVecCast');
            dataVecCast.SimulinkRate=dataRate;
        end

        if mod(blockInfo.KernelHeight,2)==0&&blockInfo.BiasUp
            pirelab.getCompareToValueComp(topNet,lineCountF,firstNLine,'<',floor(blockInfo.KernelHeight/2)-1);
        else
            pirelab.getCompareToValueComp(topNet,lineCountF,firstNLine,'<',floor(blockInfo.KernelHeight/2));
        end

        pirelab.getLogicComp(topNet,[initLine,firstNLine],initLineN,'and');

        pirelab.getCounterComp(topNet,[vStartIn,initLineN],lineCountF,'Free running',...
        0,1,[],true,false,true,false,'Line Counter',0);

        if blockInfo.NumPixels==1

            for ii=1:1:blockInfo.KernelHeight
                dataLineIn(ii)=topNet.addSignal2('Type',inType,'Name',['DataLineIn',num2str(ii)]);%#ok<AGROW>
                dataLineIn(ii).SimulinkRate=dataRate;%#ok<AGROW>
                dataLineOut(ii)=topNet.addSignal2('Type',inType,'Name',['DataLineOut',num2str(ii)]);%#ok<AGROW>
                dataLineOut(ii).SimulinkRate=dataRate;%#ok<AGROW>
            end

            pirelab.getDemuxComp(topNet,DataVecPadded,dataLineIn);

            if mod(blockInfo.KernelHeight,2)==0
                EvenKernelConstant=1;%#ok<NASGU>
            else
                EvenKernelConstant=0;%#ok<NASGU>
            end


            if blockInfo.BiasUp
                BiasConstant=0;%#ok<NASGU>
            else
                BiasConstant=1;%#ok<NASGU>
            end


            dataPadValue=topNet.addSignal2('Type',inType,'Name','DataPadValue');
            dataPadValue.SimulinkRate=dataRate;
            pirelab.getConstComp(topNet,dataPadValue,0);

            if mod(blockInfo.KernelHeight,2)==0
                for ii=1:1:blockInfo.KernelHeight


                    if ii==ceil(blockInfo.KernelHeight/2)+1
                        lineSEL(ii)=topNet.addSignal2('Type',booleanT,'Name',['lineSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getWireComp(topNet,dataLineIn(ii),dataLineOut(ii));

                    elseif ii<ceil(blockInfo.KernelHeight/2)+1
                        lineSEL(ii)=topNet.addSignal2('Type',booleanT,'Name',['lineSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getCompareToValueComp(topNet,lineCountF,lineSEL(ii),'>',(floor(blockInfo.KernelHeight/2)+(ii)));
                        pirelab.getSwitchComp(topNet,[dataLineIn(ii),dataPadValue],dataLineOut(ii),lineSEL(ii));
                    elseif ii>ceil(blockInfo.KernelHeight/2)+1
                        lineSEL(ii)=topNet.addSignal2('Type',booleanT,'Name',['lineSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getCompareToValueComp(topNet,lineCountF,lineSEL(ii),'<',ii-ceil(blockInfo.KernelHeight/2)-1);
                        pirelab.getSwitchComp(topNet,[dataLineIn(ii),dataPadValue],dataLineOut(ii),lineSEL(ii));
                    end



                end
            else
                for ii=1:1:blockInfo.KernelHeight

                    if ii==ceil(blockInfo.KernelHeight/2)
                        lineSEL(ii)=topNet.addSignal2('Type',booleanT,'Name',['lineSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getWireComp(topNet,dataLineIn(ii),dataLineOut(ii));

                    elseif ii<ceil(blockInfo.KernelHeight/2)
                        lineSEL(ii)=topNet.addSignal2('Type',booleanT,'Name',['lineSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getCompareToValueComp(topNet,lineCountF,lineSEL(ii),'>',(floor(blockInfo.KernelHeight/2)+(ii-1)));
                        pirelab.getSwitchComp(topNet,[dataLineIn(ii),dataPadValue],dataLineOut(ii),lineSEL(ii));
                    elseif ii>ceil(blockInfo.KernelHeight/2)
                        lineSEL(ii)=topNet.addSignal2('Type',booleanT,'Name',['lineSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getCompareToValueComp(topNet,lineCountF,lineSEL(ii),'<',ii-ceil(blockInfo.KernelHeight/2));
                        pirelab.getSwitchComp(topNet,[dataLineIn(ii),dataPadValue],dataLineOut(ii),lineSEL(ii));
                    end
                end


            end

            DataVecCorrected=topNet.addSignal2('Type',dataVType,'Name','DataMemVectorPadded');
            DataVecCorrected.SimulinkRate=dataRate;
            pirelab.getMuxComp(topNet,dataLineOut,DataVecCorrected);

            if(strcmpi(blockInfo.PaddingMethod,'None'))
                if blockInfo.Exposed
                    if blockInfo.KernelWidth==1
                        pirelab.getUnitDelayComp(topNet,DataVecCorrected,verPadOut);
                    else
                        pirelab.getIntDelayComp(topNet,DataVecCorrected,verPadOut,2);
                    end
                else
                    pirelab.getUnitDelayComp(topNet,DataVecCorrected,verPadOut);
                end
            else
                pirelab.getWireComp(topNet,DataVecCorrected,verPadOut);

            end


        else



            colType=pirelab.createPirArrayType(inType.BaseType,[1,inType.Dimensions]);

            for ii=1:1:blockInfo.KernelHeight*blockInfo.NumPixels
                dataLineInPre(ii)=topNet.addSignal2('Type',colType.BaseType,'Name',['DataLineIn',num2str(ii)]);%#ok<NASGU,AGROW>
            end


            for ii=1:1:blockInfo.KernelHeight
                dataLineIn(ii)=topNet.addSignal2('Type',colType,'Name',['DataLineIn',num2str(ii)]);%#ok<AGROW>
                dataLineOut(ii)=topNet.addSignal2('Type',colType,'Name',['DataLineOut',num2str(ii)]);%#ok<AGROW>
            end

            dataTType=pirelab.createPirArrayType(colType.BaseType,[colType.Dimensions,blockInfo.KernelHeight]);
            dataVectorTranpose=topNet.addSignal2('Type',dataTType,'Name','DataVectorTranpose');
            pirelab.getTransposeComp(topNet,DataVecPadded,dataVectorTranpose);



            dataVectorSplit=dataVectorTranpose.split;

            for kk=1:1:blockInfo.KernelHeight
                pirelab.getWireComp(topNet,dataVectorSplit.PirOutputSignals(kk),dataLineIn(kk));
            end

            if mod(blockInfo.KernelHeight,2)==0
                EvenKernelConstant=1;%#ok<NASGU>
            else
                EvenKernelConstant=0;%#ok<NASGU>
            end


            if blockInfo.BiasUp
                BiasConstant=0;
            else
                BiasConstant=1;
            end


            dataPadValue=topNet.addSignal2('Type',colType,'Name','DataPadValue');
            dataPadValue.SimulinkRate=dataRate;
            pirelab.getConstComp(topNet,dataPadValue,blockInfo.PaddingValue);

            if mod(blockInfo.KernelHeight,2)==0
                for ii=1:1:blockInfo.KernelHeight


                    if ii<ceil(blockInfo.KernelHeight/2)+1
                        verSEL(ii)=topNet.addSignal2('Type',booleanT,'Name',['verSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getCompareToValueComp(topNet,lineCountF,verSEL(ii),'>',(floor(blockInfo.KernelHeight/2)+(ii-2))+BiasConstant);
                        pirelab.getSwitchComp(topNet,[dataLineIn(ii),dataPadValue],dataLineOut(ii),verSEL(ii));

                    elseif ii>ceil(blockInfo.KernelHeight/2)
                        verSEL(ii)=topNet.addSignal2('Type',booleanT,'Name',['verSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getCompareToValueComp(topNet,lineCountF,verSEL(ii),'<',ii-ceil(blockInfo.KernelHeight/2)-1+BiasConstant);
                        pirelab.getSwitchComp(topNet,[dataLineIn(ii),dataPadValue],dataLineOut(ii),verSEL(ii));

                    end
                end
            else
                for ii=1:1:blockInfo.KernelHeight

                    if ii==ceil(blockInfo.KernelHeight/2)
                        verSEL(ii)=topNet.addSignal2('Type',booleanT,'Name',['verSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getWireComp(topNet,dataLineIn(ii),dataLineOut(ii));

                    elseif ii<ceil(blockInfo.KernelHeight/2)
                        verSEL(ii)=topNet.addSignal2('Type',booleanT,'Name',['verSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getCompareToValueComp(topNet,lineCountF,verSEL(ii),'>',(floor(blockInfo.KernelHeight/2)+(ii-1)));
                        pirelab.getSwitchComp(topNet,[dataLineIn(ii),dataPadValue],dataLineOut(ii),verSEL(ii));

                    elseif ii>ceil(blockInfo.KernelHeight/2)
                        verSEL(ii)=topNet.addSignal2('Type',booleanT,'Name',['verSEL',num2str(ii)]);%#ok<AGROW>
                        pirelab.getCompareToValueComp(topNet,lineCountF,verSEL(ii),'<',ii-ceil(blockInfo.KernelHeight/2));
                        pirelab.getSwitchComp(topNet,[dataLineIn(ii),dataPadValue],dataLineOut(ii),verSEL(ii));

                    end
                end


            end

            DataVecCorrected=topNet.addSignal2('Type',dataVType,'Name','DataMemVectorPadded');
            pirelab.getConcatenateComp(topNet,dataLineOut,DataVecCorrected,'VecConcatOut','1');



            if blockInfo.Exposed
                pirelab.getIntDelayComp(topNet,DataVecCorrected,verPadOut,2);
            else
                pirelab.getUnitDelayComp(topNet,DataVecCorrected,verPadOut);
            end



        end





    end



    processDataP=topNet.addSignal2('Type',booleanT,'Name','processDataP');
    processDataOD=topNet.addSignal2('Type',booleanT,'Name','processDataOD');

    if blockInfo.NumPixels>1
        processDataPreOut=topNet.addSignal2('Type',booleanT,'Name','processDataPreOut');
    end

    outputProcess=topNet.addSignal2('Type',booleanT,'Name','outputProcess');


    if blockInfo.KernelWidth>1&&~(strcmpi(blockInfo.PaddingMethod,'None'))
        pirelab.getUnitDelayComp(topNet,verPadOut,verPadD);
        pirelab.getSwitchComp(topNet,[constZero,verPadD],dataSigOut,outputProcess);
    else
        pirelab.getUnitDelayComp(topNet,verPadOut,verPadD);


    end
    hStartRD=topNet.addSignal2('Type',booleanT,'Name','hStartRD');
    hStartRDP=topNet.addSignal2('Type',booleanT,'Name','hStartRDP');
    hEndRD=topNet.addSignal2('Type',booleanT,'Name','hEndRD');
    vStartRD=topNet.addSignal2('Type',booleanT,'Name','vStartRD');%#ok<NASGU>
    vEndRD=topNet.addSignal2('Type',booleanT,'Name','vEndRD');
    vEndRDH=topNet.addSignal2('Type',booleanT,'Name','vEndRDH');
    validRD=topNet.addSignal2('Type',booleanT,'Name','validRD');


    hStartP=topNet.addSignal2('Type',booleanT,'Name','hStartP');
    hEndP=topNet.addSignal2('Type',booleanT,'Name','hEndP');
    hEndPInt=topNet.addSignal2('Type',booleanT,'Name','hEndPInt');%#ok<NASGU>
    vStartP=topNet.addSignal2('Type',booleanT,'Name','vStartP');
    vEndP=topNet.addSignal2('Type',booleanT,'Name','vEndP');
    validP=topNet.addSignal2('Type',booleanT,'Name','validP');
    hEndGate=topNet.addSignal2('Type',booleanT,'Name','hEndGate');
    hEndGateN=topNet.addSignal2('Type',booleanT,'Name','hEndGateN');
    hEndFGG=topNet.addSignal2('Type',booleanT,'Name','hEndFGG');
    validFGG=topNet.addSignal2('Type',booleanT,'Name','validFGG');

    validOD=topNet.addSignal2('Type',booleanT,'Name','validOD');
    outputDataREG=topNet.addSignal2('Type',booleanT,'Name','outputDataREG');



    validRDEnd=topNet.addSignal2('Type',booleanT,'Name','validRDEnd');
    vStartGate=topNet.addSignal2('Type',booleanT,'Name','vStartGate');
    vStartGate.SimulinkRate=dataRate;
    frameStarted=topNet.addSignal2('Type',booleanT,'Name','frameStarted');
    frameStartedN=topNet.addSignal2('Type',booleanT,'Name','frameStartedN');


    if blockInfo.KernelWidth>1&&~(strcmpi(blockInfo.PaddingMethod,'None'))
        pirelab.getLogicComp(topNet,frameStarted,frameStartedN,'not');
        pirelab.getUnitDelayEnabledResettableComp(topNet,hStartP,frameStarted,hStartP,vStartIn);
        pirelab.getLogicComp(topNet,[hStartP,frameStartedN],vStartGate,'and');
        pirelab.getLogicComp(topNet,[outputData,processDataP],outputProcess,'and');


        pirelab.getSwitchComp(topNet,[ctrlOutZero,hStartRD],hStartP,outputProcess);
        pirelab.getSwitchComp(topNet,[ctrlOutZero,hEndRD],hEndP,outputProcess);
        pirelab.getSwitchComp(topNet,[ctrlOutZero,vStartGate],vStartP,outputProcess);
        pirelab.getSwitchComp(topNet,[ctrlOutZero,vEndRDH],vEndP,outputProcess);
        pirelab.getSwitchComp(topNet,[ctrlOutZero,validRDEnd],validP,outputProcess);
    else

        pirelab.getLogicComp(topNet,frameStarted,frameStartedN,'not');
        pirelab.getUnitDelayEnabledResettableComp(topNet,hStartOut,frameStarted,hStartOut,vStartIn);
        pirelab.getLogicComp(topNet,[hStartP,frameStartedN],vStartGate,'and');
        pirelab.getLogicComp(topNet,[outputData,processDataP],outputProcess,'and');



        pirelab.getWireComp(topNet,hStartR,hStartP);
        pirelab.getWireComp(topNet,hEndR,hEndP);
        pirelab.getWireComp(topNet,vStartGate,vStartP);
        pirelab.getWireComp(topNet,vEndR,vEndP);
        pirelab.getWireComp(topNet,validR,validP);


    end


    if blockInfo.KernelWidth>1&&~(strcmpi(blockInfo.PaddingMethod,'None'))

        PSNet=this.elaborateMultiPixelProcessMask(topNet,blockInfo,sigInfo,dataRate);


        if blockInfo.Exposed

            pirelab.getIntDelayComp(topNet,hStartP,hStartOut,2);
            pirelab.getIntDelayComp(topNet,hEndP,hEndOut,2);
            pirelab.getIntDelayComp(topNet,vStartP,vStartOut,2);
            pirelab.getIntDelayComp(topNet,vEndP,vEndOut,2);
            pirelab.getIntDelayComp(topNet,validP,validOD,2);

            pirelab.getUnitDelayComp(topNet,outputData,outputDataREG);
            pirelab.getSwitchComp(topNet,[ctrlOutZero,validOD],validOut,outputDataREG);
            if blockInfo.NumPixels==1
                pirelab.getIntDelayComp(topNet,processDataP,processDataOD,2);
            else
                pirelab.getUnitDelayComp(topNet,processDataP,processDataOD);
            end

            if blockInfo.NumPixels==1
                pirelab.getSwitchComp(topNet,[ctrlOutZero,processDataOD],processDataOut,outputDataREG);
            else
                processDataPost=topNet.addSignal2('Type',booleanT,'Name','frameStartedN');
                hStartPost=topNet.addSignal2('Type',booleanT,'Name','frameStartedN');
                hEndPost=topNet.addSignal2('Type',booleanT,'Name','frameStartedN');

                pirelab.getUnitDelayComp(topNet,hStartP,hStartPost);
                pirelab.getUnitDelayComp(topNet,hEndP,hEndPost);

                pirelab.getSwitchComp(topNet,[ctrlOutZero,processDataOD],processDataPreOut,outputDataREG);
                pirelab.instantiateNetwork(topNet,PSNet,[processDataPreOut,hStartPost,hEndPost],processDataPost,'Multi Pixel Process Shorten');
                pirelab.getUnitDelayComp(topNet,processDataPost,processDataOut);

            end

            if~blockInfo.KernelTwo
                pirelab.getIntDelayComp(topNet,dataSigOut,dataSigPreOD,2);

                if blockInfo.NumPixels==1
                    pirelab.getSwitchComp(topNet,[constZero,dataSigPreOD],outSignals(1),outputDataREG);
                elseif blockInfo.KernelWidth==4
                    outputDataPost=topNet.addSignal2('Type',booleanT,'Name','outputDataPost');
                    pirelab.getLogicComp(topNet,[processDataOut,outputDataREG],outputDataPost,'and');
                    pirelab.getSwitchComp(topNet,[constZero,dataSigPreOD],outSignals(1),outputDataPost);
                else
                    pirelab.getSwitchComp(topNet,[constZero,dataSigPreOD],outSignals(1),processDataOut);
                end
            else
                if blockInfo.NumPixels==1
                    pirelab.getIntDelayComp(topNet,dataSigOut,dataSigPre,2);

                    for ii=1:1:blockInfo.KernelHeight
                        dataArray(ii)=topNet.addSignal2('Type',inType,'Name','DataArray');%#ok<AGROW>
                    end

                    pirelab.getDemuxComp(topNet,dataSigPre,dataArray);
                    pirelab.getWireComp(topNet,dataVecCast,outSignals(1));

                    if blockInfo.BiasUp
                        pirelab.getMuxComp(topNet,dataArray(1:(blockInfo.KernelHeight-1)),dataVecCast);
                    else
                        pirelab.getMuxComp(topNet,dataArray(2:blockInfo.KernelHeight),dataVecCast);
                    end
                elseif strcmpi(blockInfo.PaddingMethod,'Reflection')

                    colType=pirelab.createPirArrayType(inType.BaseType,[1,inType.Dimensions]);
                    dataTType=pirelab.createPirArrayType(colType.BaseType,[colType.Dimensions,blockInfo.KernelHeight]);

                    dataVectorTranpose=topNet.addSignal2('Type',dataTType,'Name','DataTranpose');
                    pirelab.getTransposeComp(topNet,dataSigOut,dataVectorTranpose);


                    dataVectorSplit=dataVectorTranpose.split;


                    for ii=1:1:blockInfo.KernelHeight
                        dataArray(ii)=topNet.addSignal2('Type',colType,'Name',['DataLineIn',num2str(ii)]);%#ok<AGROW>
                    end

                    for kk=1:1:blockInfo.KernelHeight
                        pirelab.getWireComp(topNet,dataVectorSplit.PirOutputSignals(kk),dataArray(kk));
                    end


                    if blockInfo.BiasUp
                        pirelab.getMuxComp(topNet,dataArray(1:(blockInfo.KernelHeight-1)),dataVecCast);
                    else
                        pirelab.getMuxComp(topNet,dataArray(2:blockInfo.KernelHeight),dataVecCast);
                    end


                    dataSigPreOut=topNet.addSignal2('Type',dataOType,'Name','DataSigPreOut');
                    pirelab.getIntDelayComp(topNet,dataVecCast,dataSigPreOut,2);


                    constZeroOT=topNet.addSignal2('Type',dataOType,'Name','constZeroOT');
                    constZeroOT.SimulinkRate=dataRate;
                    pirelab.getConstComp(topNet,constZeroOT,0);

                    pirelab.getSwitchComp(topNet,[constZeroOT,dataSigPreOut],outSignals(1),processDataOut);

                else
                    pirelab.getIntDelayComp(topNet,dataSigOut,dataSigPre,2);



                    dataTType=pirelab.createPirArrayType(inType.BaseType,[blockInfo.NumPixels,blockInfo.KernelHeight]);

                    outType=pirelab.createPirArrayType(inType.BaseType,[(blockInfo.KernelHeight-1),blockInfo.NumPixels]);

                    rowType=pirelab.createPirArrayType(inType.BaseType,[1,blockInfo.NumPixels]);
                    dataVectorTranpose=topNet.addSignal2('Type',dataTType,'Name','DataVectorTranpose');
                    outSigPre=topNet.addSignal2('Type',outType,'Name','DataVectorTranpose');
                    outSigProcess=topNet.addSignal2('Type',outType,'Name','DataVectorProcess');
                    dataZero=topNet.addSignal2('Type',outType,'Name','DataVectorZero');
                    for ii=1:1:(blockInfo.KernelHeight-1)
                        dataRow(ii)=topNet.addSignal2('Type',rowType,'Name','DataVectorTranpose');%#ok<AGROW>
                    end


                    pirelab.getTransposeComp(topNet,dataSigPre,dataVectorTranpose);

                    dataVecSplit=dataVectorTranpose.split.PirOutputSignals;















                    pirelab.getConstComp(topNet,dataZero,0);

                    if blockInfo.BiasUp
                        for ii=1:1:(blockInfo.KernelHeight-1)
                            pirelab.getWireComp(topNet,dataVecSplit(ii),dataRow(ii));
                        end


                    else
                        for ii=2:1:blockInfo.KernelHeight
                            pirelab.getWireComp(topNet,dataVecSplit(ii),dataRow(ii-1));
                        end


                    end

                    pirelab.getConcatenateComp(topNet,dataRow(:),outSigPre,'outputRows','1');
                    pirelab.getSwitchComp(topNet,[dataZero,outSigPre],outSigProcess,processDataOut);
                    pirelab.getWireComp(topNet,outSigProcess,outSignals(1));

                end
            end

            if~blockInfo.KernelWidthTwo

                pirelab.getIntDelayComp(topNet,processDataGatedRU,processDataP,2);
            else
                if blockInfo.BiasUp

                    processDataGatedTwo=topNet.addSignal2('Type',booleanT,'Name','processDataGatedTwo');

                    pirelab.getSwitchComp(topNet,[processDataGatedRU,ctrlOutZero],processDataGatedTwo,hStartOutFG);
                    pirelab.getIntDelayComp(topNet,processDataGatedTwo,processDataP,2);

                else
                    processDataGatedTwo=topNet.addSignal2('Type',booleanT,'Name','processDataGatedTwo');

                    holdLow=topNet.addSignal2('Type',booleanT,'Name','holdLow');

                    pirelab.getUnitDelayEnabledResettableComp(topNet,hEndP,holdLow,hEndP,hStartOutFG);
                    pirelab.getSwitchComp(topNet,[processDataGatedTwo,ctrlOutZero],processDataP,holdLow);
                    pirelab.getIntDelayComp(topNet,processDataGatedRU,processDataGatedTwo,2);
                end

            end


        else

            pirelab.getUnitDelayComp(topNet,hStartP,hStartOut);
            pirelab.getUnitDelayComp(topNet,hEndP,hEndOut);
            pirelab.getUnitDelayComp(topNet,vStartP,vStartOut);
            pirelab.getUnitDelayComp(topNet,vEndP,vEndOut);
            pirelab.getUnitDelayComp(topNet,validP,validOD);
            if blockInfo.NumPixels==1

                pirelab.getUnitDelayComp(topNet,processDataP,processDataOD);
            else
                pirelab.getWireComp(topNet,processDataP,processDataOD);
            end
            pirelab.getUnitDelayComp(topNet,outputData,outputDataREG);
            pirelab.getSwitchComp(topNet,[ctrlOutZero,validOD],validOut,outputDataREG);


            if blockInfo.NumPixels==1
                pirelab.getSwitchComp(topNet,[ctrlOutZero,processDataOD],processDataOut,outputDataREG);
            else
                processDataPost=topNet.addSignal2('Type',booleanT,'Name','frameStartedN');
                hStartPost=topNet.addSignal2('Type',booleanT,'Name','frameStartedN');
                hEndPost=topNet.addSignal2('Type',booleanT,'Name','frameStartedN');

                pirelab.getWireComp(topNet,hStartP,hStartPost);
                pirelab.getWireComp(topNet,hEndP,hEndPost);

                pirelab.getSwitchComp(topNet,[ctrlOutZero,processDataOD],processDataPreOut,outputDataREG);
                pirelab.instantiateNetwork(topNet,PSNet,[processDataPreOut,hStartPost,hEndPost],processDataPost,'Multi Pixel Process Shorten');
                pirelab.getUnitDelayComp(topNet,processDataPost,processDataOut);

            end




            if~blockInfo.KernelTwo
                pirelab.getUnitDelayComp(topNet,dataSigOut,dataSigPreOD);
                pirelab.getSwitchComp(topNet,[constZero,dataSigPreOD],outSignals(1),outputDataREG);


            else
                pirelab.getUnitDelayComp(topNet,dataSigOut,dataSigPre);

                if blockInfo.NumPixels==1
                    for ii=1:1:blockInfo.KernelHeight
                        dataArray(ii)=topNet.addSignal2('Type',inType,'Name','DataArray');%#ok<AGROW>
                    end


                    pirelab.getDemuxComp(topNet,dataSigPre,dataArray);
                    pirelab.getWireComp(topNet,dataVecCast,outSignals(1));

                    if blockInfo.BiasUp
                        pirelab.getMuxComp(topNet,dataArray(1:(blockInfo.KernelHeight-1)),dataVecCast);
                    else
                        pirelab.getMuxComp(topNet,dataArray(2:blockInfo.KernelHeight),dataVecCast);
                    end

                elseif strcmpi(blockInfo.PaddingMethod,'Reflection')

                    colType=pirelab.createPirArrayType(inType.BaseType,[1,inType.Dimensions]);
                    dataTType=pirelab.createPirArrayType(colType.BaseType,[colType.Dimensions,blockInfo.KernelHeight]);

                    dataVectorTranpose=topNet.addSignal2('Type',dataTType,'Name','DataTranpose');
                    pirelab.getTransposeComp(topNet,dataSigOut,dataVectorTranpose);


                    dataVectorSplit=dataVectorTranpose.split;


                    for ii=1:1:blockInfo.KernelHeight
                        dataArray(ii)=topNet.addSignal2('Type',colType,'Name',['DataLineIn',num2str(ii)]);%#ok<AGROW>
                    end

                    for kk=1:1:blockInfo.KernelHeight
                        pirelab.getWireComp(topNet,dataVectorSplit.PirOutputSignals(kk),dataArray(kk));
                    end


                    if blockInfo.BiasUp
                        pirelab.getMuxComp(topNet,dataArray(1:(blockInfo.KernelHeight-1)),dataVecCast);
                    else
                        pirelab.getMuxComp(topNet,dataArray(2:blockInfo.KernelHeight),dataVecCast);
                    end


                    dataSigPreOut=topNet.addSignal2('Type',dataOType,'Name','DataSigPreOut');
                    pirelab.getIntDelayComp(topNet,dataVecCast,dataSigPreOut,2);


                    constZeroOT=topNet.addSignal2('Type',dataOType,'Name','constZeroOT');
                    constZeroOT.SimulinkRate=dataRate;
                    pirelab.getConstComp(topNet,constZeroOT,0);

                    pirelab.getSwitchComp(topNet,[constZeroOT,dataSigPreOut],outSignals(1),processDataOut);

                else
                    dataTType=pirelab.createPirArrayType(inType.BaseType,[blockInfo.NumPixels,3]);
                    dataVectorTranpose=topNet.addSignal2('Type',dataTType,'Name','DataVectorTranpose');
                    outType=pirelab.createPirArrayType(inType.BaseType,[2,blockInfo.NumPixels]);
                    rowType=pirelab.createPirArrayType(inType.BaseType,[1,blockInfo.NumPixels]);
                    dataRow(1)=topNet.addSignal2('Type',rowType,'Name','DataVectorTranpose');
                    dataRow(2)=topNet.addSignal2('Type',rowType,'Name','DataVectorTranpose');
                    outSigPre=topNet.addSignal2('Type',outType,'Name','DataVectorTranpose');

                    pirelab.getTransposeComp(topNet,dataSigPre,dataVectorTranpose);

                    dataVecSplit=dataVectorTranpose.split.PirOutputSignals;

                    if blockInfo.BiasUp
                        pirelab.getWireComp(topNet,dataVecSplit(1),dataRow(1));
                        pirelab.getWireComp(topNet,dataVecSplit(2),dataRow(2));
                    else
                        pirelab.getWireComp(topNet,dataVecSplit(2),dataRow(1));
                        pirelab.getWireComp(topNet,dataVecSplit(3),dataRow(2));
                    end

                    pirelab.getConcatenateComp(topNet,dataRow(:),outSigPre,'outputRows','1');
                    pirelab.getWireComp(topNet,outSigPre,outSignals(1));
                end
            end

            if~blockInfo.KernelWidthTwo
                pirelab.getIntDelayComp(topNet,processDataGatedRU,processDataP,2);
            else
                pirelab.getUnitDelayComp(topNet,processDataP,processDataOut);

                if blockInfo.BiasUp
                    pirelab.getSwitchComp(topNet,[processDataGatedRU,ctrlOutZero],processDataGatedTwo,hStartOutFG);
                    pirelab.getIntDelayComp(topNet,processDataGatedTwo,processDataP,2);
                else
                    holdLow=topNet.addSignal2('Type',booleanT,'Name','holdLow');
                    pirelab.getUnitDelayEnabledResettableComp(topNet,hEndP,holdLow,hEndP,hStartOutFG);
                    pirelab.getSwitchComp(topNet,[processDataGatedTwo,ctrlOutZero],processDataP,holdLow);
                    pirelab.getIntDelayComp(topNet,processDataGatedRU,processDataGatedTwo,2);
                end
            end
        end


        pirelab.getLogicComp(topNet,[validRD,hEndRD],validRDEnd,'or');
        pirelab.getLogicComp(topNet,[vEndRD,hEndRD],vEndRDH,'and');

        pirelab.getUnitDelayEnabledResettableComp(topNet,hEndOutFG,hEndGate,hEndOutFG,hStartOutFG);
        pirelab.getLogicComp(topNet,hEndGate,hEndGateN,'not');
        pirelab.getLogicComp(topNet,[hEndOutFG,hEndGateN],hEndFGG,'and');
        pirelab.getLogicComp(topNet,[validOutFG,hEndGateN],validFGG,'and');



        pirelab.getIntDelayComp(topNet,hStartOutFG,hStartRDP,2);
        pirelab.getUnitDelayComp(topNet,hStartRDP,hStartRD);
        pirelab.getIntDelayComp(topNet,hEndFGG,hEndRD,3);


        if blockInfo.KernelHeight>1
            pirelab.getIntDelayComp(topNet,vEndOutFG,vEndRD,4);
        else
            if blockInfo.Exposed
                pirelab.getIntDelayComp(topNet,vEndOutFG,vEndRD,3);
            else
                if blockInfo.KernelWidth<=3
                    pirelab.getIntDelayComp(topNet,vEndOutFG,vEndRD,2);
                else
                    pirelab.getIntDelayComp(topNet,vEndOutFG,vEndRD,3);
                end
            end
        end

        pirelab.getIntDelayComp(topNet,validFGG,validRPre,2);
        pirelab.getUnitDelayComp(topNet,validRPre,validRD);
        pirelab.getLogicComp(topNet,[validRPre,outputData],validRPreOutput,'and');
    else

        hStartPre=topNet.addSignal2('Type',booleanT,'Name','hStartPre');
        hEndPre=topNet.addSignal2('Type',booleanT,'Name','hEndPre');
        vStartPre=topNet.addSignal2('Type',booleanT,'Name','vStartPre');
        vEndPre=topNet.addSignal2('Type',booleanT,'Name','vEndPre');
        validPre=topNet.addSignal2('Type',booleanT,'Name','validPre');
        validPreU=topNet.addSignal2('Type',booleanT,'Name','validPreU');
        hStartPreD=topNet.addSignal2('Type',booleanT,'Name','hStartPreD');
        hEndPreD=topNet.addSignal2('Type',booleanT,'Name','hEndPreD');
        vStartPreD=topNet.addSignal2('Type',booleanT,'Name','vStartPreD');
        vEndPreD=topNet.addSignal2('Type',booleanT,'Name','vEndPreD');
        validPreD=topNet.addSignal2('Type',booleanT,'Name','validPreD');
        validPreD.SimulinkRate=dataRate;
        validPreUD=topNet.addSignal2('Type',booleanT,'Name','validPreUD');%#ok<NASGU>


        if blockInfo.Exposed
            pirelab.getSwitchComp(topNet,[constZero,verPadOut],dataSigOut,validPreD);




            if~blockInfo.KernelTwo&&~strcmpi(blockInfo.PaddingMethod,'Reflection')
                pirelab.getWireComp(topNet,dataSigOut,outSignals(1));
            elseif strcmpi(blockInfo.PaddingMethod,'Reflection')
                if blockInfo.KernelTwo
                    for ii=1:1:blockInfo.KernelHeight
                        dataArray(ii)=topNet.addSignal2('Type',inType.BaseType,'Name',['DataArray_',num2str(ii)]);%#ok<AGROW>
                    end

                    pirelab.getDemuxComp(topNet,dataSigOut,dataArray);

                    dataVecCast=topNet.addSignal2('Type',dataOType,'Name','dataVecCast');

                    if blockInfo.BiasUp
                        pirelab.getMuxComp(topNet,dataArray(1:(end-1)),dataVecCast);
                    else
                        pirelab.getMuxComp(topNet,dataArray(2:end),dataVecCast);
                    end

                    pirelab.getWireComp(topNet,dataVecCast,outSignals(1));
                else
                    pirelab.getWireComp(topNet,dataSigOut,outSignals(1));
                end
            else
                pirelab.getWireComp(topNet,dataSigOut,dataSigPre);

                if blockInfo.NumPixels==1

                    for ii=1:1:3
                        dataArray(ii)=topNet.addSignal2('Type',inType,'Name','DataArray');%#ok<AGROW>
                    end

                    pirelab.getDemuxComp(topNet,dataSigPre,dataArray);
                    pirelab.getWireComp(topNet,dataVecCast,outSignals(1));

                    if blockInfo.BiasUp
                        pirelab.getMuxComp(topNet,dataArray(1:2),dataVecCast);
                    else
                        pirelab.getMuxComp(topNet,dataArray(2:3),dataVecCast);

                    end
                else





                    dataTType=pirelab.createPirArrayType(inType.BaseType,[blockInfo.NumPixels,3]);
                    outType=pirelab.createPirArrayType(inType.BaseType,[2,blockInfo.NumPixels]);
                    rowType=pirelab.createPirArrayType(inType.BaseType,[1,blockInfo.NumPixels]);
                    dataVectorTranpose=topNet.addSignal2('Type',dataTType,'Name','DataVectorTranpose');
                    outSigPre=topNet.addSignal2('Type',outType,'Name','DataVectorTranpose');
                    outSigProcess=topNet.addSignal2('Type',outType,'Name','DataVectorProcess');
                    dataZero=topNet.addSignal2('Type',outType,'Name','DataVectorZero');
                    dataZero.SimulinkRate=dataRate;
                    dataRow(1)=topNet.addSignal2('Type',rowType,'Name','DataVectorTranpose');
                    dataRow(2)=topNet.addSignal2('Type',rowType,'Name','DataVectorTranpose');
                    pirelab.getTransposeComp(topNet,dataSigPre,dataVectorTranpose);

                    dataVecSplit=dataVectorTranpose.split.PirOutputSignals;















                    pirelab.getConstComp(topNet,dataZero,0);
                    pirelab.getWireComp(topNet,dataVecSplit(1),dataRow(1));
                    pirelab.getWireComp(topNet,dataVecSplit(2),dataRow(2));
                    pirelab.getConcatenateComp(topNet,dataRow(:),outSigPre,'outputRows','1');
                    pirelab.getSwitchComp(topNet,[dataZero,outSigPre],outSigProcess,processDataOut);
                    pirelab.getWireComp(topNet,outSigProcess,outSignals(1));

                end
            end
            if(strcmpi(blockInfo.PaddingMethod,'None'))

                if blockInfo.KernelWidth==1
                    pirelab.getIntDelayComp(topNet,hStartP,hStartPre,4);
                    pirelab.getIntDelayComp(topNet,hEndP,hEndPre,6);
                    pirelab.getIntDelayComp(topNet,vStartP,vStartPre,4);
                    pirelab.getIntDelayComp(topNet,vEndP,vEndPre,5);
                    pirelab.getIntDelayComp(topNet,validP,validPre,5);
                    pirelab.getLogicComp(topNet,[validPre,hEndPre],validPreU,'or');
                else
                    pirelab.getIntDelayComp(topNet,hStartP,hStartPre,5);
                    pirelab.getIntDelayComp(topNet,hEndP,hEndPre,7);
                    pirelab.getIntDelayComp(topNet,vStartP,vStartPre,5);
                    if blockInfo.KernelHeight==1
                        pirelab.getIntDelayComp(topNet,vEndP,vEndPre,5);
                    else
                        pirelab.getIntDelayComp(topNet,vEndP,vEndPre,6);
                    end
                    pirelab.getIntDelayComp(topNet,validP,validPre,6);
                    pirelab.getLogicComp(topNet,[validPre,hEndPre],validPreU,'or');

                end

            else
                pirelab.getIntDelayComp(topNet,hStartP,hStartPre,3);
                pirelab.getIntDelayComp(topNet,hEndP,hEndPre,5);
                pirelab.getIntDelayComp(topNet,vStartP,vStartPre,3);
                pirelab.getIntDelayComp(topNet,vEndP,vEndPre,4);
                pirelab.getIntDelayComp(topNet,validP,validPre,4);
                pirelab.getLogicComp(topNet,[validPre,hEndPre],validPreU,'or');


            end

        else
            pirelab.getSwitchComp(topNet,[constZero,verPadOut],dataSigOut,validPreD);

            if~blockInfo.KernelTwo

                pirelab.getWireComp(topNet,dataSigOut,outSignals(1));

            else
                pirelab.getWireComp(topNet,dataSigOut,dataSigPre);

                if blockInfo.NumPixels==1

                    for ii=1:1:3
                        dataArray(ii)=topNet.addSignal2('Type',inType,'Name','DataArray');%#ok<AGROW>
                    end

                    pirelab.getDemuxComp(topNet,dataSigPre,dataArray);
                    pirelab.getWireComp(topNet,dataVecCast,outSignals(1));

                    if blockInfo.BiasUp
                        pirelab.getMuxComp(topNet,dataArray(1:2),dataVecCast);
                    else
                        pirelab.getMuxComp(topNet,dataArray(2:3),dataVecCast);

                    end
                else





                    dataTType=pirelab.createPirArrayType(inType.BaseType,[blockInfo.NumPixels,3]);
                    outType=pirelab.createPirArrayType(inType.BaseType,[2,blockInfo.NumPixels]);
                    rowType=pirelab.createPirArrayType(inType.BaseType,[1,blockInfo.NumPixels]);
                    dataVectorTranpose=topNet.addSignal2('Type',dataTType,'Name','DataVectorTranpose');
                    outSigPre=topNet.addSignal2('Type',outType,'Name','DataVectorTranpose');
                    outSigProcess=topNet.addSignal2('Type',outType,'Name','DataVectorProcess');
                    dataZero=topNet.addSignal2('Type',outType,'Name','DataVectorZero');
                    dataZero.SimulinkRate=dataRate;
                    dataRow(1)=topNet.addSignal2('Type',rowType,'Name','DataVectorTranpose');
                    dataRow(2)=topNet.addSignal2('Type',rowType,'Name','DataVectorTranpose');
                    pirelab.getTransposeComp(topNet,dataSigPre,dataVectorTranpose);

                    dataVecSplit=dataVectorTranpose.split.PirOutputSignals;















                    pirelab.getConstComp(topNet,dataZero,0);
                    pirelab.getWireComp(topNet,dataVecSplit(1),dataRow(1));
                    pirelab.getWireComp(topNet,dataVecSplit(2),dataRow(2));
                    pirelab.getConcatenateComp(topNet,dataRow(:),outSigPre,'outputRows','1');
                    pirelab.getSwitchComp(topNet,[dataZero,outSigPre],outSigProcess,processDataOut);
                    pirelab.getWireComp(topNet,outSigProcess,outSignals(1));

                end


            end


            if(strcmpi(blockInfo.PaddingMethod,'None'))
                pirelab.getIntDelayComp(topNet,hStartP,hStartPre,4);
                pirelab.getIntDelayComp(topNet,hEndP,hEndPre,6);
                pirelab.getIntDelayComp(topNet,vStartP,vStartPre,4);

                if blockInfo.KernelHeight==1
                    pirelab.getIntDelayComp(topNet,vEndP,vEndPre,4);
                else
                    pirelab.getIntDelayComp(topNet,vEndP,vEndPre,5);
                end
                pirelab.getIntDelayComp(topNet,validP,validPre,5);
                pirelab.getLogicComp(topNet,[validPre,hEndPre],validPreU,'or');
            else
                pirelab.getIntDelayComp(topNet,hStartP,hStartPre,3);
                pirelab.getIntDelayComp(topNet,hEndP,hEndPre,5);
                pirelab.getIntDelayComp(topNet,vStartP,vStartPre,3);
                pirelab.getIntDelayComp(topNet,vEndP,vEndPre,4);
                pirelab.getIntDelayComp(topNet,validP,validPre,4);
                pirelab.getLogicComp(topNet,[validPre,hEndPre],validPreU,'or');
            end


        end




        pirelab.getSwitchComp(topNet,[ctrlOutZero,hStartPre],hStartPreD,outputData);
        pirelab.getSwitchComp(topNet,[ctrlOutZero,hEndPre],hEndPreD,outputData);
        pirelab.getSwitchComp(topNet,[ctrlOutZero,vStartPre],vStartPreD,outputData);
        pirelab.getSwitchComp(topNet,[ctrlOutZero,vEndPre],vEndPreD,outputData);
        pirelab.getSwitchComp(topNet,[ctrlOutZero,validPreU],validPreD,outputData);

        pirelab.getUnitDelayComp(topNet,hStartPreD,hStartOut);
        pirelab.getWireComp(topNet,hEndPreD,hEndOut);
        pirelab.getUnitDelayComp(topNet,vStartPreD,vStartOut);
        pirelab.getUnitDelayComp(topNet,vEndPreD,vEndOut);
        pirelab.getWireComp(topNet,validPreD,validOut);


        pirelab.getWireComp(topNet,validOut,processDataOut);

    end

