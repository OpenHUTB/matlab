function coreNet=elaborateBilinearCore(this,topNet,blockInfo,sigInfo,dataRate)











    inType=sigInfo.inType;
    booleanT=sigInfo.booleanT;
    if blockInfo.NumPixels==1
        selT=pir_ufixpt_t(3,0);
    else
        selT=pirelab.createPirArrayType(pir_ufixpt_t(3,0),[1,2]);
        dataRType=sigInfo.dataRType;
    end
    sigInfo.selT=selT;


    inPortNames={'data1','data2','data3','hStartIn','hEndIn','vStartIn','vEndIn','validIn','processDataIn'};
    inPortRates=[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate];
    outPortNames={'R','G','B','hStartOut','hEndOut','vStartOut','vEndOut','validOut'};

    if blockInfo.NumPixels==1
        inPortTypes=[inType,inType,inType,booleanT,booleanT,booleanT,booleanT,booleanT,booleanT];
        outPortTypes=[inType,inType,inType,booleanT,booleanT,booleanT,booleanT,booleanT];
    else
        inPortTypes=[dataRType,dataRType,dataRType,booleanT,booleanT,booleanT,booleanT,booleanT,booleanT];
        outPortTypes=[dataRType,dataRType,dataRType,booleanT,booleanT,booleanT,booleanT,booleanT];
    end

    coreNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','BilinearFilterCore',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );


    inSignals=coreNet.PirInputSignals;
    data1=inSignals(1);
    data2=inSignals(2);
    data3=inSignals(3);
    hStartIn=inSignals(4);
    hEndIn=inSignals(5);
    vStartIn=inSignals(6);
    vEndIn=inSignals(7);
    validIn=inSignals(8);
    processDataIn=inSignals(9);


    outSignals=coreNet.PirOutputSignals;
    R=outSignals(1);
    G=outSignals(2);
    B=outSignals(3);
    hStartOut=outSignals(4);
    hEndOut=outSignals(5);
    vStartOut=outSignals(6);
    vEndOut=outSignals(7);
    validOut=outSignals(8);


    if blockInfo.NumPixels==1
        REG1OUT=coreNet.addSignal2('Type',inType,'Name','REG1OUT');
        REG2OUT=coreNet.addSignal2('Type',inType,'Name','REG2OUT');
        REG3OUT=coreNet.addSignal2('Type',inType,'Name','REG3OUT');
        REG4OUT=coreNet.addSignal2('Type',inType,'Name','REG4OUT');
        REG5OUT=coreNet.addSignal2('Type',inType,'Name','REG5OUT');
        REG6OUT=coreNet.addSignal2('Type',inType,'Name','REG6OUT');


        pirelab.getUnitDelayEnabledComp(coreNet,data1,REG1OUT,processDataIn,'REG1');
        pirelab.getUnitDelayEnabledComp(coreNet,REG1OUT,REG2OUT,processDataIn,'REG2');


        pirelab.getUnitDelayEnabledComp(coreNet,data2,REG3OUT,processDataIn,'REG3');
        pirelab.getUnitDelayEnabledComp(coreNet,REG3OUT,REG4OUT,processDataIn,'REG4');


        pirelab.getUnitDelayEnabledComp(coreNet,data3,REG5OUT,processDataIn,'REG5');
        pirelab.getUnitDelayEnabledComp(coreNet,REG5OUT,REG6OUT,processDataIn,'REG6');
    else
        for ii=1:blockInfo.NumPixels
            data1Split(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['data1Split_',num2str(ii)]);%#ok<AGROW>
            data2Split(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['data2Split_',num2str(ii)]);%#ok<AGROW>
            data3Split(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['data3Split_',num2str(ii)]);%#ok<AGROW>

            MulPixREG1(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['MulPixREG1_',num2str(ii)]);%#ok<AGROW>
            MulPixREG2(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['MulPixREG2_',num2str(ii)]);%#ok<AGROW>
            MulPixREG3(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['MulPixREG3_',num2str(ii)]);%#ok<AGROW>
            MulPixREG4(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['MulPixREG4_',num2str(ii)]);%#ok<AGROW>
            MulPixREG5(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['MulPixREG5_',num2str(ii)]);%#ok<AGROW>
            MulPixREG6(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['MulPixREG6_',num2str(ii)]);%#ok<AGROW>


            pirelab.getSelectorComp(coreNet,data1,data1Split(ii),'one-based',{'Index vector (dialog)','Index vector (dialog)'},{1,ii},{'1','1'},'2',['data1_selector_(1,',num2str(ii),')']);
            pirelab.getSelectorComp(coreNet,data2,data2Split(ii),'one-based',{'Index vector (dialog)','Index vector (dialog)'},{1,ii},{'1','1'},'2',['data2_selector_(1,',num2str(ii),')']);
            pirelab.getSelectorComp(coreNet,data3,data3Split(ii),'one-based',{'Index vector (dialog)','Index vector (dialog)'},{1,ii},{'1','1'},'2',['data3_selector_(1,',num2str(ii),')']);



            pirelab.getUnitDelayEnabledComp(coreNet,data1Split(ii),MulPixREG1(ii),processDataIn,['MulPixREG1_r1d1p',num2str(ii)]);
            pirelab.getUnitDelayEnabledComp(coreNet,MulPixREG1(ii),MulPixREG2(ii),processDataIn,['MulPixREG2_r1d2p',num2str(ii)]);

            pirelab.getUnitDelayEnabledComp(coreNet,data2Split(ii),MulPixREG3(ii),processDataIn,['MulPixREG3_r2d1p',num2str(ii)]);
            pirelab.getUnitDelayEnabledComp(coreNet,MulPixREG3(ii),MulPixREG4(ii),processDataIn,['MulPixREG4_r2d2p',num2str(ii)]);

            pirelab.getUnitDelayEnabledComp(coreNet,data3Split(ii),MulPixREG5(ii),processDataIn,['MulPixREG5_r3d1p',num2str(ii)]);
            pirelab.getUnitDelayEnabledComp(coreNet,MulPixREG5(ii),MulPixREG6(ii),processDataIn,['MulPixREG6_r3d2p',num2str(ii)]);
        end
    end



    dataWriteNet=this.elabDataWrite(coreNet,blockInfo,sigInfo,dataRate);


    REG15OUT=coreNet.addSignal2('Type',booleanT,'Name','REG15OUT');
    REG16OUT=coreNet.addSignal2('Type',booleanT,'Name','REG16OUT');
    REG17OUT=coreNet.addSignal2('Type',booleanT,'Name','REG17OUT');
    REG18OUT=coreNet.addSignal2('Type',booleanT,'Name','REG18OUT');
    REG19OUT=coreNet.addSignal2('Type',booleanT,'Name','REG19OUT');

    pirelab.getUnitDelayComp(coreNet,hStartIn,REG15OUT,'REG15');
    pirelab.getIntDelayComp(coreNet,hEndIn,REG16OUT,2,'REG16');
    pirelab.getUnitDelayComp(coreNet,vStartIn,REG17OUT,'REG17');
    pirelab.getIntDelayComp(coreNet,vEndIn,REG18OUT,2,'REG18');
    pirelab.getUnitDelayComp(coreNet,validIn,REG19OUT,'REG19');

    dataWriteInput=[REG15OUT,REG16OUT,REG17OUT,REG18OUT,REG19OUT];


    SELR=coreNet.addSignal2('Type',selT,'Name','SELR');
    SELG=coreNet.addSignal2('Type',selT,'Name','SELG');
    SELB=coreNet.addSignal2('Type',selT,'Name','SELB');

    dataWriteOutput=[SELR,SELG,SELB];

    pirelab.instantiateNetwork(coreNet,dataWriteNet,dataWriteInput,dataWriteOutput,'dataWriteController');



    bilinearFilterNet1=this.elabBilinearKernel1(coreNet,blockInfo,sigInfo,dataRate);

    if blockInfo.NumPixels==1
        bilinearIn1=[REG5OUT,REG4OUT,data2,REG1OUT];

        bilinearFilterOut1=coreNet.addSignal2('Type',inType,'Name','BilinearFilterOut1');
        bilinearOut1=bilinearFilterOut1;

        pirelab.instantiateNetwork(coreNet,bilinearFilterNet1,bilinearIn1,bilinearOut1,'bilinearFilterKernel1');
    else
        for ii=1:blockInfo.NumPixels
            if ii==1
                bilinearIn1=[MulPixREG5(ii),MulPixREG3(2),MulPixREG4(blockInfo.NumPixels),MulPixREG1(ii)];

            elseif ii<blockInfo.NumPixels
                bilinearIn1=[MulPixREG5(ii),MulPixREG3(ii+1),MulPixREG3(ii-1),MulPixREG1(ii)];

            else
                bilinearIn1=[MulPixREG5(ii),data2Split(1),MulPixREG3(ii-1),MulPixREG1(ii)];

            end
            bilinearOut1(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['BilinearFilterOut1_',num2str(ii)]);%#ok<AGROW>
            pirelab.instantiateNetwork(coreNet,bilinearFilterNet1,bilinearIn1,bilinearOut1(ii),['bilinearFilterKernel1_',num2str(ii)]);
        end
    end


    bilinearFilterNet2=this.elabBilinearKernel2(coreNet,blockInfo,sigInfo,dataRate);

    if blockInfo.NumPixels==1
        bilinearIn2=[REG6OUT,data3,REG2OUT,data1];

        bilinearFilterOut2=coreNet.addSignal2('Type',inType,'Name','BilinearFilterOut2');
        bilinearOut2=bilinearFilterOut2;

        pirelab.instantiateNetwork(coreNet,bilinearFilterNet2,bilinearIn2,bilinearOut2,'bilinearFilterKernel2');
    else
        for ii=1:blockInfo.NumPixels
            if ii==1
                bilinearIn2=[MulPixREG5(2),MulPixREG6(blockInfo.NumPixels),MulPixREG1(2),MulPixREG2(blockInfo.NumPixels)];

            elseif ii<blockInfo.NumPixels
                bilinearIn2=[MulPixREG5(ii+1),MulPixREG5(ii-1),MulPixREG1(ii+1),MulPixREG1(ii-1)];

            else
                bilinearIn2=[data3Split(1),MulPixREG5(ii-1),data1Split(1),MulPixREG1(ii-1)];

            end
            bilinearOut2(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['BilinearFilterOut2_',num2str(ii)]);%#ok<AGROW>
            pirelab.instantiateNetwork(coreNet,bilinearFilterNet2,bilinearIn2,bilinearOut2(ii),['bilinearFilterKernel2_',num2str(ii)]);
        end
    end


    bilinearFilterNet3=this.elabBilinearKernel3(coreNet,blockInfo,sigInfo,dataRate);

    if blockInfo.NumPixels==1
        bilinearIn3=[REG5OUT,REG1OUT];

        bilinearFilterOut3=coreNet.addSignal2('Type',inType,'Name','BilinearFilterOut3');
        bilinearOut3=bilinearFilterOut3;

        pirelab.instantiateNetwork(coreNet,bilinearFilterNet3,bilinearIn3,bilinearOut3,'bilinearFilterKernel3');
    else
        for ii=1:blockInfo.NumPixels
            bilinearIn3=[MulPixREG5(ii),MulPixREG1(ii)];
            bilinearOut3(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['BilinearFilterOut3_',num2str(ii)]);%#ok<AGROW>
            pirelab.instantiateNetwork(coreNet,bilinearFilterNet3,bilinearIn3,bilinearOut3(ii),['bilinearFilterKernel3_',num2str(ii)]);
        end
    end


    bilinearFilterNet4=this.elabBilinearKernel4(coreNet,blockInfo,sigInfo,dataRate);

    if blockInfo.NumPixels==1
        bilinearIn4=[REG4OUT,data2];

        bilinearFilterOut4=coreNet.addSignal2('Type',inType,'Name','BilinearFilterOut4');
        bilinearOut4=bilinearFilterOut4;

        pirelab.instantiateNetwork(coreNet,bilinearFilterNet4,bilinearIn4,bilinearOut4,'bilinearFilterKernel4');
    else
        for ii=1:blockInfo.NumPixels
            if ii==1
                bilinearIn4=[MulPixREG3(2),MulPixREG4(blockInfo.NumPixels)];

            elseif ii<blockInfo.NumPixels
                bilinearIn4=[MulPixREG3(ii+1),MulPixREG3(ii-1)];

            else
                bilinearIn4=[data2Split(1),MulPixREG3(ii-1)];

            end
            bilinearOut4(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['BilinearFilterOut4_',num2str(ii)]);%#ok<AGROW>
            pirelab.instantiateNetwork(coreNet,bilinearFilterNet4,bilinearIn4,bilinearOut4(ii),['bilinearFilterKernel4_',num2str(ii)]);
        end
    end


    if blockInfo.NumPixels==1
        passThru=coreNet.addSignal2('Type',inType,'Name','passThrough');
        pirelab.getUnitDelayComp(coreNet,REG3OUT,passThru,'passThroughREG');
    else
        for ii=1:blockInfo.NumPixels
            passThru(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['passThrough_',num2str(ii)]);%#ok<AGROW>
            pirelab.getUnitDelayComp(coreNet,MulPixREG3(ii),passThru(ii),['passThroughREG_',num2str(ii)]);
        end
    end


    ConstantZeroB=coreNet.addSignal2('Type',booleanT,'Name','ConstantZero');
    notValid=coreNet.addSignal2('Type',booleanT,'Name','notValid');
    preValid=coreNet.addSignal2('Type',booleanT,'Name','preValid');
    hEndPost=coreNet.addSignal2('Type',booleanT,'Name','hEndPost');
    hStartPre=coreNet.addSignal2('Type',booleanT,'Name','hStartPre');
    hStartGate=coreNet.addSignal2('Type',booleanT,'Name','hStartGate');
    vStartPre=coreNet.addSignal2('Type',booleanT,'Name','vStartPre');
    vStartGate=coreNet.addSignal2('Type',booleanT,'Name','vStartGate');
    validGate=coreNet.addSignal2('Type',booleanT,'Name','validGate');
    processDataREG=coreNet.addSignal2('Type',booleanT,'Name','processDataREG');

    if blockInfo.NumPixels==1
        GMUXOut=coreNet.addSignal2('Type',inType,'Name','GmuxOut');
        RMUXOut=coreNet.addSignal2('Type',inType,'Name','RmuxOut');
        BMUXOut=coreNet.addSignal2('Type',inType,'Name','BmuxOut');
        GMUXV=coreNet.addSignal2('Type',inType,'Name','GmuxV');
        RMUXV=coreNet.addSignal2('Type',inType,'Name','RmuxV');
        BMUXV=coreNet.addSignal2('Type',inType,'Name','BmuxV');
        ConstantZero=coreNet.addSignal2('Type',inType,'Name','ConstantZero');

        pirelab.getSwitchComp(coreNet,[bilinearOut1,bilinearOut2,bilinearOut3,bilinearOut4,passThru],RMUXOut,SELR);
        pirelab.getSwitchComp(coreNet,[bilinearOut1,bilinearOut2,bilinearOut3,bilinearOut4,passThru],GMUXOut,SELG);
        pirelab.getSwitchComp(coreNet,[bilinearOut1,bilinearOut2,bilinearOut3,bilinearOut4,passThru],BMUXOut,SELB);
    else
        RMUXOut=coreNet.addSignal2('Type',dataRType,'Name','RmuxOut');
        GMUXOut=coreNet.addSignal2('Type',dataRType,'Name','GmuxOut');
        BMUXOut=coreNet.addSignal2('Type',dataRType,'Name','BmuxOut');
        RMUXV=coreNet.addSignal2('Type',dataRType,'Name','RmuxV');
        GMUXV=coreNet.addSignal2('Type',dataRType,'Name','GmuxV');
        BMUXV=coreNet.addSignal2('Type',dataRType,'Name','BmuxV');
        ConstantZero=coreNet.addSignal2('Type',dataRType,'Name','ConstantZero');


        for ii=1:2
            SELRMulPix(ii)=coreNet.addSignal2('Type',selT.BaseType,'Name',['SELRMulPix_P',num2str(ii)]);%#ok<AGROW>
            SELGMulPix(ii)=coreNet.addSignal2('Type',selT.BaseType,'Name',['SELGMulPix_P',num2str(ii)]);%#ok<AGROW>
            SELBMulPix(ii)=coreNet.addSignal2('Type',selT.BaseType,'Name',['SELBMulPix_P',num2str(ii)]);%#ok<AGROW>

            pirelab.getSelectorComp(coreNet,SELR,SELRMulPix(ii),'one-based',{'Index vector (dialog)','Index vector (dialog)'},{1,ii},{'1','1'},'2',['SELR_selector_(1,',num2str(ii),')']);
            pirelab.getSelectorComp(coreNet,SELG,SELGMulPix(ii),'one-based',{'Index vector (dialog)','Index vector (dialog)'},{1,ii},{'1','1'},'2',['SELG_selector_(1,',num2str(ii),')']);
            pirelab.getSelectorComp(coreNet,SELB,SELBMulPix(ii),'one-based',{'Index vector (dialog)','Index vector (dialog)'},{1,ii},{'1','1'},'2',['SELB_selector_(1,',num2str(ii),')']);
        end

        for ii=1:blockInfo.NumPixels
            RMUX(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['RmuxOut_',num2str(ii)]);%#ok<AGROW>
            GMUX(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['GmuxOut_',num2str(ii)]);%#ok<AGROW>
            BMUX(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['BmuxOut_',num2str(ii)]);%#ok<AGROW>

            pirelab.getSwitchComp(coreNet,[bilinearOut1(ii),bilinearOut2(ii),bilinearOut3(ii),bilinearOut4(ii),passThru(ii)],RMUX(ii),SELRMulPix(2-mod(ii,2)));
            pirelab.getSwitchComp(coreNet,[bilinearOut1(ii),bilinearOut2(ii),bilinearOut3(ii),bilinearOut4(ii),passThru(ii)],GMUX(ii),SELGMulPix(2-mod(ii,2)));
            pirelab.getSwitchComp(coreNet,[bilinearOut1(ii),bilinearOut2(ii),bilinearOut3(ii),bilinearOut4(ii),passThru(ii)],BMUX(ii),SELBMulPix(2-mod(ii,2)));
        end
    end

    ConstantZero.SimulinkRate=dataRate;
    ConstantZeroB.SimulinkRate=dataRate;

    pirelab.getConstComp(coreNet,ConstantZero,0);
    pirelab.getConstComp(coreNet,ConstantZeroB,0);




    pirelab.getLogicComp(coreNet,preValid,notValid,'not');

    if blockInfo.NumPixels>1
        pirelab.getMuxComp(coreNet,RMUX(:),RMUXOut);
        pirelab.getMuxComp(coreNet,GMUX(:),GMUXOut);
        pirelab.getMuxComp(coreNet,BMUX(:),BMUXOut);
    end

    pirelab.getUnitDelayComp(coreNet,RMUXOut,RMUXV);
    pirelab.getUnitDelayComp(coreNet,GMUXOut,GMUXV);
    pirelab.getUnitDelayComp(coreNet,BMUXOut,BMUXV);

    pirelab.getSwitchComp(coreNet,[ConstantZero,RMUXV],R,validOut);
    pirelab.getSwitchComp(coreNet,[ConstantZero,GMUXV],G,validOut);
    pirelab.getSwitchComp(coreNet,[ConstantZero,BMUXV],B,validOut);


    pirelab.getIntDelayComp(coreNet,processDataIn,processDataREG,2);
    pirelab.getIntDelayEnabledComp(coreNet,hStartIn,hStartPre,processDataIn,2);
    pirelab.getUnitDelayComp(coreNet,hStartPre,hStartGate);
    pirelab.getSwitchComp(coreNet,[ConstantZeroB,hStartGate],hStartOut,processDataREG);
    pirelab.getIntDelayComp(coreNet,hEndIn,hEndPost,2);
    pirelab.getUnitDelayComp(coreNet,hEndPost,hEndOut);
    pirelab.getIntDelayEnabledComp(coreNet,vStartIn,vStartPre,processDataIn,2);
    pirelab.getUnitDelayComp(coreNet,vStartPre,vStartGate);
    pirelab.getSwitchComp(coreNet,[ConstantZeroB,vStartGate],vStartOut,processDataREG);
    pirelab.getIntDelayComp(coreNet,vEndIn,vEndOut,3);
    pirelab.getIntDelayEnabledResettableComp(coreNet,validIn,preValid,processDataIn,hEndPost,2);
    pirelab.getUnitDelayComp(coreNet,preValid,validGate);
    pirelab.getSwitchComp(coreNet,[ConstantZeroB,validGate],validOut,processDataREG);
