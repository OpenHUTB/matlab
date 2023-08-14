function elaborateDVBS2BCHDecoderNetwork(this,topNet,blockInfo,insignals,outsignals)







    dataIn=insignals(1);
    startInput=insignals(2);
    endInput=insignals(3);
    validInput=insignals(4);



    dataOut=outsignals(1);
    startOut=outsignals(2);
    endOut=outsignals(3);
    validOut=outsignals(4);







    if blockInfo.NumErrorsOutputPort
        nextFrame=outsignals(6);
        numErrOut=outsignals(5);
        hasErrPort=true;

    else
        numErrOut=[];
        hasErrPort=false;
        nextFrame=outsignals(5);
    end

    rate=dataIn.SimulinkRate;
    dataOut.SimulinkRate=rate;
    startOut.SimulinkRate=rate;
    endOut.SimulinkRate=rate;
    validOut.SimulinkRate=rate;
    nextFrame.SimulinkRate=rate;
    numErrOut.SimulinkRate=rate;




    vecLen=length(dataIn);
    maxCorr=24;


    uFix4Type=pir_ufixpt_t(4,0);
    sFix5Type=pir_sfixpt_t(5,0);
    uint32=pir_ufixpt_t(32,0);
    uint16=pir_ufixpt_t(16,0);
    controlType=pir_ufixpt_t(1,0);


    FECFrameTypeDelay=newControlSignal(topNet,'FECFrameTypeDelay',rate);



    if strcmp(blockInfo.CodeRateSource,'Input port')

        codeRateIdxTemp=newDataSignal(topNet,uFix4Type,'codeRateIdxTemp',rate);
        codeRateIdx=newDataSignal(topNet,uFix4Type,'codeRateIdx',rate);
        pirelab.getUnitDelayEnabledComp(topNet,insignals(5),codeRateIdxTemp,startInput,'',0);
        pirelab.getSwitchComp(topNet,[codeRateIdxTemp,insignals(5)],codeRateIdx,startInput)

        FECFrameTypeProperty=newControlSignal(topNet,'FECFrameTypeProperty',rate);
        if strcmp(blockInfo.FECFrameType,'Normal')
            pirelab.getConstComp(topNet,FECFrameTypeProperty,0);
        else
            pirelab.getConstComp(topNet,FECFrameTypeProperty,1);
        end
        pirelab.getIntDelayComp(topNet,FECFrameTypeProperty,FECFrameTypeDelay,1,'',0);
    else
        FECFrameTypeProperty=newControlSignal(topNet,'FECFrameTypeProperty',rate);
        if strcmp(blockInfo.FECFrameType,'Normal')
            pirelab.getConstComp(topNet,FECFrameTypeProperty,0);
        else
            pirelab.getConstComp(topNet,FECFrameTypeProperty,1);
        end
        pirelab.getIntDelayComp(topNet,FECFrameTypeProperty,FECFrameTypeDelay,1,'',0);
        codeRateIdx=newDataSignal(topNet,uFix4Type,'codeRateIdx',rate);
        pirelab.getConstComp(topNet,codeRateIdx,blockInfo.CodeRateIdx);

    end

    N=newDataSignal(topNet,uint16,'N',rate);
    NMinusOne=newDataSignal(topNet,uint16,'NMinusOne',rate);
    K=newDataSignal(topNet,uint16,'K',rate);
    tCorr=newDataSignal(topNet,uint16,'tCorr',rate);
    doubleCorr=newDataSignal(topNet,uint16,'doubleCorr',rate);
    N_Delay=newDataSignal(topNet,uint16,'N_Delay',rate);
    K_Delay=newDataSignal(topNet,uint16,'K_Delay',rate);
    tCorr_Delay=newDataSignal(topNet,uint16,'tCorr_Delay',rate);

    N_long=newDataSignal(topNet,uint16,'N_long',rate);
    N_long32Bit=newDataSignal(topNet,uint32,'N_long32bit',rate);
    N_longMinusOne=newDataSignal(topNet,uint16,'N_longMinusOne',rate);
    N_long32BitMinusOne=newDataSignal(topNet,uint16,'N_long32BitMinusOne',rate);

    pirelab.getDTCComp(topNet,N_long,N_long32Bit,'floor','Wrap','SI');
    K_long=newDataSignal(topNet,uint16,'K_long',rate);
    oneconst=newDataSignal(topNet,uint16,'oneconst',rate);

    if strcmp(blockInfo.FECFrameType,'Normal')
        bitLength=16;



        pirelab.getConstComp(topNet,N_long,2^16-1);



        N_Normal_LUT=ufi([16200,21600,25920,32400,38880,43200,48600,51840,54000,57600,58320],16,0);
        K_Normal_LUT=ufi([16008,21408,25728,32208,38688,43040,48408,51648,53840,57472,58192],16,0);
        tCorr_Normal_LUT=ufi([12,12,12,12,12,10,12,12,10,8,8],16,0);

        pirelab.getDirectLookupComp(topNet,codeRateIdx,N,N_Normal_LUT,'N_Normal_LUT');
        pirelab.getDirectLookupComp(topNet,codeRateIdx,K,K_Normal_LUT,'K_Normal_LUT');
        pirelab.getDirectLookupComp(topNet,codeRateIdx,tCorr,tCorr_Normal_LUT,'tCorr_Normal_LUT');
    else
        bitLength=14;



        pirelab.getConstComp(topNet,N_long,2^14-1);




        N_Short_LUT=ufi([3240,5400,6480,7200,9720,10800,11880,12600,13320,14400],16,0);
        K_Short_LUT=ufi([3072,5232,6312,7032,9552,10632,11712,12432,13152,14232],16,0);
        tCorr=newDataSignal(topNet,uint16,'tCorr',rate);
        pirelab.getConstComp(topNet,tCorr,12);


        pirelab.getDirectLookupComp(topNet,codeRateIdx,N,N_Short_LUT,'N_Short_LUT');
        pirelab.getDirectLookupComp(topNet,codeRateIdx,K,K_Short_LUT,'K_Short_LUT');
    end



    pirelab.getSubComp(topNet,[N_long,tCorr],K_long);
    pirelab.getBitShiftComp(topNet,tCorr,doubleCorr,'sll',1);






    gfTables=coder.load(fullfile(matlabroot,'toolbox','whdl','whdl','+satcomhdl','+internal','dvbs2BCH_GFTables.mat'),'GFTable');

    if strcmp(blockInfo.FECFrameType,'Normal')

        gfTable1_16=ufi(gfTables.GFTable(1).table1,16,0);
        gfTable2_16=ufi(gfTables.GFTable(1).table2,16,0);
        gfTable2_16(1)=ufi(2^16-1,16,0);
    else

        gfTable1_14=ufi(gfTables.GFTable(2).table1,16,0);
        gfTable2_14=ufi(gfTables.GFTable(2).table2,16,0);
        gfTable2_14(1)=ufi(2^14-1,16,0);
    end

    nextFrameLowTime=newDataSignal(topNet,uint16,'nextFrameLowTime',rate);
    pirelab.getSubComp(topNet,[N_long,N],nextFrameLowTime);


    startIn=newControlSignal(topNet,'startin_valid',rate);
    endIn_valid=newControlSignal(topNet,'endin_valid',rate);
    validIn=newControlSignal(topNet,'validIn',rate);

    sampleControlNet=this.elabSampleControl(topNet,blockInfo,rate);
    sampleControlNet.addComment('Sample control for valid start and end');



    sampleCountVal=newDataSignal(topNet,uint16,'sampleCountVal',rate);
    sampleCountValDelay=newDataSignal(topNet,uint16,'sampleCountValDelay',rate);
    sampleCountMax=newControlSignal(topNet,'sampleCountMax',rate);
    sampleCountMaxTemp=newControlSignal(topNet,'sampleCountMaxTemp',rate);
    sampleCountRst=newControlSignal(topNet,'sampleCountRst',rate);
    sampleCountEnb=newControlSignal(topNet,'sampleCountEnb',rate);
    falseEnd=newControlSignal(topNet,'falseEnd',rate);
    endInOr=newControlSignal(topNet,'endInOr',rate);

    notendin=newControlSignal(topNet,'notendin',rate);
    inpacket=newControlSignal(topNet,'inpacket',rate);
    inpacketnext=newControlSignal(topNet,'inpacketnext',rate);
    notdonepacket=newControlSignal(topNet,'notdonepacket',rate);
    endIn=newControlSignal(topNet,'endin_packet',rate);

    pirelab.getCounterComp(topNet,[sampleCountRst,startIn,oneconst,sampleCountEnb],sampleCountVal,...
    'Count limited',...
    0.0,...
    vecLen,...
    65535,...
    true,...
    true,...
    true,...
    false,...
    'sampleCounter');
    pirelab.getBitwiseOpComp(topNet,[validIn,inpacketnext],sampleCountEnb,'AND');
    pirelab.getRelOpComp(topNet,[sampleCountVal,NMinusOne],sampleCountMaxTemp,'==');
    pirelab.getBitwiseOpComp(topNet,[sampleCountMaxTemp,validIn],sampleCountMax,'AND');
    pirelab.getBitwiseOpComp(topNet,[sampleCountMax,endInput],sampleCountRst,'OR');




    inports(1)=startInput;
    inports(2)=endInput;
    inports(3)=validInput;
    inports(4)=sampleCountMax;
    inports(5)=endOut;

    outports(1)=startIn;
    outports(2)=endIn_valid;
    outports(3)=validIn;
    outports(4)=nextFrame;
    pirelab.instantiateNetwork(topNet,sampleControlNet,inports,outports,'sampleControlNet_inst');
    pirelab.getBitwiseOpComp(topNet,endIn,notendin,'NOT');
    pirelab.getBitwiseOpComp(topNet,[notendin,inpacket],notdonepacket,'AND');
    pirelab.getBitwiseOpComp(topNet,[startIn,notdonepacket],inpacketnext,'OR');
    pirelab.getUnitDelayComp(topNet,inpacketnext,inpacket,'inpacketreg',0.0);

    pirelab.getBitwiseOpComp(topNet,[endIn_valid,sampleCountMax],endIn,'AND');


    dataInDelay=newControlSignal(topNet,['dataInDelay'],rate);

    validInDelay=newControlSignal(topNet,'validInDelay',rate);
    startInDelay=newControlSignal(topNet,'startInDelay',rate);
    endInDelay=newControlSignal(topNet,'endInDelay',rate);
    endInDelay2=newControlSignal(topNet,'endInDelay2',rate);
    endInDelay3=newControlSignal(topNet,'endInDelay3',rate);

    pirelab.getUnitDelayComp(topNet,dataIn,dataInDelay,'datainputdelay',0.0);
    pirelab.getUnitDelayComp(topNet,startIn,startInDelay,'startdelay',0.0);
    pirelab.getUnitDelayComp(topNet,endIn,endInDelay,'enddelay',0.0);
    pirelab.getUnitDelayComp(topNet,endInDelay,endInDelay2,'enddelay2',0.0);
    pirelab.getUnitDelayComp(topNet,endInDelay2,endInDelay3,'enddelay3',0.0);
    pirelab.getUnitDelayComp(topNet,validIn,validInDelay,'dvdelay',0.0);

    zeroconst=newDataSignal(topNet,uint16,'zeroconst',rate);
    pirelab.getConstComp(topNet,zeroconst,0,'zeroconst');
    falseconst=newControlSignal(topNet,'falseConstant',rate);
    pirelab.getConstComp(topNet,falseconst,0);



    counterRst=newControlSignal(topNet,'counterRst',rate);
    counterMax=newControlSignal(topNet,'counterMax',rate);
    counterEnb=newControlSignal(topNet,'counterEnb',rate);
    counterVal=newDataSignal(topNet,uint16,'counterVal',rate);

    pirelab.getConstComp(topNet,oneconst,1,'oneconst');
    pirelab.getCompareToValueComp(topNet,counterVal,counterEnb,'>',0,'counterEnbComp');
    pirelab.getRelOpComp(topNet,[counterVal,nextFrameLowTime],counterMax,'==','counterRstComp');
    pirelab.getBitwiseOpComp(topNet,[startIn,counterMax],counterRst,'OR');
    pirelab.getSubComp(topNet,[N,oneconst],NMinusOne);

    pirelab.getCounterComp(topNet,[counterRst,endIn,oneconst,counterEnb],counterVal,...
    'Count limited',...
    0.0,...
    1.0,...
    65535,...
    true,...
    true,...
    true,...
    false,...
    'nextFramecounter');





















    pirelab.getUnitDelayComp(topNet,sampleCountVal,sampleCountValDelay);

    dataValidIn=newControlSignal(topNet,['dataValidIn'],rate);
    pirelab.getBitwiseOpComp(topNet,[dataInDelay,validInDelay],dataValidIn,'AND');
    vecLenConst=newDataSignal(topNet,uint16,['vecLenConst'],rate);
    pirelab.getConstComp(topNet,vecLenConst,1);
    pirelab.getSubComp(topNet,[N_long32Bit,oneconst],N_long32BitMinusOne);

    dataValidInD5=newControlSignal(topNet,'dataValidInD5',rate);
    startInD5=newControlSignal(topNet,'startInD5',rate);
    pirelab.getIntDelayComp(topNet,startIn,startInD5,5,'',0,'');
    pirelab.getIntDelayComp(topNet,dataValidIn,dataValidInD5,5,'',0,'');

    for ii=1:maxCorr/2
        eleValTemp(ii)=newDataSignal(topNet,uint16,['eleValTemp_',num2str(ii)],rate);
        eleValTemp1(ii)=newDataSignal(topNet,uint16,['eleValTemp1_',num2str(ii)],rate);
        eleValTemp2(ii)=newDataSignal(topNet,uint16,['eleValTemp2_',num2str(ii)],rate);
        eleValTemp32Bit(ii)=newDataSignal(topNet,uint32,['eleValTemp32Bit_',num2str(ii)],rate);
        eleVal(ii)=newDataSignal(topNet,uint16,['eleVal_',num2str(ii)],rate);
        eleValminusonetemp(ii)=newDataSignal(topNet,uint16,['eleValminusonetemp_',num2str(ii)],rate);
        eleValminusonetemp1(ii)=newDataSignal(topNet,uint16,['eleValminusonetemp1_',num2str(ii)],rate);
        eleValminusonetemp2(ii)=newDataSignal(topNet,uint16,['eleValminusonetemp2_',num2str(ii)],rate);
        eleValminusone(ii)=newDataSignal(topNet,uint16,['eleValminusone_',num2str(ii)],rate);
        eleValSum(ii)=newDataSignal(topNet,uint16,['eleValSum_',num2str(ii)],rate);
        eleValSumValid(ii)=newDataSignal(topNet,uint16,['eleValSumValid_',num2str(ii)],rate);
        eleValSum_N(ii)=newDataSignal(topNet,uint16,['eleValSum_N',num2str(ii)],rate);
        eleValSum_S(ii)=newDataSignal(topNet,uint16,['eleValSum_S',num2str(ii)],rate);
        syndrometemp(ii)=newDataSignal(topNet,uint16,['syndrometemp_',num2str(ii)],rate);
        syntemp(ii)=newDataSignal(topNet,uint16,['syntemp_',num2str(ii)],rate);

        eleIdxVal(ii)=newDataSignal(topNet,uint16,['eleIdxVal_',num2str(ii)],rate);
        eleIdxValDelay(ii)=newDataSignal(topNet,uint16,['eleIdxValDelay_',num2str(ii)],rate);
        eleIdxVal32Bit(ii)=newDataSignal(topNet,uint16,['eleIdxVal32Bit_',num2str(ii)],rate);
        eleIdxValTemp(ii)=newDataSignal(topNet,uint16,['eleIdxValTemp_',num2str(ii)],rate);
        eleIdxValTempIsZero(ii)=newControlSignal(topNet,['eleIdxValTempIsZero_',num2str(ii)],rate);
        eleIdxValNormal(ii)=newDataSignal(topNet,uint16,['eleIdxValNormal_',num2str(ii)],rate);
        eleIdxValShort(ii)=newDataSignal(topNet,uint16,['eleIdxValShort_',num2str(ii)],rate);
        sampCountProduct(ii)=newDataSignal(topNet,uint32,['sampCountProduct_',num2str(ii)],rate);
        sampCountProductDelay(ii)=newDataSignal(topNet,uint32,['sampCountProductDelay_',num2str(ii)],rate);
        sampCountProductDelay1(ii)=newDataSignal(topNet,uint32,['sampCountProductDelay1_',num2str(ii)],rate);
        sampCountProductwrap(ii)=newControlSignal(topNet,['sampCountProductwrap_',num2str(ii)],rate);
        sampCountProductslice(ii)=newDataSignal(topNet,uint16,['sampCountProductSlice_',num2str(ii)],rate);
        sampCountProductslice_14bit(ii)=newDataSignal(topNet,pir_fixpt_t(0,14,0),['sampCountProductSlice_14bit_',num2str(ii)],rate);
        sampCountProductShift(ii)=newDataSignal(topNet,uint32,['sampCountProductShift_',num2str(ii)],rate);
        sampCountProductreduced(ii)=newDataSignal(topNet,uint16,['sampCountProductreduced_',num2str(ii)],rate);
        sampCountProductreduced_14bit(ii)=newDataSignal(topNet,pir_fixpt_t(0,14,0),['sampCountProductreduced_14Bit_',num2str(ii)],rate);
        sampCountProductrem(ii)=newDataSignal(topNet,uint32,['sampCountProductrem_',num2str(ii)],rate);
        sampCountProductrem1(ii)=newDataSignal(topNet,uint32,['sampCountProductrem1_',num2str(ii)],rate);
        remCompare(ii)=newControlSignal(topNet,['remCompare_',num2str(ii)],rate);
        sampCountProductlog(ii)=newDataSignal(topNet,uint32,['sampCountProductlog_',num2str(ii)],rate);
        sampCountProductFlag(ii)=newControlSignal(topNet,['sampCountProductFlag_',num2str(ii)],rate);
        eleValCompareZero(ii)=newControlSignal(topNet,['eleValCompareZero_',num2str(ii)],rate);
        sampCountVal(ii)=newDataSignal(topNet,uint16,['sampCountVal_',num2str(ii)],rate);
        modComp(ii)=newControlSignal(topNet,['modComp_',num2str(ii)],rate);
        isNLong(ii)=newControlSignal(topNet,['isNLong_',num2str(ii)],rate);
        synLenConst(ii)=newDataSignal(topNet,uint16,['synLenConst_',num2str(ii)],rate);
        pirelab.getConstComp(topNet,synLenConst(ii),2*ii-1);

        pirelab.getAddComp(topNet,[sampleCountValDelay,vecLenConst],sampCountVal(ii));

        pirelab.getSubComp(topNet,[N,sampCountVal(ii)],eleIdxValTemp(ii));
        pirelab.getCompareToValueComp(topNet,eleIdxValTemp(ii),eleIdxValTempIsZero(ii),'==',0);
        pirelab.getSwitchComp(topNet,[eleIdxValTemp(ii),N_long],eleIdxVal(ii),eleIdxValTempIsZero(ii));
        pirelab.getUnitDelayResettableComp(topNet,eleIdxVal(ii),eleIdxValDelay(ii),counterRst);
        pirelab.getMulComp(topNet,[eleIdxValDelay(ii),synLenConst(ii)],sampCountProduct(ii));
        pirelab.getUnitDelayComp(topNet,sampCountProduct(ii),sampCountProductDelay(ii));
        pirelab.getUnitDelayComp(topNet,sampCountProductDelay(ii),sampCountProductDelay1(ii));


        if strcmp(blockInfo.FECFrameType,'Normal')
            pirelab.getBitSliceComp(topNet,sampCountProductDelay1(ii),sampCountProductslice(ii),15,0);
            pirelab.getBitShiftComp(topNet,sampCountProductDelay1(ii),sampCountProductShift(ii),'srl',16,0);
            pirelab.getBitSliceComp(topNet,sampCountProductShift(ii),sampCountProductreduced(ii),15,0);
            pirelab.getAddComp(topNet,[sampCountProductslice(ii),sampCountProductreduced(ii)],sampCountProductrem(ii),'Floor','Wrap');
            pirelab.getRelOpComp(topNet,[sampCountProductrem(ii),N_long],remCompare(ii),'>');
            pirelab.getSubComp(topNet,[sampCountProductrem(ii),N_long],sampCountProductrem1(ii),'Floor','Wrap');
            pirelab.getSwitchComp(topNet,[sampCountProductrem(ii),sampCountProductrem1(ii)],sampCountProductlog(ii),remCompare(ii),'modmux');
        else
            pirelab.getBitSliceComp(topNet,sampCountProductDelay1(ii),sampCountProductslice_14bit(ii),13,0);
            pirelab.getBitShiftComp(topNet,sampCountProductDelay1(ii),sampCountProductShift(ii),'srl',14,0);
            pirelab.getBitSliceComp(topNet,sampCountProductShift(ii),sampCountProductreduced_14bit(ii),13,0);
            pirelab.getAddComp(topNet,[sampCountProductslice_14bit(ii),sampCountProductreduced_14bit(ii)],sampCountProductrem(ii),'Floor','Wrap');
            pirelab.getRelOpComp(topNet,[sampCountProductrem(ii),N_long],remCompare(ii),'>');
            pirelab.getSubComp(topNet,[sampCountProductrem(ii),N_long],sampCountProductrem1(ii),'Floor','Wrap');
            pirelab.getSwitchComp(topNet,[sampCountProductrem(ii),sampCountProductrem1(ii)],sampCountProductlog(ii),remCompare(ii),'modmux1');
        end
        pirelab.getDTCComp(topNet,sampCountProductlog(ii),eleValTemp1(ii),'floor','Wrap','SI');
        pirelab.getAddComp(topNet,[eleValTemp1(ii),oneconst],eleValTemp2(ii));
        pirelab.getRelOpComp(topNet,[eleValTemp1(ii),N_long32Bit],sampCountProductFlag(ii),'==');
        pirelab.getSwitchComp(topNet,[eleValTemp1(ii),N_long32Bit],eleValTemp(ii),sampCountProductFlag(ii));

        pirelab.getCompareToValueComp(topNet,eleValTemp(ii),eleValCompareZero(ii),'==',0);
        pirelab.getSubComp(topNet,[N_long,oneconst],N_longMinusOne);
        pirelab.getSwitchComp(topNet,[eleValTemp(ii),N_longMinusOne],eleVal(ii),eleValCompareZero(ii));
        pirelab.getWireComp(topNet,eleValTemp(ii),eleVal(ii));
        pirelab.getSubComp(topNet,[eleVal(ii),oneconst],eleValminusonetemp(ii));
        pirelab.getSubComp(topNet,[eleValminusonetemp(ii),oneconst],eleValminusonetemp1(ii));
        pirelab.getRelOpComp(topNet,[sampCountProductDelay1(ii),N_long],modComp(ii),'<');
        pirelab.getSwitchComp(topNet,[eleValminusonetemp1(ii),eleValminusonetemp(ii)],eleValminusonetemp2(ii),modComp(ii));
        pirelab.getRelOpComp(topNet,[sampCountProductDelay1(ii),N_long],isNLong(ii),'==');
        pirelab.getSwitchComp(topNet,[eleValminusonetemp2(ii),N_longMinusOne],eleValminusone(ii),isNLong(ii));
        LUTInput(ii)=newDataSignal(topNet,uint16,['LUTInput_',num2str(ii)],rate);
        LUTOutput(ii)=newDataSignal(topNet,uint16,['LUTOutput_',num2str(ii)],rate);

        if strcmp(blockInfo.FECFrameType,'Normal')

            pirelab.getIntDelayComp(topNet,eleValSum_N(ii),eleValSum(ii),1,'',0,true);
        else
            pirelab.getIntDelayComp(topNet,eleValSum_S(ii),eleValSum(ii),1,'',0,true);
        end

        pirelab.getMulComp(topNet,[eleValSum(ii),dataValidInD5],eleValSumValid(ii));
        eleValSumValid32Bit(ii)=newDataSignal(topNet,uint32,['eleValSumValid32Bit_',num2str(ii)],rate);
        syntemp32Bit(ii)=newDataSignal(topNet,uint32,['syntemp32Bit_',num2str(ii)],rate);
        syntempDelay(ii)=newDataSignal(topNet,uint32,['syntempDelay_',num2str(ii)],rate);

        pirelab.getDTCComp(topNet,eleValSumValid(ii),eleValSumValid32Bit(ii));
        pirelab.getBitwiseOpComp(topNet,[eleValSumValid32Bit(ii),syntempDelay(ii)],syntemp32Bit(ii),'XOR');
        pirelab.getUnitDelayResettableComp(topNet,syntemp32Bit(ii),syntempDelay(ii),startInD5);

        pirelab.getDTCComp(topNet,syntemp32Bit(ii),syntemp(ii));
        syndrometempnotZero(ii)=newControlSignal(topNet,['syndrometempnotZero',num2str(ii)],rate);
        syndrometempOut(ii)=newDataSignal(topNet,uint16,['syndrometempOut_',num2str(ii)],rate);
        syndrometempOutminusone(ii)=newDataSignal(topNet,uint16,['syndrometempOutminusone_',num2str(ii)],rate);
        syndromeVal_14(ii)=newDataSignal(topNet,uint16,['syndromeVal_14_',num2str(ii)],rate);
        syndromeVal_16(ii)=newDataSignal(topNet,uint16,['syndromeVal_16_',num2str(ii)],rate);
        syndromeVal(ii)=newDataSignal(topNet,uint16,['syndromeVal_',num2str(ii)],rate);


        pirelab.getWireComp(topNet,syntemp(ii),syndrometemp(ii));

        pirelab.getCompareToValueComp(topNet,syndrometemp(ii),syndrometempnotZero(ii),'~=',0);
        pirelab.getSwitchComp(topNet,[zeroconst,syndrometemp(ii)],syndrometempOut(ii),syndrometempnotZero(ii));
        pirelab.getSubComp(topNet,[syndrometempOut(ii),oneconst],syndrometempOutminusone(ii));

    end

    endInD7=newControlSignal(topNet,'endInD7',rate);
    endInD5=newControlSignal(topNet,'endInD5',rate);
    pirelab.getIntDelayComp(topNet,endIn,endInD7,7,'',0,'');
    pirelab.getIntDelayComp(topNet,endIn,endInD5,5,'',0,'');

    gfTable2Count=newDataSignal(topNet,uint16,'gfTable2Count',rate);
    gfT2CountGreatZero=newControlSignal(topNet,'gfT2CountGreatZero',rate);
    gfT2CountRst=newControlSignal(topNet,'gfT2CountRst',rate);
    gfT2CountMax=newControlSignal(topNet,'gfT2CountMax',rate);
    pirelab.getCompareToValueComp(topNet,gfTable2Count,gfT2CountGreatZero,'>',0);
    pirelab.getCompareToValueComp(topNet,gfTable2Count,gfT2CountMax,'==',11);
    pirelab.getBitwiseOpComp(topNet,[gfT2CountMax,startInD5],gfT2CountRst,'OR');
    pirelab.getCounterComp(topNet,[gfT2CountRst,endInD5,oneconst,gfT2CountGreatZero],gfTable2Count,...
    'Count limited',...
    0.0,...
    1.0,...
    65535,...
    true,...
    true,...
    true,...
    false,...
    'gfTable2counter');
    gfTable2Inp=newDataSignal(topNet,uint16,'gfTable2Inp',rate);
    gfTable2Out=newDataSignal(topNet,uint16,'gfTable2Out',rate);
    gfTable2CountD1=newDataSignal(topNet,uint16,'gfTable2CountD1',rate);
    pirelab.getUnitDelayComp(topNet,gfTable2Count,gfTable2CountD1);
    gfTable2CountD2=newDataSignal(topNet,uint16,'gfTable2CountD2',rate);
    pirelab.getUnitDelayComp(topNet,gfTable2CountD1,gfTable2CountD2);
    gfTable2CountD3=newDataSignal(topNet,uint16,'gfTable2CountD3',rate);
    pirelab.getUnitDelayComp(topNet,gfTable2CountD2,gfTable2CountD3);
    gfTable2InpTemp=newDataSignal(topNet,uint16,'gfTable2InpTemp',rate);
    gfTable2InpTempisMax=newControlSignal(topNet,'gfTable2InpTempisMax',rate);
    pirelab.getMultiPortSwitchComp(topNet,[gfTable2CountD1,syndrometempOutminusone],gfTable2InpTemp,1,1,'floor','Wrap','syndromemux');
    pirelab.getCompareToValueComp(topNet,gfTable2InpTemp,gfTable2InpTempisMax,'==',2^16-1);
    gfTable2OutTemp=newDataSignal(topNet,uint16,'gfTable2OutTemp',rate);

    for ii=1:maxCorr
        syndromeFinal(ii)=newDataSignal(topNet,uint16,['syndromeFinal_',num2str(ii)],rate);
        syndrome(ii)=newDataSignal(topNet,uint16,['syndrome_',num2str(ii)],rate);
        syndrome32Bit(ii)=newDataSignal(topNet,uint32,['syndrome32Bit_',num2str(ii)],rate);
    end
    isgfTable2InpNotZero=newControlSignal(topNet,'isgfTable2InpNotZero',rate);
    isgfTable2InpNotZeroD1=newControlSignal(topNet,'isgfTable2InpNotZeroD1',rate);
    pirelab.getUnitDelayComp(topNet,isgfTable2InpNotZero,isgfTable2InpNotZeroD1);
    if strcmp(blockInfo.FECFrameType,'Normal')
        pirelab.getCompareToValueComp(topNet,gfTable2Inp,isgfTable2InpNotZero,'~=',2^16-1);


        pirelab.getSwitchComp(topNet,[gfTable2InpTemp,N_long],gfTable2Inp,gfTable2InpTempisMax);

        ramInputSigs=[zeroconst,zeroconst,falseconst,gfTable2Inp];
        pirelab.getSimpleDualPortRamComp(topNet,ramInputSigs,gfTable2OutTemp,'RamForLUTTable2',1,-1,[],'',gfTable2_16);
    else
        pirelab.getCompareToValueComp(topNet,gfTable2Inp,isgfTable2InpNotZero,'~=',2^14-1);


        pirelab.getSwitchComp(topNet,[gfTable2InpTemp,N_long],gfTable2Inp,gfTable2InpTempisMax);

        ramInputSigs=[zeroconst,zeroconst,falseconst,gfTable2Inp];
        pirelab.getSimpleDualPortRamComp(topNet,ramInputSigs,gfTable2OutTemp,'RamForLUTTable2',1,-1,[],'',gfTable2_14);
    end
    pirelab.getSwitchComp(topNet,[zeroconst,gfTable2OutTemp],gfTable2Out,isgfTable2InpNotZeroD1);
    gfTable2OutD2=newDataSignal(topNet,uint16,'gfTable2OutD2',rate);
    pirelab.getIntDelayComp(topNet,gfTable2Out,gfTable2OutD2,1,'',0,'');
    syndromeValTemp=newDataSignal(topNet,uint16,'syndromeValTemp',rate);
    syndromeTemp=newDataSignal(topNet,uint16,'syndromeTemp',rate);
    syndrometempisone=newControlSignal(topNet,'syndrometempone',rate);

    pirelab.getCompareToValueComp(topNet,gfTable2OutD2,syndrometempisone,'==',1);
    pirelab.getSwitchComp(topNet,[gfTable2OutD2,N_long],syndromeTemp,syndrometempisone);

    for ii=1:maxCorr/2
        constantComp(ii)=newControlSignal(topNet,['constantComp_',num2str(ii)],rate);
        pirelab.getCompareToValueComp(topNet,gfTable2CountD3,constantComp(ii),'==',ii-1);
        pirelab.getUnitDelayEnabledComp(topNet,syndromeTemp,syndromeFinal(2*ii-1),constantComp(ii));
        pirelab.getDTCComp(topNet,syndromeFinal(ii),syndrome32Bit(ii));
    end
    for ii=2:2:maxCorr
        if strcmp(blockInfo.FECFrameType,'Normal')
            pirelab.getBitShiftComp(topNet,syndrome32Bit(ii/2),syndrome32Bit(ii),'sll',1,0);

            syndromeSliced(ii)=newDataSignal(topNet,uint16,['syndromeSliced_',num2str(ii)],rate);
            pirelab.getBitSliceComp(topNet,syndrome32Bit(ii),syndromeSliced(ii),15,0);
            syndromeShifted(ii)=newDataSignal(topNet,uint32,['syndromeShifted_',num2str(ii)],rate);
            pirelab.getBitShiftComp(topNet,syndrome32Bit(ii),syndromeShifted(ii),'srl',16,0);
            syndromeReduced(ii)=newDataSignal(topNet,uint16,['syndromeReduced_',num2str(ii)],rate);
            pirelab.getBitSliceComp(topNet,syndromeShifted(ii),syndromeReduced(ii),15,0);
            syndromeRem(ii)=newDataSignal(topNet,uint16,['syndromeRem_',num2str(ii)],rate);
            syndromeRem1(ii)=newDataSignal(topNet,uint16,['syndromeRem1_',num2str(ii)],rate);
            pirelab.getAddComp(topNet,[syndromeSliced(ii),syndromeReduced(ii)],syndromeRem(ii),'Floor','Wrap');
            syndromeRemCompare(ii)=newControlSignal(topNet,['syndromeRemCompare_',num2str(ii)],rate);
            pirelab.getCompareToValueComp(topNet,syndromeRem(ii),syndromeRemCompare(ii),'>',65535);
            pirelab.getSubComp(topNet,[syndromeRem(ii),N_long],syndromeRem1(ii),'Floor','Wrap');
            pirelab.getSwitchComp(topNet,[syndromeRem(ii),syndromeRem1(ii)],syndromeFinal(ii),syndromeRemCompare(ii),'Synmodmux');
        else
            pirelab.getBitShiftComp(topNet,syndrome32Bit(ii/2),syndrome32Bit(ii),'sll',1,0);

            syndromeSliced(ii)=newDataSignal(topNet,pir_fixpt_t(0,14,0),['syndromeSliced_',num2str(ii)],rate);
            pirelab.getBitSliceComp(topNet,syndrome32Bit(ii),syndromeSliced(ii),13,0);
            syndromeShifted(ii)=newDataSignal(topNet,uint32,['syndromeShifted_',num2str(ii)],rate);
            pirelab.getBitShiftComp(topNet,syndrome32Bit(ii),syndromeShifted(ii),'srl',14,0);
            syndromeReduced(ii)=newDataSignal(topNet,pir_fixpt_t(0,14,0),['syndromeReduced_',num2str(ii)],rate);
            pirelab.getBitSliceComp(topNet,syndromeShifted(ii),syndromeReduced(ii),13,0);
            syndromeRem(ii)=newDataSignal(topNet,uint16,['syndromeRem_',num2str(ii)],rate);
            syndromeRem1(ii)=newDataSignal(topNet,uint16,['syndromeRem1_',num2str(ii)],rate);
            pirelab.getAddComp(topNet,[syndromeSliced(ii),syndromeReduced(ii)],syndromeRem(ii),'Floor','Wrap');
            syndromeRemCompare(ii)=newControlSignal(topNet,['syndromeRemCompare_',num2str(ii)],rate);
            pirelab.getCompareToValueComp(topNet,syndromeRem(ii),syndromeRemCompare(ii),'>',2^14-1);
            pirelab.getSubComp(topNet,[syndromeRem(ii),N_long],syndromeRem1(ii),'Floor','Wrap');
            pirelab.getSwitchComp(topNet,[syndromeRem(ii),syndromeRem1(ii)],syndromeFinal(ii),syndromeRemCompare(ii),'Synmodmux');
        end

    end

    for ii=1:24
        indConst(ii)=newDataSignal(topNet,pir_ufixpt_t(8,0),['indConst',num2str(ii)],rate);
        pirelab.getConstComp(topNet,indConst(ii),ii);
        synEnb(ii)=newControlSignal(topNet,['synEnb',num2str(ii)],rate);
        pirelab.getRelOpComp(topNet,[indConst(ii),doubleCorr],synEnb(ii),'<=');
        pirelab.getSwitchComp(topNet,[zeroconst,syndromeFinal(ii)],syndrome(ii),synEnb(ii));
    end




    ramdepth=2^16-1;
    ii=1;


    ramrddata=newControlSignal(topNet,['ramrddata_'],rate);
    ramrddataDelay=newControlSignal(topNet,['ramrddataDelay_'],rate);
    ramrddata_1=newControlSignal(topNet,['ramrddata_1_'],rate);
    ramrddata_2=newControlSignal(topNet,['ramrddata_2_'],rate);
    ramwraddr=newDataSignal(topNet,uint16,['ramwraddr_'],rate);
    ramrdaddr=newDataSignal(topNet,uint16,['ramrdaddr_'],rate);

    wrAddrCount=newDataSignal(topNet,uint16,'wrAddCount',rate);
    ramwren_1=newControlSignal(topNet,'ramwren_1',rate);
    ramwren_2=newControlSignal(topNet,'ramwren_2',rate);

    ramwrbanken_1_delay=newControlSignal(topNet,'ramwrbanken_1_delay',rate);
    ramwrbanken_1=newControlSignal(topNet,'ramwrbanken_1',rate);
    ramwrbanken_2=newControlSignal(topNet,'ramwrbanken_2',rate);

    ramrdbanken_delay=newControlSignal(topNet,'ramrdbanken_1_delay',rate);
    ramrdbanken=newControlSignal(topNet,'ramrdbanken_1',rate);

    ramwrcount=newDataSignal(topNet,uint16,'ramwrcount',rate);
    ramrdcount=newDataSignal(topNet,uint16,'ramrdcount',rate);
    ramwrbank=newDataSignal(topNet,uint16,'ramwrbank',rate);
    ramrdbank=newDataSignal(topNet,uint16,'ramrdbank',rate);

    ramwrbanken=newControlSignal(topNet,'ramwrbanken',rate);

    pirelab.getCounterComp(topNet,[startInDelay,validInDelay],wrAddrCount,...
    'Count limited',...
    0.0,...
    vecLen,...
    65535,...
    true,...
    false,...
    true,...
    false,...
    'writeAddrCounter');

    dataInDelay1=newControlSignal(topNet,'dataInDelay1',rate);
    ramwraddrDelay=newDataSignal(topNet,uint16,'ramwraddrDelay',rate);
    ramwren_1_delay=newControlSignal(topNet,'ramwren_1_delay',rate);
    ramwren_2_delay=newControlSignal(topNet,'ramwren_2_delay',rate);
    ramrddata_1_delay=newControlSignal(topNet,'ramrddata_1_delay',rate);
    ramrddata_2_delay=newControlSignal(topNet,'ramrddata_2_delay',rate);

    pirelab.getUnitDelayComp(topNet,dataInDelay,dataInDelay1);
    pirelab.getUnitDelayComp(topNet,ramwraddr,ramwraddrDelay);
    pirelab.getUnitDelayComp(topNet,ramwren_1,ramwren_1_delay);
    pirelab.getUnitDelayComp(topNet,ramwren_2,ramwren_2_delay);
    pirelab.getUnitDelayComp(topNet,ramrddata_1,ramrddata_1_delay);
    pirelab.getUnitDelayComp(topNet,ramrddata_2,ramrddata_2_delay);
    pirelab.getUnitDelayComp(topNet,ramrddata,ramrddataDelay);


    vecConst=newDataSignal(topNet,uint16,['vecConst_'],rate);
    pirelab.getConstComp(topNet,vecConst(ii),0);
    pirelab.getAddComp(topNet,[wrAddrCount,vecConst],ramwraddr);
    ram_insigs=[dataInDelay1,ramwraddr,ramwren_1_delay,ramrdaddr];
    pirelab.getSimpleDualPortRamComp(topNet,ram_insigs,ramrddata_1,'BCHDataRAM');






    pirelab.getAddComp(topNet,[wrAddrCount,vecConst],ramwraddr);
    ram_insigs=[dataInDelay1,ramwraddr,ramwren_2_delay,ramrdaddr];
    pirelab.getSimpleDualPortRamComp(topNet,ram_insigs,ramrddata_2,'BCHDataRAM');


    pirelab.getBitwiseOpComp(topNet,[startInDelay,ramwrbanken_1_delay],ramwrbanken_1,'XOR');
    pirelab.getUnitDelayComp(topNet,ramwrbanken_1,ramwrbanken_1_delay);
    pirelab.getBitwiseOpComp(topNet,ramwrbanken_1,ramwrbanken_2,'NOT');
    pirelab.getBitwiseOpComp(topNet,[ramwrbanken_1,validInDelay],ramwren_1,'AND');
    pirelab.getBitwiseOpComp(topNet,[ramwrbanken_2,validInDelay],ramwren_2,'AND');


    startInDelay2=newControlSignal(topNet,'startInDelay2',rate);
    pirelab.getUnitDelayComp(topNet,startInDelay,startInDelay2);
    pirelab.getBitwiseOpComp(topNet,[startInDelay2,ramrdbanken_delay],ramrdbanken,'XOR');
    pirelab.getUnitDelayComp(topNet,ramrdbanken,ramrdbanken_delay);

    pirelab.getSwitchComp(topNet,[ramrddata_2,ramrddata_1],ramrddata,ramrdbanken);

    gfT2CountRstD5=newControlSignal(topNet,'gfT2CountRstD5',rate);
    pirelab.getIntDelayComp(topNet,gfT2CountMax,gfT2CountRstD5,5);

    LStar=newDataSignal(topNet,pir_sfixpt_t(8,0),'LStar',rate);
    errlocpolylen=newDataSignal(topNet,pir_ufixpt_t(8,0),'errlocpolylen',rate);
    fsmdone=newControlSignal(topNet,'fsmdone',rate);
    for ii=1:maxCorr
        errlocpoly(ii)=newDataSignal(topNet,uint16,sprintf('errloc%dpoly',ii),rate);%#ok
    end

    masseyNet=this.elabMassey(topNet,blockInfo,rate);
    masseyNet.addComment('Berklekamp-Massey State-machine');

    for ii=1:maxCorr
        inports(ii)=syndrome(ii);
        outports(ii)=errlocpoly(ii);
    end
    inports(ii+1)=gfT2CountRstD5;
    inports(ii+2)=doubleCorr;

    outports(ii+1)=fsmdone;
    outports(ii+2)=errlocpolylen;
    outports(ii+3)=LStar;

    pirelab.instantiateNetwork(topNet,masseyNet,inports,outports,'masseyNet_inst');




    N_chien=newDataSignal(topNet,uint16,'N_chien',rate);
    K_chien=newDataSignal(topNet,uint16,'K_chien',rate);

    pirelab.getUnitDelayEnabledComp(topNet,N,N_chien,gfT2CountRstD5);
    pirelab.getUnitDelayEnabledComp(topNet,K,K_chien,gfT2CountRstD5);






    chienCountEnb=newControlSignal(topNet,'chienCountEnb',rate);
    chienCountVal=newDataSignal(topNet,uint16,'chienCountVal',rate);
    chienXORVal=newDataSignal(topNet,uint16,'chienXORVal',rate);
    chienCountRst=newControlSignal(topNet,'chienCountRst',rate);
    chienCountRstTemp=newControlSignal(topNet,'chienCountRstTemp',rate);
    chienCountRstTemp1=newControlSignal(topNet,'chienCountRstTemp1',rate);
    pirelab.getCounterComp(topNet,[chienCountRst,fsmdone,oneconst,chienCountEnb],chienCountVal,...
    'Count limited',...
    0.0,...
    1.0,...
    65535,...
    true,...
    true,...
    true,...
    false,...
    'chiencounter');
    pirelab.getCompareToValueComp(topNet,chienCountVal,chienCountEnb,'>',0,'');
    pirelab.getRelOpComp(topNet,[chienCountVal,N_chien],chienCountRstTemp,'==');
    pirelab.getBitwiseOpComp(topNet,[chienCountRstTemp,chienCountEnb],chienCountRstTemp1,'AND');
    pirelab.getBitwiseOpComp(topNet,[chienCountRstTemp1,startIn],chienCountRst,'OR');
    chienErrCheckCountVal=newDataSignal(topNet,uint16,'chienErrCheckCountVal',rate);
    chienErrCheckCountValD1=newDataSignal(topNet,uint16,'chienErrCheckCountValD1',rate);
    pirelab.getUnitDelayComp(topNet,chienErrCheckCountVal,chienErrCheckCountValD1);
    dataInd=newDataSignal(topNet,uint16,'dataInd',rate);
    errPos=newDataSignal(topNet,uint16,'errPos',rate);
    chienCountEnbD2=newControlSignal(topNet,'chienCountEnbD2',rate);
    pirelab.getIntDelayComp(topNet,chienCountEnb,chienCountEnbD2,2,'',0,'');
    fsmdoneD1=newControlSignal(topNet,'fsmDoneD1',rate);
    pirelab.getUnitDelayComp(topNet,fsmdone,fsmdoneD1);
    messageValid=newControlSignal(topNet,'messageValid',rate);
    NlongMinusNPlus1=newDataSignal(topNet,uint16,'NlongMinusNPlus1',rate);
    NlongMinusN=newDataSignal(topNet,uint16,'NlongMinusN',rate);
    pirelab.getSubComp(topNet,[N_long,N_chien],NlongMinusN);
    pirelab.getAddComp(topNet,[NlongMinusN,oneconst],NlongMinusNPlus1);

    pirelab.getCounterComp(topNet,[chienCountRst,fsmdone,NlongMinusNPlus1,chienCountEnb],chienErrCheckCountVal,...
    'Count limited',...
    0,...
    1,...
    65535,...
    true,...
    true,...
    true,...
    false,...
    'chienDownCounter');

    chienEnb=newControlSignal(topNet,'chienEnb',rate);
    chienEnbTemp=newControlSignal(topNet,'chienEnbTemp',rate);
    chienEnbTemp1=newControlSignal(topNet,'chienEnbTemp1',rate);
    chienOrStartSig=newControlSignal(topNet,'chienOrStartSig',rate);
    pirelab.getBitwiseOpComp(topNet,[fsmdone,startInput],chienOrStartSig,'OR');
    pirelab.getUnitDelayEnabledComp(topNet,fsmdone,chienEnbTemp,chienOrStartSig);
    pirelab.getSwitchComp(topNet,[chienEnbTemp,fsmdone],chienEnbTemp1,fsmdone);
    pirelab.getBitwiseOpComp(topNet,[chienEnbTemp1,chienCountEnb],chienEnb,'AND');
    chienEnbD3=newControlSignal(topNet,'chienEnbD3',rate);
    pirelab.getIntDelayComp(topNet,chienEnb,chienEnbD3,3);
    chienEnbD4=newControlSignal(topNet,'chienEnbD4',rate);
    pirelab.getUnitDelayComp(topNet,chienEnbD3,chienEnbD4);
    for ii=1:13
        chienTemp(ii)=newDataSignal(topNet,uint32,['chienTemp_',num2str(ii)],rate);
        chienTempMod(ii)=newDataSignal(topNet,uint16,['chienTempMod_',num2str(ii)],rate);
        chienMod(ii)=newDataSignal(topNet,uint16,['chienMod_',num2str(ii)],rate);
        chienTempGreatN(ii)=newControlSignal(topNet,['chienTempGreatN_',num2str(ii)],rate);
        chienTempModTemp(ii)=newDataSignal(topNet,uint16,['chienTempModTemp_',num2str(ii)],rate);
        chienTempGFVal(ii)=newDataSignal(topNet,uint16,['chienTempGFVal_',num2str(ii)],rate);
        iiConstant(ii)=newDataSignal(topNet,pir_ufixpt_t(8,0),['iiConstant_',num2str(ii)],rate);
        constMulOp(ii)=newDataSignal(topNet,uint32,['constMulOp_',num2str(ii)],rate);
        constMulOpD2(ii)=newDataSignal(topNet,uint32,['constMulOpD2_',num2str(ii)],rate);
        errlocpolyD2(ii)=newDataSignal(topNet,uint16,['errlocpolyD2_',num2str(ii)],rate);
        pirelab.getIntDelayComp(topNet,constMulOp(ii),constMulOpD2(ii),2);
        pirelab.getIntDelayComp(topNet,errlocpoly(ii),errlocpolyD2(ii),2);
        chienTempModMinus1(ii)=newDataSignal(topNet,uint16,['chienTempModMinus1_',num2str(ii)],rate);
        pirelab.getConstComp(topNet,iiConstant(ii),ii-1);
        pirelab.getMulComp(topNet,[iiConstant(ii),chienErrCheckCountValD1],constMulOp(ii));
        pirelab.getAddComp(topNet,[errlocpolyD2(ii),constMulOpD2(ii)],chienTemp(ii));


        chienTempModNet(ii)=this.elabModulo(topNet,blockInfo,chienTemp(ii),chienTempModTemp(ii),rate);
        chienTempModNet(ii).addComment(['chienTempMod',num2str(ii)]);
        pirelab.instantiateNetwork(topNet,chienTempModNet(ii),chienTemp(ii),chienTempModTemp(ii),['chienTempMod',num2str(ii)]);

        chienTempModisZero(ii)=newControlSignal(topNet,['chienModTempisZero_',num2str(ii)],rate);
        pirelab.getCompareToValueComp(topNet,chienTempModTemp(ii),chienTempModisZero(ii),'==',0);
        pirelab.getSwitchComp(topNet,[chienTempModTemp(ii),N_long],chienMod(ii),chienTempModisZero(ii));


        pirelab.getSubComp(topNet,[chienMod(ii),oneconst],chienTempModMinus1(ii));
        chienTempGFValTemp=newDataSignal(topNet,uint16,'chienTempGFValTemp',rate);
        if ii==13
            if strcmp(blockInfo.FECFrameType,'Normal')
                ramInputSigs=[zeroconst,zeroconst,falseconst,chienTempModMinus1(ii)];
                pirelab.getSimpleDualPortRamComp(topNet,ramInputSigs,chienTempGFVal(ii),['RamForLUT',num2str(ii)],1,-1,[],'',gfTable1_16,blockInfo.ramAttr_block);
            else
                ramInputSigs=[zeroconst,zeroconst,falseconst,chienTempModMinus1(ii)];
                pirelab.getSimpleDualPortRamComp(topNet,ramInputSigs,chienTempGFVal(ii),['RamForLUT',num2str(ii)],1,-1,[],'',gfTable1_14,blockInfo.ramAttr_block);
            end
        else
            pirelab.getSwitchComp(topNet,[eleValminusonetemp(ii),chienTempModMinus1(ii)],LUTInput(ii),chienEnbD3);
            if strcmp(blockInfo.FECFrameType,'Normal')
                ramInputSigs=[zeroconst,zeroconst,falseconst,LUTInput(ii)];
                pirelab.getSimpleDualPortRamComp(topNet,ramInputSigs,LUTOutput(ii),['RamForLUT',num2str(ii)],1,-1,[],'',gfTable1_16,blockInfo.ramAttr_block);
                pirelab.getSwitchComp(topNet,[LUTOutput(ii),zeroconst],eleValSum_N(ii),chienEnbD4);
                pirelab.getSwitchComp(topNet,[zeroconst,LUTOutput(ii)],chienTempGFVal(ii),chienEnbD4);
            else
                ramInputSigs=[zeroconst,zeroconst,falseconst,LUTInput(ii)];
                pirelab.getSimpleDualPortRamComp(topNet,ramInputSigs,LUTOutput(ii),['RamForLUT',num2str(ii)],1,-1,[],'',gfTable1_14,blockInfo.ramAttr_block);
                pirelab.getSwitchComp(topNet,[LUTOutput(ii),zeroconst],eleValSum_S(ii),chienEnbD4);
                pirelab.getSwitchComp(topNet,[zeroconst,LUTOutput(ii)],chienTempGFVal(ii),chienEnbD4);
            end
        end
        chienGF(ii)=newDataSignal(topNet,uint16,['chienGF_',num2str(ii)],rate);
        isLamdaZero(ii)=newControlSignal(topNet,['isLamdaZero',num2str(ii)],rate);
        isLamdaZeroD1(ii)=newControlSignal(topNet,['isLamdaZeroD1',num2str(ii)],rate);
        isLamdaZeroD4(ii)=newControlSignal(topNet,['isLamdaZeroD4',num2str(ii)],rate);
        pirelab.getCompareToValueComp(topNet,errlocpolyD2(ii),isLamdaZero(ii),'==',0);
        pirelab.getUnitDelayComp(topNet,isLamdaZero(ii),isLamdaZeroD1(ii));
        pirelab.getIntDelayComp(topNet,isLamdaZero(ii),isLamdaZeroD4(ii),4);
        pirelab.getSwitchComp(topNet,[chienTempGFVal(ii),zeroconst],chienGF(ii),isLamdaZeroD4(ii));
    end

    pirelab.getBitwiseOpComp(topNet,chienGF,chienXORVal,'XOR');
    chienXORValisZero=newControlSignal(topNet,'chienXORValisZero',rate);
    pirelab.getCompareToValueComp(topNet,chienXORVal,chienXORValisZero,'==',0);





    dataCorrected=newControlSignal(topNet,'dataCorrected',rate);
    dataNegated=newControlSignal(topNet,'dataNegated',rate);
    pirelab.getBitwiseOpComp(topNet,ramrddataDelay,dataNegated,'NOT');
    pirelab.getSwitchComp(topNet,[ramrddataDelay,dataNegated],dataCorrected,chienXORValisZero);
    chienCountValD1=newDataSignal(topNet,uint16,'chienCountValD1',rate);
    pirelab.getUnitDelayComp(topNet,chienCountVal,chienCountValD1);
    chienCountValD4=newDataSignal(topNet,uint16,'chienCountValD4',rate);
    pirelab.getIntDelayComp(topNet,chienCountVal,chienCountValD4,4);
    chienCountValD3=newDataSignal(topNet,uint16,'chienCountValD3',rate);
    pirelab.getIntDelayComp(topNet,chienCountVal,chienCountValD3,3);
    pirelab.getRelOpComp(topNet,[chienCountValD4,K_chien],messageValid,'<=');


    endOutTemp=newControlSignal(topNet,'endOutTemp',rate);
    startOutTemp=newControlSignal(topNet,'startOutTemp',rate);
    dataOutTemp=newControlSignal(topNet,'dataOutTemp',rate);
    dataOutTemp1=newControlSignal(topNet,'dataOutTemp1',rate);
    validOutTemp=newControlSignal(topNet,'validOutTemp',rate);
    validOutTemp1=newControlSignal(topNet,'validOutTemp1',rate);
    zeroBoolean=newControlSignal(topNet,'zeroBoolean',rate);
    pirelab.getConstComp(topNet,zeroBoolean,0);

    pirelab.getIntDelayComp(topNet,endOutTemp,endOut,24*bitLength);
    pirelab.getIntDelayComp(topNet,startOutTemp,startOut,24*bitLength);
    pirelab.getIntDelayComp(topNet,dataOutTemp,dataOutTemp1,24*bitLength);
    pirelab.getSwitchComp(topNet,[zeroBoolean,dataOutTemp1],dataOut,validOut);
    pirelab.getIntDelayComp(topNet,validOutTemp,validOutTemp1,24*bitLength);

    chienCountEnb1=newControlSignal(topNet,'chienCountEnb1',rate);
    pirelab.getBitwiseOpComp(topNet,[chienCountEnb1,validOutTemp1],validOut,'AND');
    rstCountRst=newControlSignal(topNet,'rstCountRst',rate);
    rstCountMax=newControlSignal(topNet,'rstCountMax',rate);
    rstCountEnb=newControlSignal(topNet,'rstCountEnb',rate);
    rstCount=newDataSignal(topNet,uint16,'rstCount',rate);
    pirelab.getBitwiseOpComp(topNet,[chienCountEnb,rstCountEnb],chienCountEnb1,'OR');

    pirelab.getCounterComp(topNet,[rstCountRst,chienCountRstTemp1,oneconst,rstCountEnb],rstCount,...
    'Count limited',...
    0,...
    1,...
    24*bitLength+1,...
    true,...
    true,...
    true,...
    false,...
    'chienDownCounter');

    rstDelayCount=newDataSignal(topNet,uint16,'rstDelayCount',rate);
    pirelab.getConstComp(topNet,rstDelayCount,24*bitLength);
    rstCountLimit=newDataSignal(topNet,uint16,'rstCountLimit',rate);
    pirelab.getSubComp(topNet,[rstDelayCount,doubleCorr],rstCountLimit);
    pirelab.getRelOpComp(topNet,[rstCount,rstCountLimit],rstCountMax,'==');
    pirelab.getBitwiseOpComp(topNet,[rstCountMax,startIn],rstCountRst,'OR');
    pirelab.getCompareToValueComp(topNet,rstCount,rstCountEnb,'>',0);

    pirelab.getWireComp(topNet,chienCountValD3,ramrdaddr);
    pirelab.getSwitchComp(topNet,[falseconst,dataCorrected],dataOutTemp,validOutTemp);

    chienCountEnbD1=newControlSignal(topNet,'chienCountEnbD1',rate);
    pirelab.getUnitDelayComp(topNet,chienCountEnb,chienCountEnbD1);
    chienCountEnbD4=newControlSignal(topNet,'chienCountEnbD4',rate);
    pirelab.getIntDelayComp(topNet,chienCountEnb,chienCountEnbD4,4);
    pirelab.getBitwiseOpComp(topNet,[chienCountEnbD4,messageValid],validOutTemp,'AND');
    outMsgEnd=newControlSignal(topNet,'outMsgEnd',rate);
    pirelab.getRelOpComp(topNet,[chienCountValD4,K_chien],outMsgEnd,'==');
    pirelab.getBitwiseOpComp(topNet,[outMsgEnd,chienCountEnbD4],endOutTemp,'AND');

    fsmdoneD2=newControlSignal(topNet,'fsmdoneD2',rate);
    pirelab.getUnitDelayComp(topNet,fsmdoneD1,fsmdoneD2);
    fsmdoneD5=newControlSignal(topNet,'fsmdoneD5',rate);
    pirelab.getIntDelayComp(topNet,fsmdoneD2,fsmdoneD5,3);
    pirelab.getWireComp(topNet,fsmdoneD5,startOutTemp);

    if blockInfo.NumErrorsOutputPort
        chienXORValisZeroD1=newControlSignal(topNet,'chienXORValisZeroD1',rate);
        pirelab.getIntDelayComp(topNet,chienXORValisZero,chienXORValisZeroD1,1);
        errCountEnb=newControlSignal(topNet,'errCountEnb',rate);
        pirelab.getBitwiseOpComp(topNet,[chienXORValisZero,chienCountEnbD4],errCountEnb,'AND');
        zeroErrorConst=newDataSignal(topNet,sFix5Type,'zeroErrorConst',rate);
        cnumErr=newDataSignal(topNet,sFix5Type,'cnumErr',rate);
        cnumErrTemp=newDataSignal(topNet,sFix5Type,'cnumErrTemp',rate);
        pirelab.getCounterComp(topNet,[startIn,errCountEnb],cnumErr,...
        'Count limited',...
        0,...
        1,...
        12,...
        true,...
        false,...
        true,...
        false,...
        'chienDownCounter');
        pirelab.getConstComp(topNet,zeroErrorConst,0);
        finalErrOut=newDataSignal(topNet,sFix5Type,'finalErrOut',rate);
        errCheckCap=newControlSignal(topNet,'errCheckCap',rate);

        LStarMinusOne=newDataSignal(topNet,pir_sfixpt_t(8,0),'LStarMinusOne',rate);
        oneBoolean=newControlSignal(topNet,'oneBoolean',rate);
        pirelab.getConstComp(topNet,oneBoolean,1);
        pirelab.getSubComp(topNet,[LStar,oneBoolean],LStarMinusOne);
        pirelab.getRelOpComp(topNet,[LStar,cnumErr],errCheckCap,'~=');
        negOneConst=newDataSignal(topNet,sFix5Type,'negOneConst',rate);
        pirelab.getConstComp(topNet,negOneConst,-1);

        pirelab.getSwitchComp(topNet,[cnumErr,negOneConst],cnumErrTemp,errCheckCap);
        pirelab.getSwitchComp(topNet,[zeroErrorConst,cnumErrTemp],finalErrOut,endOut);
        pirelab.getWireComp(topNet,finalErrOut,numErrOut);
    end

end

function signal=newControlSignal(topNet,name,rate)
    controlType=pir_ufixpt_t(1,0);
    signal=topNet.addSignal(controlType,name);
    signal.SimulinkRate=rate;
end

function signal=newDataSignal(topNet,inType,name,rate)
    signal=topNet.addSignal(inType,name);
    signal.SimulinkRate=rate;
end
