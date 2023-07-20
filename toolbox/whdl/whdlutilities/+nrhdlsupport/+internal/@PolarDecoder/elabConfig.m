function configNet=elabConfig(this,topNet,blockInfo,dataRate)

    nMax=blockInfo.nMax;
    downlinkMode=blockInfo.downlinkMode;
    boolType=pir_boolean_t();
    stageType=blockInfo.stageType;
    nType=blockInfo.nType;
    NType=blockInfo.NType;
    KType=blockInfo.KType;
    KInType=blockInfo.KInType;
    EType=blockInfo.EType;
    qPCType=blockInfo.qPCType;

    if blockInfo.configFromPort
        inportNames={'leafIdx','K','E','configure'};
        inTypes=[NType,KInType,EType,boolType];

        PLut=blockInfo.PLut;
        seqLut=blockInfo.seqLut;
        seqAddrType=blockInfo.seqAddrType;

        if downlinkMode
            inportNames(end+1)={'itlvPathRdAddr'};
            inTypes=[inTypes,KType];
            itlvPattern=blockInfo.itlvPattern;
        end
    else
        inportNames={'leafIdx'};
        inTypes=NType;

        messageLength=blockInfo.messageLength;
        rate=blockInfo.rate;
        n=blockInfo.n;
        NInt=blockInfo.N;
        FLut=blockInfo.FLut;
        parityEnProp=blockInfo.parityEnProp;
        qPCProp=blockInfo.qPCProp;

        if downlinkMode
            inportNames(end+1)={'itlvPathRdAddr'};
            inTypes=[inTypes,KType];
            itlvLut=blockInfo.itlvLut;
        end
    end

    indataRates=dataRate*ones(1,length(inportNames));

    outportNames={'KLatch','nSUb1','NSub1','F','configured','configValid'};
    outTypes=[KType,stageType,NType,boolType,boolType,boolType];

    if downlinkMode
        outportNames(end+1:end+2)={'ELatch','deitlvPathRdAddr'};
        outTypes=[outTypes,EType,KType];
    else
        outportNames(end+1:end+2)={'isParity','parityEn'};
        outTypes=[outTypes,boolType,boolType];
    end

    configNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','Configuration',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );

    leafIdx=configNet.PirInputSignals(1);

    if blockInfo.configFromPort
        K=configNet.PirInputSignals(2);
        E=configNet.PirInputSignals(3);
        configure=configNet.PirInputSignals(4);
    end

    KLatch=configNet.PirOutputSignals(1);
    nSub1=configNet.PirOutputSignals(2);
    NSub1=configNet.PirOutputSignals(3);
    F=configNet.PirOutputSignals(4);
    configured=configNet.PirOutputSignals(5);
    configValid=configNet.PirOutputSignals(6);

    if downlinkMode
        itlvPathRdAddr=configNet.PirInputSignals(end);

        ELatch=configNet.PirOutputSignals(7);
        deitlvPathRdAddr=configNet.PirOutputSignals(8);
    else
        isParity=configNet.PirOutputSignals(7);
        parityEn=configNet.PirOutputSignals(8);
    end

    if blockInfo.configFromPort

        KLatchInt=configNet.addSignal(KInType,'KLatchDTC');
        ELatchInt=configNet.addSignal(EType,'ELatchInt');
        pirelab.getUnitDelayEnabledComp(configNet,K,KLatchInt,configure,'Kreg','','',false,'',-1,true);
        pirelab.getUnitDelayEnabledComp(configNet,E,ELatchInt,configure,'Ereg','','',false,'',-1,true);

        KLatchDTC=configNet.addSignal(KType,'KLatchDTC');

        if downlinkMode
            pirelab.getDTCComp(configNet,KLatchInt,KLatchDTC);
        else
            pirelab.getWireComp(configNet,KLatchInt,KLatchDTC);
        end

        KLatchInt_reg=configNet.addSignal(KType,'KLatchInt_reg');
        ELatchInt_reg=configNet.addSignal(EType,'ELatchInt_reg');
        pirelab.getUnitDelayComp(configNet,KLatchDTC,KLatchInt_reg);
        pirelab.getUnitDelayComp(configNet,ELatchInt,ELatchInt_reg);

        KChange=configNet.addSignal(boolType,'KChange');
        EChange=configNet.addSignal(boolType,'EChange');
        pirelab.getRelOpComp(configNet,[KLatchDTC,KLatchInt_reg],KChange,'~=');
        pirelab.getRelOpComp(configNet,[ELatchInt,ELatchInt_reg],EChange,'~=');

        reconfig=configNet.addSignal(boolType,'reconfig');
        pirelab.getLogicComp(configNet,[KChange,EChange],reconfig,'or');


        KGTLim=configNet.addSignal(boolType,'KGTLim');
        KValid=configNet.addSignal(boolType,'KValid');

        if downlinkMode
            pirelab.getCompareToValueComp(configNet,KLatchInt,KGTLim,'>=',36);

            KLTLim=configNet.addSignal(boolType,'KLTLim');
            pirelab.getCompareToValueComp(configNet,KLatchInt,KLTLim,'<=',164);


            pirelab.getLogicComp(configNet,[KLTLim,KGTLim],KValid,'and');
        else
            KGtPCLim=configNet.addSignal(boolType,'KGtPCLim');
            KLtPCLim=configNet.addSignal(boolType,'KLtPCLim');

            pirelab.getCompareToValueComp(configNet,KLatchInt,KGtPCLim,'>=',18);
            pirelab.getCompareToValueComp(configNet,KLatchInt,KLtPCLim,'<=',25);

            parityEnInt=configNet.addSignal(boolType,'parityEnInt');
            pirelab.getLogicComp(configNet,[KGtPCLim,KLtPCLim],parityEnInt,'and');

            ESubK=configNet.addSignal(EType,'ESubK');
            pirelab.getSubComp(configNet,[ELatchInt,KLatchInt],ESubK);

            nwmCheck=configNet.addSignal(boolType,'nwmCheck');
            pirelab.getCompareToValueComp(configNet,ESubK,nwmCheck,'>',189);

            nwm=configNet.addSignal(boolType,'nwm');
            pirelab.getLogicComp(configNet,[nwmCheck,parityEnInt],nwm,'and');

            pirelab.getCompareToValueComp(configNet,KLatchInt,KGTLim,'>=',31);
            pirelab.getLogicComp(configNet,[KGTLim,parityEnInt],KValid,'or');
        end

        ELTEqLim=configNet.addSignal(boolType,'ELTEqLim');
        pirelab.getCompareToValueComp(configNet,ELatchInt,ELTEqLim,'<=',8192);

        EGTK=configNet.addSignal(boolType,'EGTK');
        pirelab.getRelOpComp(configNet,[ELatchInt,KLatchInt],EGTK,'>');

        configValidInt=configNet.addSignal(boolType,'configValidInt');
        pirelab.getLogicComp(configNet,[KValid,EGTK,ELTEqLim],configValidInt,'and');

        pirelab.getUnitDelayComp(configNet,configValidInt,configValid);



        reconfig_reg=configNet.addSignal(boolType,'reconfig_reg');
        pirelab.getIntDelayComp(configNet,reconfig,reconfig_reg,2);


        n2=configNet.addSignal(nType,'n2');
        cl2E=configNet.addSignal(nType,'cl2E');

        desc='ceilLog2K - compute ceil(log2(K))';

        fid=fopen(fullfile(blockInfo.emlPath,'ceilLog2K.m'),'r');
        fcnBody=fread(fid,Inf,'char=>char');
        fclose(fid);

        inports=KLatchDTC;
        outports=n2;

        ceilLog2K=configNet.addComponent2(...
        'kind','cgireml',...
        'Name','ceilLog2K',...
        'InputSignals',inports,...
        'OutputSignals',outports,...
        'EMLFileName','ceilLog2K',...
        'EMLFileBody',fcnBody,...
        'EMLParams',{nMax},...
        'EMLFlag_TreatInputIntsAsFixpt',true,...
        'EMLFlag_SaturateOnIntOverflow',false,...
        'EMLFlag_TreatInputBoolsAsUfix1',false,...
        'BlockComment',desc...
        );
        ceilLog2K.runConcurrencyMaximizer(0);

        desc='ceilLog2E - compute ceil(log2(E))';

        fid=fopen(fullfile(blockInfo.emlPath,'ceilLog2E.m'),'r');
        fcnBody=fread(fid,Inf,'char=>char');
        fclose(fid);

        inports=ELatchInt;
        outports=cl2E;

        ceilLog2E=configNet.addComponent2(...
        'kind','cgireml',...
        'Name','ceilLog2E',...
        'InputSignals',inports,...
        'OutputSignals',outports,...
        'EMLFileName','ceilLog2E',...
        'EMLFileBody',fcnBody,...
        'EMLParams',{nMax},...
        'EMLFlag_TreatInputIntsAsFixpt',true,...
        'EMLFlag_SaturateOnIntOverflow',false,...
        'EMLFlag_TreatInputBoolsAsUfix1',false,...
        'BlockComment',desc...
        );
        ceilLog2E.runConcurrencyMaximizer(0);

        cl2ESub1=configNet.addSignal(nType,'cl2ESub1');
        pirelab.getDecrementRWV(configNet,cl2E,cl2ESub1);

        K16Type=pir_ufixpt_t(14,0);
        E9Type=pir_ufixpt_t(21,0);

        K16=configNet.addSignal(K16Type,'K16');
        E9=configNet.addSignal(E9Type,'E9');
        pirelab.getGainComp(configNet,KLatchDTC,K16,fi(16,0,8,0),1,1);
        pirelab.getGainComp(configNet,ELatchInt,E9,fi(9,0,8,0),1,1);

        K16E9Cmp=configNet.addSignal(boolType,'K16E9Cmp');
        pirelab.getRelOpComp(configNet,[K16,E9],K16E9Cmp,'<');

        EThreshType=pir_ufixpt_t(13,-3);

        nineEighths=configNet.addSignal(EThreshType,'nineEighths');
        nineEighths.SimulinkRate=dataRate;
        pirelab.getConstComp(configNet,nineEighths,9/8);

        EThresh=configNet.addSignal(EThreshType,'EThresh');
        pirelab.getDynamicBitShiftComp(configNet,[nineEighths,cl2ESub1],EThresh,'left');

        ELtEqThresh=configNet.addSignal(boolType,'ELtEqThresh');
        pirelab.getRelOpComp(configNet,[ELatchInt,EThresh],ELtEqThresh,'<=');


        n2_reg=configNet.addSignal(nType,'n2_reg');
        K16E9Cmp_reg=configNet.addSignal(boolType,'K16E9Cmp_reg');
        ELtEqThresh_reg=configNet.addSignal(boolType,'ELtEqThresh_reg');
        cl2E_reg=configNet.addSignal(nType,'cl2E_reg');
        cl2ESub1_reg=configNet.addSignal(nType,'cl2ESub1_reg');
        pirelab.getUnitDelayComp(configNet,n2,n2_reg);
        pirelab.getUnitDelayComp(configNet,K16E9Cmp,K16E9Cmp_reg);
        pirelab.getUnitDelayComp(configNet,ELtEqThresh,ELtEqThresh_reg);
        pirelab.getUnitDelayComp(configNet,cl2E,cl2E_reg);
        pirelab.getUnitDelayComp(configNet,cl2ESub1,cl2ESub1_reg);

        n1Cond=configNet.addSignal(boolType,'n1Cond');
        pirelab.getLogicComp(configNet,[K16E9Cmp_reg,ELtEqThresh_reg],n1Cond,'and');

        n1=configNet.addSignal(nType,'n1');
        pirelab.getMultiPortSwitchComp(configNet,[n1Cond,cl2E_reg,cl2ESub1_reg],n1,1);

        nInt=configNet.addSignal(nType,'nInt');
        pirelab.getMinMaxComp(configNet,[n1,n2_reg],nInt,'min','min');

        NValType=pir_ufixpt_t(NType.WordLength+1,0);

        one=configNet.addSignal(NValType,'one');
        one.SimulinkRate=dataRate;
        pirelab.getConstComp(configNet,one,1);

        NInt=configNet.addSignal(NValType,'NInt');
        pirelab.getDynamicBitShiftComp(configNet,[one,nInt],NInt,'left');

        NSub1Int=configNet.addSignal(NValType,'NSub1Int');
        pirelab.getDecrementRWV(configNet,NInt,NSub1Int);

        NSub1IntDTC=configNet.addSignal(NType,'NSub1IntDTC');
        pirelab.getDTCComp(configNet,NSub1Int,NSub1IntDTC);

        nSub1Int=configNet.addSignal(nType,'nSub1Int');
        pirelab.getDecrementRWV(configNet,nInt,nSub1Int);


        NInt_reg=configNet.addSignal(NValType,'NInt_reg');
        NSub1Int_reg=configNet.addSignal(NType,'NSub1Int_reg');
        nInt_reg=configNet.addSignal(nType,'nInt_reg');
        nSub1Int_reg=configNet.addSignal(nType,'nSub1Int_reg');
        pirelab.getUnitDelayComp(configNet,NInt,NInt_reg);
        pirelab.getUnitDelayComp(configNet,NSub1IntDTC,NSub1Int_reg);
        pirelab.getUnitDelayComp(configNet,nInt,nInt_reg);
        pirelab.getUnitDelayComp(configNet,nSub1Int,nSub1Int_reg);


        ELtN=configNet.addSignal(boolType,'ELtN');
        pirelab.getRelOpComp(configNet,[ELatchInt,NInt_reg],ELtN,'<');


        configuredInt=configNet.addSignal(boolType,'configured');
        FIdx=configNet.addSignal(NType,'FIdx');
        seqEn=configNet.addSignal(boolType,'seqEn');
        seqRst=configNet.addSignal(boolType,'seqRst');
        shortPuncEn=configNet.addSignal(boolType,'shortPuncEn');

        inports=[reconfig_reg,ELtN,NSub1Int_reg];
        outports=[configuredInt,FIdx,seqEn,seqRst,shortPuncEn];

        if downlinkMode
            mIdxType=pir_ufixpt_t(8,0);
            mIdx=configNet.addSignal(mIdxType,'mIdx');
            itlvMapEn=configNet.addSignal(boolType,'itlvMapEn');

            outports=[outports,mIdx,itlvMapEn];

            filename='configControllerDL';
        else
            filename='configControllerUL';
        end

        desc='configController - construct F, and intlvMap for DL';

        fid=fopen(fullfile(blockInfo.emlPath,[filename,'.m']),'r');
        fcnBody=fread(fid,Inf,'char=>char');
        fclose(fid);

        configCtrlr=configNet.addComponent2(...
        'kind','cgireml',...
        'Name','configCtrlr',...
        'InputSignals',inports,...
        'OutputSignals',outports,...
        'EMLFileName',filename,...
        'EMLFileBody',fcnBody,...
        'EMLParams',{nMax},...
        'EMLFlag_TreatInputIntsAsFixpt',true,...
        'EMLFlag_SaturateOnIntOverflow',false,...
        'EMLFlag_TreatInputBoolsAsUfix1',false,...
        'BlockComment',desc...
        );
        configCtrlr.runConcurrencyMaximizer(0);




        EShortPunc=configNet.addSignal(NType,'EShortPunc');
        pirelab.getDTCComp(configNet,ELatchInt,EShortPunc);

        five=configNet.addSignal(nType,'five');
        pirelab.getConstComp(configNet,five,5);

        nSub5=configNet.addSignal(nType,'nSub5');
        pirelab.getAddComp(configNet,[nInt_reg,five],nSub5,'FLoor','Wrap','Subtracter',[],'+-');



        PIdx=configNet.addSignal(NType,'PIdx');
        pirelab.getDynamicBitShiftComp(configNet,[FIdx,nSub5],PIdx,'right');

        PType=pir_ufixpt_t(5,0);

        PIdxDTC=configNet.addSignal(PType,'PIdxDTC');
        pirelab.getDTCComp(configNet,PIdx,PIdxDTC);

        P=configNet.addSignal(PType,'P');
        pirelab.getLookupComp(configNet,PIdxDTC,P,0:31,PLut);

        FIdxDTC=configNet.addSignal(PType,'FIdxDTC');
        pirelab.getDTCComp(configNet,FIdx,FIdxDTC);

        modMask=configNet.addSignal(PType,'modMask');
        pirelab.getLookupComp(configNet,nSub5,modMask,0:5,[0,1,3,7,15,31]);


        P_reg=configNet.addSignal(PType,'P_reg');
        nSub5_reg=configNet.addSignal(nType,'nSub5_reg');
        FIdxDTC_reg=configNet.addSignal(PType,'FIdxDTC_reg');
        modMask_reg=configNet.addSignal(PType,'modMask_reg');
        pirelab.getUnitDelayComp(configNet,P,P_reg);
        pirelab.getUnitDelayComp(configNet,nSub5,nSub5_reg);
        pirelab.getUnitDelayComp(configNet,FIdxDTC,FIdxDTC_reg);
        pirelab.getUnitDelayComp(configNet,modMask,modMask_reg);

        PDTC=configNet.addSignal(NType,'PDTC');
        pirelab.getDTCComp(configNet,P_reg,PDTC);

        JBlockOffset=configNet.addSignal(NType,'JBlockOffset');
        pirelab.getDynamicBitShiftComp(configNet,[PDTC,nSub5_reg],JBlockOffset,'left');


        JBlockIdx=configNet.addSignal(PType,'JBlockIdx');
        pirelab.getBitwiseOpComp(configNet,[FIdxDTC_reg,modMask_reg],JBlockIdx,'and');

        J=configNet.addSignal(NType,'J');
        pirelab.getAddComp(configNet,[JBlockOffset,JBlockIdx],J);


        FIdx_reg=configNet.addSignal(NType,'FIdx_reg');
        pirelab.getUnitDelayComp(configNet,FIdx,FIdx_reg);


        NSubE=configNet.addSignal(NType,'NSubE');
        pirelab.getAddComp(configNet,[NInt_reg,EShortPunc],NSubE,'FLoor','Wrap','Subtracter',[],'+-');

        NScale9_16=configNet.addSignal(NType,'NScale916');
        pirelab.getGainComp(configNet,NInt_reg,NScale9_16,fi(9/16,0,4,4),1,1);

        NScale3_4=configNet.addSignal(NType,'NScale34');
        pirelab.getGainComp(configNet,NInt_reg,NScale3_4,fi(3/4,0,2,2),1,1);

        EHalfType=pir_ufixpt_t(10,-1);
        EQuartType=pir_ufixpt_t(10,-2);

        EScale1_2=configNet.addSignal(EHalfType,'EScale1_2');
        pirelab.getGainComp(configNet,EShortPunc,EScale1_2,fi(1/2,0,1,1),1,1);

        EScale1_4=configNet.addSignal(EQuartType,'EScale1_2');
        pirelab.getGainComp(configNet,EScale1_2,EScale1_4,fi(1/2,0,1,1),1,1);


        FIdx_reg_reg=configNet.addSignal(NType,'FIdx_reg_reg');
        NSubE_reg=configNet.addSignal(NType,'NSubE_reg');
        EShortPunc_reg=configNet.addSignal(NType,'EShortPunc_reg');
        NScale9_16_reg=configNet.addSignal(NType,'NScale9_16_reg');
        NScale3_4_reg=configNet.addSignal(NType,'NScale3_4_reg');
        EScale1_2_reg=configNet.addSignal(EHalfType,'EScale1_2_reg');
        EScale1_4_reg=configNet.addSignal(EQuartType,'EScale1_4_reg');
        J_reg=configNet.addSignal(NType,'J_reg');
        pirelab.getUnitDelayComp(configNet,FIdx_reg,FIdx_reg_reg);
        pirelab.getUnitDelayComp(configNet,NSubE,NSubE_reg);
        pirelab.getUnitDelayComp(configNet,EShortPunc,EShortPunc_reg);
        pirelab.getUnitDelayComp(configNet,NScale9_16,NScale9_16_reg);
        pirelab.getUnitDelayComp(configNet,NScale3_4,NScale3_4_reg);
        pirelab.getUnitDelayComp(configNet,EScale1_2,EScale1_2_reg);
        pirelab.getUnitDelayComp(configNet,EScale1_4,EScale1_4_reg);
        pirelab.getUnitDelayComp(configNet,J,J_reg);

        FIdxLtNSubE=configNet.addSignal(boolType,'FIdxLtNSubE');
        pirelab.getRelOpComp(configNet,[FIdx_reg_reg,NSubE_reg],FIdxLtNSubE,'<');

        puncMode=configNet.addSignal(boolType,'EGtEqNScale3_4');
        pirelab.getRelOpComp(configNet,[EShortPunc_reg,NScale3_4_reg],puncMode,'>=');

        puncLimA=configNet.addSignal(NType,'puncLimA');
        pirelab.getAddComp(configNet,[NScale9_16_reg,EScale1_4_reg],puncLimA,'FLoor','Wrap','Subtracter',[],'+-');

        puncLimB=configNet.addSignal(NType,'puncLimA');
        pirelab.getAddComp(configNet,[NScale3_4_reg,EScale1_2_reg],puncLimB,'FLoor','Wrap','Subtracter',[],'+-');

        JLtLimA=configNet.addSignal(boolType,'JLtLimA');
        JLtLimB=configNet.addSignal(boolType,'JLtLimB');
        pirelab.getRelOpComp(configNet,[J_reg,puncLimA],JLtLimA,'<');
        pirelab.getRelOpComp(configNet,[J_reg,puncLimB],JLtLimB,'<');

        puncLimSel=configNet.addSignal(boolType,'puncLimSel');
        pirelab.getMultiPortSwitchComp(configNet,[puncMode,JLtLimA,JLtLimB],puncLimSel,1);

        puncture=configNet.addSignal(boolType,'puncture');
        pirelab.getLogicComp(configNet,[FIdxLtNSubE,puncLimSel],puncture,'or');


        FIdxGtEqE=configNet.addSignal(boolType,'FIdxGtEqE');
        pirelab.getRelOpComp(configNet,[FIdx_reg,EShortPunc],FIdxGtEqE,'>=');

        FIdxLtN=configNet.addSignal(boolType,'FIdxLtN');
        pirelab.getRelOpComp(configNet,[FIdx_reg,NInt_reg],FIdxLtN,'<');


        FIdxGtEqE_reg=configNet.addSignal(boolType,'FIdxGtEqE_reg');
        FIdxLtN_reg=configNet.addSignal(boolType,'FIdxLtN_reg');
        pirelab.getUnitDelayComp(configNet,FIdxGtEqE,FIdxGtEqE_reg);
        pirelab.getUnitDelayComp(configNet,FIdxLtN,FIdxLtN_reg);

        shorten=configNet.addSignal(boolType,'shorten');
        pirelab.getLogicComp(configNet,[FIdxGtEqE_reg,FIdxLtN_reg],shorten,'and');


        K16Type=pir_ufixpt_t(14,0);
        E7Type=pir_ufixpt_t(13,0);

        K16=configNet.addSignal(K16Type,'K16');
        E7=configNet.addSignal(E7Type,'E7');
        pirelab.getGainComp(configNet,KLatchDTC,K16,fi(16,0,5,0),1,1);
        pirelab.getGainComp(configNet,EShortPunc,E7,fi(7,0,3,0),1,1);


        K16_reg=configNet.addSignal(K16Type,'K16_reg');
        E7_reg=configNet.addSignal(E7Type,'E7_Reg');
        pirelab.getUnitDelayComp(configNet,K16,K16_reg);
        pirelab.getUnitDelayComp(configNet,E7,E7_reg);

        shortPuncMode=configNet.addSignal(boolType,'shortPuncMode');
        pirelab.getRelOpComp(configNet,[K16_reg,E7_reg],shortPuncMode,'<=');


        shortPuncMode_reg=configNet.addSignal(boolType,'shortPuncMode_reg');
        shorten_reg=configNet.addSignal(boolType,'shorten_reg');
        puncture_reg=configNet.addSignal(boolType,'puncture_reg');
        pirelab.getUnitDelayComp(configNet,shortPuncMode,shortPuncMode_reg);
        pirelab.getUnitDelayComp(configNet,shorten,shorten_reg);
        pirelab.getUnitDelayComp(configNet,puncture,puncture_reg);

        removeIdx=configNet.addSignal(boolType,'removeIdx');
        pirelab.getMultiPortSwitchComp(configNet,[shortPuncMode_reg,shorten_reg,puncture_reg],removeIdx,1);

        shortPuncEn_reg=configNet.addSignal(boolType,'shortPuncEn_reg');
        pirelab.getIntDelayComp(configNet,shortPuncEn,shortPuncEn_reg,3);

        shortPuncIdx=configNet.addSignal(NType,'shortPuncIdx');
        pirelab.getUnitDelayComp(configNet,J_reg,shortPuncIdx);


        thirtyOne=configNet.addSignal(NType,'thirtyOne');
        pirelab.getConstComp(configNet,thirtyOne,31);

        seqLutAddr=configNet.addSignal(seqAddrType,'NSeqOffset');
        pirelab.getAddComp(configNet,[FIdx_reg_reg,NSub1Int_reg,thirtyOne],seqLutAddr,'FLoor','Wrap','Subtracter',[],'++-');

        seqLutAddr_reg=configNet.addSignal(seqAddrType,'seqLutAddr_reg');
        pirelab.getUnitDelayComp(configNet,seqLutAddr,seqLutAddr_reg);

        seqIdx=configNet.addSignal(NType,'seqIdx');
        pirelab.getLookupComp(configNet,seqLutAddr_reg,seqIdx,0:length(seqLut)-1,seqLut);

        seqIdx_reg=configNet.addSignal(NType,'sequenceIdx_reg');
        pirelab.getUnitDelayComp(configNet,seqIdx,seqIdx_reg);

        seqIdx_reg_reg=configNet.addSignal(NType,'sequenceIdx_reg_reg');
        pirelab.getIntDelayComp(configNet,seqIdx_reg,seqIdx_reg_reg,2);

        idxRemoved=configNet.addSignal(boolType,'idxRemoved');
        pirelab.getSimpleDualPortRamComp(configNet,[removeIdx,shortPuncIdx,shortPuncEn_reg,seqIdx_reg],idxRemoved);

        idxRemoved_reg=configNet.addSignal(boolType,'idxRemoved_reg');
        pirelab.getUnitDelayComp(configNet,idxRemoved,idxRemoved_reg);

        candInfoBit=configNet.addSignal(boolType,'candInfoBit');
        pirelab.getLogicComp(configNet,[ELtN,idxRemoved_reg],candInfoBit,'nand');

        seqEn_reg=configNet.addSignal(boolType,'sequenceEn_reg');
        pirelab.getIntDelayComp(configNet,seqEn,seqEn_reg,6);

        rstInfoCnt=configNet.addSignal(boolType,'rstInfoCnt');
        pirelab.getIntDelayComp(configNet,seqRst,rstInfoCnt,5);

        infoCnt=configNet.addSignal(NType,'infoCnt');
        pirelab.getCounterComp(configNet,[rstInfoCnt,candInfoBit],infoCnt,'Free running',0,1,[],1,0,1,0);

        numInfoBits=configNet.addSignal(NType,'numInfoBits');
        if downlinkMode
            pirelab.getWireComp(configNet,KLatchDTC,numInfoBits);
        else


            KPlus3=configNet.addSignal(KType,'KPLus3');
            const3=configNet.addSignal(pir_ufixpt_t(2,0),'const3');
            const3.SimulinkRate=dataRate;
            pirelab.getConstComp(configNet,const3,3);
            pirelab.getAddComp(configNet,[KLatchInt,const3],KPlus3);

            pirelab.getMultiPortSwitchComp(configNet,[parityEnInt,KLatchDTC,KPlus3],numInfoBits,1);



            remainingInfoBits=configNet.addSignal(NType,'infoCntSubTotal');
            pirelab.getSubComp(configNet,[numInfoBits,infoCnt],remainingInfoBits);

            for ii=1:3
                isParityBit(ii)=configNet.addSignal(boolType,['isParityBit_',num2str(ii)]);%#ok
                pirelab.getCompareToValueComp(configNet,remainingInfoBits,isParityBit(ii),'==',ii);

                parityWrEn(ii)=configNet.addSignal(boolType,['parityWrEn_',num2str(ii)]);%#ok
                pirelab.getLogicComp(configNet,[isParityBit(ii),seqEn_reg],parityWrEn(ii),'and');

                parityIdx(ii)=configNet.addSignal(NType,['parityIdx_',num2str(ii)]);%#ok
                pirelab.getUnitDelayEnabledComp(configNet,seqIdx_reg_reg,parityIdx(ii),parityWrEn(ii));
            end




            rowWeightLUT=blockInfo.rowWeightLUT;
            rowWeight=configNet.addSignal(nType,'rowWeight');
            pirelab.getLookupComp(configNet,seqIdx_reg,rowWeight,0:1023,rowWeightLUT);

            rowWeight_reg=configNet.addSignal(nType,'rowWeight_reg');
            pirelab.getIntDelayComp(configNet,rowWeight,rowWeight_reg,2);


            isWmBitCand=configNet.addSignal(boolType,'isWmBitCand');
            infoCntLtK=configNet.addSignal(boolType,'infoCntLtK');
            pirelab.getRelOpComp(configNet,[infoCnt,KLatchDTC],infoCntLtK,'<');
            pirelab.getLogicComp(configNet,[candInfoBit,infoCntLtK],isWmBitCand,'and');

            lowerRowWeight=configNet.addSignal(boolType,'lowerRowWeight');
            wmWrEn=configNet.addSignal(boolType,'wmWrEn');
            pirelab.getLogicComp(configNet,[seqEn_reg,isWmBitCand,lowerRowWeight],wmWrEn,'and');

            wmIdx=configNet.addSignal(NType,'wmIdx');
            wmRowWeight=configNet.addSignal(nType,'curRowWeight');
            pirelab.getUnitDelayEnabledResettableComp(configNet,seqIdx_reg_reg,wmIdx,wmWrEn,rstInfoCnt);


            pirelab.getUnitDelayEnabledResettableComp(configNet,rowWeight_reg,wmRowWeight,wmWrEn,rstInfoCnt,'wmRowWeightReg',11,'',false,'',-1,true);

            pirelab.getRelOpComp(configNet,[rowWeight_reg,wmRowWeight],lowerRowWeight,'<');



            selectedPC=configNet.addSignal(NType,'selectedPC');
            pirelab.getMultiPortSwitchComp(configNet,[nwm,parityIdx(3),wmIdx],selectedPC,1);

            qPC=configNet.addSignal(qPCType,'qPC');
            pirelab.getConcatenateComp(configNet,[parityIdx(1:2),selectedPC],qPC,'Multidimensional array',2);

            isParityVecType=pirelab.createPirArrayType(boolType,[1,3]);
            isParityVec=configNet.addSignal(isParityVecType,'isParityVec');
            pirelab.getRelOpComp(configNet,[qPC,leafIdx],isParityVec,'==');

            isParityIdx=configNet.addSignal(boolType,'isParityIdx');
            pirelab.getBitwiseOpComp(configNet,isParityVec,isParityIdx,'or');

            isParityInt=configNet.addSignal(boolType,'isParityint');
            pirelab.getLogicComp(configNet,[isParityIdx,parityEnInt],isParityInt,'and');
        end

        infoCntLtInfoBits=configNet.addSignal(boolType,'infoCntLtK');
        pirelab.getRelOpComp(configNet,[infoCnt,numInfoBits],infoCntLtInfoBits,'<');

        infoBit=configNet.addSignal(boolType,'infoBit');
        pirelab.getLogicComp(configNet,[infoCntLtInfoBits,candInfoBit],infoBit,'and');

        FInt=configNet.addSignal(boolType,'FInt');
        pirelab.getSimpleDualPortRamComp(configNet,[infoBit,seqIdx_reg_reg,seqEn_reg,leafIdx],FInt);


        if downlinkMode
            mIdx_reg=configNet.addSignal(mIdxType,'mIdx_reg');
            pirelab.getUnitDelayComp(configNet,mIdx,mIdx_reg);

            rstItlvCnt=configNet.addSignal(boolType,'rstItlvCnt');
            pirelab.getCompareToValueComp(configNet,mIdx_reg,rstItlvCnt,'==',0);

            itlvPatOut=configNet.addSignal(KType,'itlvPatOut');
            pirelab.getLookupComp(configNet,mIdx_reg,itlvPatOut,0:255,[itlvPattern;zeros(92,1)]);

            KMax=configNet.addSignal(KType,'KMax');
            KMax.SimulinkRate=dataRate;
            pirelab.getConstComp(configNet,KMax,164);

            KMaxSubK=configNet.addSignal(KType,'KMaxSubK');
            pirelab.getAddComp(configNet,[KMax,KLatchDTC],KMaxSubK,'Floor','Wrap','adder',[],'+-');

            itlvPatOut_reg=configNet.addSignal(KType,'itlvPatOut_reg');
            pirelab.getIntDelayComp(configNet,itlvPatOut,itlvPatOut_reg,2);

            KMaxSubK_reg=configNet.addSignal(KType,'KMaxSubK_reg');
            pirelab.getIntDelayComp(configNet,KMaxSubK,KMaxSubK_reg,2);

            itlvIdx=configNet.addSignal(KType,'itlvIdx');
            pirelab.getAddComp(configNet,[itlvPatOut_reg,KMaxSubK_reg],itlvIdx,'Floor','Wrap','adder',[],'+-');

            itlvIdxValid=configNet.addSignal(boolType,'itlvIdxValid');
            pirelab.getRelOpComp(configNet,[itlvPatOut_reg,KMaxSubK_reg],itlvIdxValid,'>=');

            itlvIdxValid_reg=configNet.addSignal(boolType,'itlvIdxValid_reg');
            pirelab.getUnitDelayComp(configNet,itlvIdxValid,itlvIdxValid_reg);

            itlvMapEn_reg=configNet.addSignal(boolType,'itlvMapEn_reg');
            pirelab.getIntDelayComp(configNet,itlvMapEn,itlvMapEn_reg,4);

            rstItlvCnt_reg=configNet.addSignal(boolType,'rstItlvCnt_reg');
            pirelab.getIntDelayComp(configNet,rstItlvCnt,rstItlvCnt_reg,2);

            itlvRamWrAddr=configNet.addSignal(KType,'itlvRamWrAddr');
            pirelab.getCounterComp(configNet,[rstItlvCnt_reg,itlvIdxValid_reg],itlvRamWrAddr,'Free running',0,1,[],1,0,1,0);

            itlvRamWrEn=configNet.addSignal(boolType,'itlvRamWrEn');
            pirelab.getLogicComp(configNet,[itlvMapEn_reg,itlvIdxValid_reg],itlvRamWrEn,'and');

            itlvIdx_reg=configNet.addSignal(KType,'itlvIdx_reg');
            pirelab.getIntDelayComp(configNet,itlvIdx,itlvIdx_reg,2);

            itlvRamWrAddr_reg=configNet.addSignal(KType,'itlvRamWrAddr_reg');
            pirelab.getUnitDelayComp(configNet,itlvRamWrAddr,itlvRamWrAddr_reg);

            itlvRamWrEn_reg=configNet.addSignal(boolType,'itlvRamWrEn_reg');
            pirelab.getUnitDelayComp(configNet,itlvRamWrEn,itlvRamWrEn_reg);

            itlvRamDout=configNet.addSignal(KType,'itlvRamDout');
            pirelab.getSimpleDualPortRamComp(configNet,[itlvIdx_reg,itlvRamWrAddr_reg,itlvRamWrEn_reg,itlvPathRdAddr],itlvRamDout);
        end

        pirelab.getWireComp(configNet,KLatchDTC,KLatch);
        pirelab.getWireComp(configNet,nSub1Int_reg,nSub1);
        pirelab.getWireComp(configNet,NSub1Int_reg,NSub1);
        pirelab.getUnitDelayComp(configNet,FInt,F);
        pirelab.getWireComp(configNet,configuredInt,configured);

        if downlinkMode
            pirelab.getWireComp(configNet,ELatchInt,ELatch);
            pirelab.getUnitDelayComp(configNet,itlvRamDout,deitlvPathRdAddr);
        else

            pirelab.getIntDelayComp(configNet,isParityInt,isParity,2);
            pirelab.getWireComp(configNet,parityEnInt,parityEn);
        end
    else
        pirelab.getConstComp(configNet,KLatch,messageLength,'const','off','false','');

        pirelab.getConstComp(configNet,nSub1,n-1);

        pirelab.getConstComp(configNet,NSub1,NInt-1);

        FLutOut=configNet.addSignal(boolType,'FLutOut');
        pirelab.getLookupComp(configNet,leafIdx,FLutOut,0:NInt-1,FLut);

        pirelab.getIntDelayComp(configNet,FLutOut,F,2);

        pirelab.getConstComp(configNet,configured,true);

        if downlinkMode
            pirelab.getConstComp(configNet,ELatch,rate,'const','off','false','');

            itlvLutOut=configNet.addSignal(KType,'itlvLutOut');
            pirelab.getLookupComp(configNet,itlvPathRdAddr,itlvLutOut,0:messageLength-1,itlvLut);

            pirelab.getIntDelayComp(configNet,itlvLutOut,deitlvPathRdAddr,2);
        else
            parityEnInt=configNet.addSignal(boolType,'parityEnInt');
            parityEnInt.SimulinkRate=dataRate;
            pirelab.getConstComp(configNet,parityEnInt,parityEnProp);

            qPC=configNet.addSignal(qPCType,'qPC');
            qPC.SimulinkRate=dataRate;
            pirelab.getConstComp(configNet,qPC,qPCProp);

            isParityVecType=pirelab.createPirArrayType(boolType,[1,3]);
            isParityVec=configNet.addSignal(isParityVecType,'isParityVec');
            pirelab.getRelOpComp(configNet,[qPC,leafIdx],isParityVec,'==');

            isParityIdx=configNet.addSignal(boolType,'isParityIdx');
            pirelab.getBitwiseOpComp(configNet,isParityVec,isParityIdx,'or');

            isParityInt=configNet.addSignal(boolType,'isParityint');
            pirelab.getLogicComp(configNet,[isParityIdx,parityEnInt],isParityInt,'and');

            pirelab.getIntDelayComp(configNet,isParityInt,isParity,2);
            pirelab.getWireComp(configNet,parityEnInt,parityEn);
        end

        pirelab.getConstComp(configNet,configValid,1);
    end
end
