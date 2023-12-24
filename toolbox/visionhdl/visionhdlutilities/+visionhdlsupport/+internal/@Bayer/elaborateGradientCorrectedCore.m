function coreNet=elaborateGradientCorrectedCore(this,topNet,blockInfo,sigInfo,dataRate)

    inType=sigInfo.inType;
    booleanT=sigInfo.booleanT;
    if blockInfo.NumPixels==1
        selT=pir_ufixpt_t(2,0);
    else
        selT=pirelab.createPirArrayType(pir_ufixpt_t(2,0),[1,2]);
        dataRType=sigInfo.dataRType;
    end
    sigInfo.selT=selT;

    inPortNames={'data1','data2','data3','data4','data5','hStartIn','hEndIn','vStartIn','vEndIn','validIn','processDataIn'};
    inPortRates=[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate];
    outPortNames={'R','G','B','hStartOut','hEndOut','vStartOut','vEndOut','validOut'};

    if blockInfo.NumPixels==1
        inPortTypes=[inType,inType,inType,inType,inType,booleanT,booleanT,booleanT,booleanT,booleanT,booleanT];
        outPortTypes=[inType,inType,inType,booleanT,booleanT,booleanT,booleanT,booleanT];
    else
        inPortTypes=[dataRType,dataRType,dataRType,dataRType,dataRType,booleanT,booleanT,booleanT,booleanT,booleanT,booleanT];
        outPortTypes=[dataRType,dataRType,dataRType,booleanT,booleanT,booleanT,booleanT,booleanT];
    end

    coreNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','GradientCorrectedFilterCore',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );


    inSignals=coreNet.PirInputSignals;
    data1In=inSignals(1);
    data2In=inSignals(2);
    data3In=inSignals(3);
    data4In=inSignals(4);
    data5In=inSignals(5);
    hStartIn=inSignals(6);
    hEndIn=inSignals(7);
    vStartIn=inSignals(8);
    vEndIn=inSignals(9);
    validIn=inSignals(10);
    processDataIn=inSignals(11);

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
        data1=coreNet.addSignal2('Type',inType,'Name','data1');
        data2=coreNet.addSignal2('Type',inType,'Name','data2');
        data3=coreNet.addSignal2('Type',inType,'Name','data3');
        data4=coreNet.addSignal2('Type',inType,'Name','data4');
        data5=coreNet.addSignal2('Type',inType,'Name','data5');
        REG1OUT=coreNet.addSignal2('Type',inType,'Name','REG1OUT');
        REG2OUT=coreNet.addSignal2('Type',inType,'Name','REG2OUT');
        REG3OUT=coreNet.addSignal2('Type',inType,'Name','REG3OUT');
        REG4OUT=coreNet.addSignal2('Type',inType,'Name','REG4OUT');
        REG5OUT=coreNet.addSignal2('Type',inType,'Name','REG5OUT');
        REG6OUT=coreNet.addSignal2('Type',inType,'Name','REG6OUT');
        REG7OUT=coreNet.addSignal2('Type',inType,'Name','REG7OUT');
        REG8OUT=coreNet.addSignal2('Type',inType,'Name','REG8OUT');
        REG9OUT=coreNet.addSignal2('Type',inType,'Name','REG9OUT');
        REG10OUT=coreNet.addSignal2('Type',inType,'Name','REG10OUT');
        REG11OUT=coreNet.addSignal2('Type',inType,'Name','REG11OUT');
        REG12OUT=coreNet.addSignal2('Type',inType,'Name','REG12OUT');
        REG13OUT=coreNet.addSignal2('Type',inType,'Name','REG13OUT');
        REG14OUT=coreNet.addSignal2('Type',inType,'Name','REG14OUT');

        pirelab.getUnitDelayEnabledComp(coreNet,data1In,data1,processDataIn,'REG1');
        pirelab.getUnitDelayEnabledComp(coreNet,data1,REG1OUT,processDataIn,'REG1');
        pirelab.getUnitDelayEnabledComp(coreNet,REG1OUT,REG2OUT,processDataIn,'REG2');

        pirelab.getUnitDelayEnabledComp(coreNet,data2In,data2,processDataIn,'REG1');
        pirelab.getUnitDelayEnabledComp(coreNet,data2,REG3OUT,processDataIn,'REG3');
        pirelab.getUnitDelayEnabledComp(coreNet,REG3OUT,REG4OUT,processDataIn,'REG4');
        pirelab.getUnitDelayEnabledComp(coreNet,REG4OUT,REG5OUT,processDataIn,'REG5');

        pirelab.getUnitDelayEnabledComp(coreNet,data3In,data3,processDataIn,'REG1');
        pirelab.getUnitDelayEnabledComp(coreNet,data3,REG6OUT,processDataIn,'REG6');
        pirelab.getUnitDelayEnabledComp(coreNet,REG6OUT,REG7OUT,processDataIn,'REG7');
        pirelab.getUnitDelayEnabledComp(coreNet,REG7OUT,REG8OUT,processDataIn,'REG8');
        pirelab.getUnitDelayEnabledComp(coreNet,REG8OUT,REG9OUT,processDataIn,'REG9');

        pirelab.getUnitDelayEnabledComp(coreNet,data4In,data4,processDataIn,'REG1');
        pirelab.getUnitDelayEnabledComp(coreNet,data4,REG10OUT,processDataIn,'REG10');
        pirelab.getUnitDelayEnabledComp(coreNet,REG10OUT,REG11OUT,processDataIn,'REG11');
        pirelab.getUnitDelayEnabledComp(coreNet,REG11OUT,REG12OUT,processDataIn,'REG12');

        pirelab.getUnitDelayEnabledComp(coreNet,data5In,data5,processDataIn,'REG1');
        pirelab.getUnitDelayEnabledComp(coreNet,data5,REG13OUT,processDataIn,'REG13');
        pirelab.getUnitDelayEnabledComp(coreNet,REG13OUT,REG14OUT,processDataIn,'REG14');
    else
        data1=coreNet.addSignal2('Type',inType,'Name','data1');
        data2=coreNet.addSignal2('Type',inType,'Name','data2');
        data3=coreNet.addSignal2('Type',inType,'Name','data3');
        data4=coreNet.addSignal2('Type',inType,'Name','data4');
        data5=coreNet.addSignal2('Type',inType,'Name','data5');

        pirelab.getUnitDelayEnabledComp(coreNet,data1In,data1,processDataIn,'DataREG1');
        pirelab.getUnitDelayEnabledComp(coreNet,data2In,data2,processDataIn,'DataREG2');
        pirelab.getUnitDelayEnabledComp(coreNet,data3In,data3,processDataIn,'DataREG3');
        pirelab.getUnitDelayEnabledComp(coreNet,data4In,data4,processDataIn,'DataREG4');
        pirelab.getUnitDelayEnabledComp(coreNet,data5In,data5,processDataIn,'DataREG5');

        for ii=1:blockInfo.NumPixels
            data1Split(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['data1Split_',num2str(ii)]);%#ok<AGROW>
            data2Split(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['data2Split_',num2str(ii)]);%#ok<AGROW>
            data3Split(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['data3Split_',num2str(ii)]);%#ok<AGROW>
            data4Split(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['data4Split_',num2str(ii)]);%#ok<AGROW>
            data5Split(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['data5Split_',num2str(ii)]);%#ok<AGROW>

            MulPixREG1(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['MulPixREG1_',num2str(ii)]);%#ok<AGROW>
            MulPixREG2(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['MulPixREG2_',num2str(ii)]);%#ok<AGROW>
            MulPixREG3(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['MulPixREG3_',num2str(ii)]);%#ok<AGROW>
            MulPixREG4(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['MulPixREG4_',num2str(ii)]);%#ok<AGROW>
            MulPixREG5(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['MulPixREG5_',num2str(ii)]);%#ok<AGROW>
            MulPixREG6(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['MulPixREG6_',num2str(ii)]);%#ok<AGROW>
            MulPixREG7(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['MulPixREG7_',num2str(ii)]);%#ok<AGROW>
            MulPixREG8(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['MulPixREG8_',num2str(ii)]);%#ok<AGROW>
            MulPixREG9(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['MulPixREG9_',num2str(ii)]);%#ok<AGROW>
            MulPixREG10(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['MulPixREG10_',num2str(ii)]);%#ok<AGROW>


            pirelab.getSelectorComp(coreNet,data1,data1Split(ii),'one-based',{'Index vector (dialog)','Index vector (dialog)'},{1,ii},{'1','1'},'2',['data1_selector_(1,',num2str(ii),')']);
            pirelab.getSelectorComp(coreNet,data2,data2Split(ii),'one-based',{'Index vector (dialog)','Index vector (dialog)'},{1,ii},{'1','1'},'2',['data2_selector_(1,',num2str(ii),')']);
            pirelab.getSelectorComp(coreNet,data3,data3Split(ii),'one-based',{'Index vector (dialog)','Index vector (dialog)'},{1,ii},{'1','1'},'2',['data3_selector_(1,',num2str(ii),')']);
            pirelab.getSelectorComp(coreNet,data4,data4Split(ii),'one-based',{'Index vector (dialog)','Index vector (dialog)'},{1,ii},{'1','1'},'2',['data4_selector_(1,',num2str(ii),')']);
            pirelab.getSelectorComp(coreNet,data5,data5Split(ii),'one-based',{'Index vector (dialog)','Index vector (dialog)'},{1,ii},{'1','1'},'2',['data5_selector_(1,',num2str(ii),')']);



            pirelab.getUnitDelayEnabledComp(coreNet,data1Split(ii),MulPixREG1(ii),processDataIn,['MulPixREG1_r1d1p',num2str(ii)]);
            pirelab.getUnitDelayEnabledComp(coreNet,MulPixREG1(ii),MulPixREG2(ii),processDataIn,['MulPixREG2_r1d2p',num2str(ii)]);

            pirelab.getUnitDelayEnabledComp(coreNet,data2Split(ii),MulPixREG3(ii),processDataIn,['MulPixREG3_r2d1p',num2str(ii)]);
            pirelab.getUnitDelayEnabledComp(coreNet,MulPixREG3(ii),MulPixREG4(ii),processDataIn,['MulPixREG4_r2d2p',num2str(ii)]);

            pirelab.getUnitDelayEnabledComp(coreNet,data3Split(ii),MulPixREG5(ii),processDataIn,['MulPixREG5_r3d1p',num2str(ii)]);
            pirelab.getUnitDelayEnabledComp(coreNet,MulPixREG5(ii),MulPixREG6(ii),processDataIn,['MulPixREG6_r3d2p',num2str(ii)]);

            pirelab.getUnitDelayEnabledComp(coreNet,data4Split(ii),MulPixREG7(ii),processDataIn,['MulPixREG7_r4d1p',num2str(ii)]);
            pirelab.getUnitDelayEnabledComp(coreNet,MulPixREG7(ii),MulPixREG8(ii),processDataIn,['MulPixREG8_r4d2p',num2str(ii)]);

            pirelab.getUnitDelayEnabledComp(coreNet,data5Split(ii),MulPixREG9(ii),processDataIn,['MulPixREG9_r5d1p',num2str(ii)]);
            pirelab.getUnitDelayEnabledComp(coreNet,MulPixREG9(ii),MulPixREG10(ii),processDataIn,['MulPixREG10_r5d2p',num2str(ii)]);
        end
    end




    dataWriteNet=this.elabDataWrite(coreNet,blockInfo,sigInfo,dataRate);


    REG15OUT=coreNet.addSignal2('Type',booleanT,'Name','REG15OUT');
    REG16OUT=coreNet.addSignal2('Type',booleanT,'Name','REG16OUT');
    REG17OUT=coreNet.addSignal2('Type',booleanT,'Name','REG17OUT');
    REG18OUT=coreNet.addSignal2('Type',booleanT,'Name','REG18OUT');
    REG19OUT=coreNet.addSignal2('Type',booleanT,'Name','REG19OUT');

    preValid=coreNet.addSignal2('Type',booleanT,'Name','preValid');
    processDataInD=coreNet.addSignal2('Type',booleanT,'Name','processDataInD');
    processDataInDU=coreNet.addSignal2('Type',booleanT,'Name','processDataInDU');
    hStartPre=coreNet.addSignal2('Type',booleanT,'Name','hStartPre');
    vStartPre=coreNet.addSignal2('Type',booleanT,'Name','vStartPre');
    endofline=coreNet.addSignal2('Type',booleanT,'Name','endofline');
    endoflineD=coreNet.addSignal2('Type',booleanT,'Name','endoflineD');

    pirelab.getUnitDelayEnabledResettableComp(coreNet,hEndIn,endofline,hEndIn,hEndOut);
    pirelab.getUnitDelayComp(coreNet,endofline,endoflineD);
    pirelab.getLogicComp(coreNet,[processDataIn,endofline],processDataInD,'or');
    pirelab.getUnitDelayComp(coreNet,processDataInD,processDataInDU);

    pirelab.getLogicComp(coreNet,[hStartPre,processDataInDU],REG15OUT,'and');
    pirelab.getIntDelayComp(coreNet,hEndOut,REG16OUT,2);
    pirelab.getLogicComp(coreNet,[vStartPre,processDataInDU],REG17OUT,'and');
    pirelab.getIntDelayComp(coreNet,vEndOut,REG18OUT,2);
    pirelab.getLogicComp(coreNet,[preValid,processDataInDU],REG19OUT,'and');

    dataWriteInput=[REG15OUT,REG16OUT,REG17OUT,REG18OUT,REG19OUT];


    SELR=coreNet.addSignal2('Type',selT,'Name','SELR');
    SELG=coreNet.addSignal2('Type',selT,'Name','SELG');
    SELB=coreNet.addSignal2('Type',selT,'Name','SELB');

    dataWriteOutput=[SELR,SELG,SELB];

    pirelab.instantiateNetwork(coreNet,dataWriteNet,dataWriteInput,dataWriteOutput,'dataWriteController');

    SELRD=coreNet.addSignal2('Type',selT,'Name','SELRD');
    SELGD=coreNet.addSignal2('Type',selT,'Name','SELGD');
    SELBD=coreNet.addSignal2('Type',selT,'Name','SELBD');

    if blockInfo.NumPixels==1
        pirelab.getIntDelayComp(coreNet,SELR,SELRD,2,'REG_SELR');
        pirelab.getIntDelayComp(coreNet,SELG,SELGD,2,'REG_SELG');
        pirelab.getIntDelayComp(coreNet,SELB,SELBD,2,'REG_SELB');
    else
        pirelab.getUnitDelayComp(coreNet,SELR,SELRD);
        pirelab.getUnitDelayComp(coreNet,SELG,SELGD);
        pirelab.getUnitDelayComp(coreNet,SELB,SELBD);
    end


    interpGreenNet=this.elabInterpGreen(coreNet,blockInfo,sigInfo,dataRate);

    if blockInfo.NumPixels==1
        interpGreenIn=[REG2OUT,REG9OUT,REG14OUT,REG7OUT,REG6OUT,REG8OUT,REG4OUT,REG11OUT,data3];

        interpG=coreNet.addSignal2('Type',inType,'Name','interpGreenOut');
        interpGreenOut=interpG;

        pirelab.instantiateNetwork(coreNet,interpGreenNet,interpGreenIn,interpGreenOut,'interpolateGreen');
    elseif blockInfo.NumPixels==2
        for ii=1:blockInfo.NumPixels
            if ii==1

                interpGreenIn=[MulPixREG1(1),MulPixREG6(1),MulPixREG9(1),MulPixREG5(1),MulPixREG5(2),MulPixREG6(2),MulPixREG3(1),MulPixREG7(1),data3Split(1)];
            else

                interpGreenIn=[MulPixREG1(2),MulPixREG6(2),MulPixREG9(2),MulPixREG5(2),data3Split(1),MulPixREG5(1),MulPixREG3(2),MulPixREG7(2),data3Split(2)];
            end
            interpG(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['interpGreenOut_',num2str(ii)]);%#ok<AGROW>
            pirelab.instantiateNetwork(coreNet,interpGreenNet,interpGreenIn,interpG(ii),['interpolateGreen_',num2str(ii)]);
        end
    elseif blockInfo.NumPixels==4||blockInfo.NumPixels==8
        for ii=1:blockInfo.NumPixels

            if ii==1
                interpGreenIn=[MulPixREG1(ii),MulPixREG6(blockInfo.NumPixels-1),MulPixREG9(ii),MulPixREG5(ii),MulPixREG5(ii+1),...
                MulPixREG6(blockInfo.NumPixels),MulPixREG3(ii),MulPixREG7(ii),MulPixREG5(ii+2)];
            elseif ii==2
                interpGreenIn=[MulPixREG1(ii),MulPixREG6(blockInfo.NumPixels),MulPixREG9(ii),MulPixREG5(ii),MulPixREG5(ii+1),...
                MulPixREG5(ii-1),MulPixREG3(ii),MulPixREG7(ii),MulPixREG5(ii+2)];
            elseif ii<blockInfo.NumPixels-1
                interpGreenIn=[MulPixREG1(ii),MulPixREG5(ii-2),MulPixREG9(ii),MulPixREG5(ii),MulPixREG5(ii+1),...
                MulPixREG5(ii-1),MulPixREG3(ii),MulPixREG7(ii),MulPixREG5(ii+2)];
            elseif ii<blockInfo.NumPixels
                interpGreenIn=[MulPixREG1(ii),MulPixREG5(ii-2),MulPixREG9(ii),MulPixREG5(ii),MulPixREG5(ii+1),...
                MulPixREG5(ii-1),MulPixREG3(ii),MulPixREG7(ii),data3Split(1)];
            else
                interpGreenIn=[MulPixREG1(ii),MulPixREG5(ii-2),MulPixREG9(ii),MulPixREG5(ii),data3Split(1),...
                MulPixREG5(ii-1),MulPixREG3(ii),MulPixREG7(ii),data3Split(2)];
            end
            interpG(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['interpGreenOut_',num2str(ii)]);%#ok<AGROW>
            pirelab.instantiateNetwork(coreNet,interpGreenNet,interpGreenIn,interpG(ii),['interpolateGreen_',num2str(ii)]);
        end
    end



    interpRB1Net=this.elabRB1(coreNet,blockInfo,sigInfo,dataRate);

    if blockInfo.NumPixels==1
        interpRB1In=[REG2OUT,REG3OUT,REG5OUT,data3,REG6OUT,REG7OUT,REG8OUT,REG9OUT,REG10OUT,REG12OUT,REG14OUT];

        interpRB1=coreNet.addSignal2('Type',inType,'Name','interpRB1Out');
        interpRB1Out=interpRB1;

        pirelab.instantiateNetwork(coreNet,interpRB1Net,interpRB1In,interpRB1Out,'InterpolateRB1');
    elseif blockInfo.NumPixels==2
        for ii=1:blockInfo.NumPixels
            if ii==1

                interpRB1In=[MulPixREG1(1),MulPixREG3(2),MulPixREG4(2),data3Split(1),MulPixREG5(2),MulPixREG5(1),MulPixREG6(2),MulPixREG6(1),MulPixREG7(2),MulPixREG8(2),MulPixREG9(1)];
            else

                interpRB1In=[MulPixREG1(2),data2Split(1),MulPixREG3(1),data3Split(2),data3Split(1),MulPixREG5(2),MulPixREG5(1),MulPixREG6(2),data4Split(1),MulPixREG7(1),MulPixREG9(2)];
            end
            interpRB1(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['interpRB1Out_',num2str(ii)]);%#ok<AGROW>
            pirelab.instantiateNetwork(coreNet,interpRB1Net,interpRB1In,interpRB1(ii),['InterpolateRB1_',num2str(ii)]);
        end
    elseif blockInfo.NumPixels==4||blockInfo.NumPixels==8
        for ii=1:blockInfo.NumPixels

            if ii==1
                interpRB1In=[MulPixREG1(ii),MulPixREG3(ii+1),MulPixREG4(blockInfo.NumPixels),MulPixREG5(ii+2),MulPixREG5(ii+1),MulPixREG5(ii),...
                MulPixREG6(blockInfo.NumPixels),MulPixREG6(blockInfo.NumPixels-1),MulPixREG7(ii+1),MulPixREG8(blockInfo.NumPixels),MulPixREG9(ii)];
            elseif ii==2
                interpRB1In=[MulPixREG1(ii),MulPixREG3(ii+1),MulPixREG3(ii-1),MulPixREG5(ii+2),MulPixREG5(ii+1),MulPixREG5(ii),...
                MulPixREG5(ii-1),MulPixREG6(blockInfo.NumPixels),MulPixREG7(ii+1),MulPixREG7(ii-1),MulPixREG9(ii)];
            elseif ii<blockInfo.NumPixels-1
                interpRB1In=[MulPixREG1(ii),MulPixREG3(ii+1),MulPixREG3(ii-1),MulPixREG5(ii+2),MulPixREG5(ii+1),MulPixREG5(ii),...
                MulPixREG5(ii-1),MulPixREG5(ii-2),MulPixREG7(ii+1),MulPixREG7(ii-1),MulPixREG9(ii)];
            elseif ii<blockInfo.NumPixels
                interpRB1In=[MulPixREG1(ii),MulPixREG3(ii+1),MulPixREG3(ii-1),data3Split(1),MulPixREG5(ii+1),MulPixREG5(ii),...
                MulPixREG5(ii-1),MulPixREG5(ii-2),MulPixREG7(ii+1),MulPixREG7(ii-1),MulPixREG9(ii)];
            else
                interpRB1In=[MulPixREG1(ii),data2Split(1),MulPixREG3(ii-1),data3Split(2),data3Split(1),MulPixREG5(ii),...
                MulPixREG5(ii-1),MulPixREG5(ii-2),data4Split(1),MulPixREG7(ii-1),MulPixREG9(ii)];
            end
            interpRB1(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['interpRB1Out_',num2str(ii)]);%#ok<AGROW>
            pirelab.instantiateNetwork(coreNet,interpRB1Net,interpRB1In,interpRB1(ii),['InterpolateRB1_',num2str(ii)]);
        end
    end

    interpRB2Net=this.elabRB2(coreNet,blockInfo,sigInfo,dataRate);

    if blockInfo.NumPixels==1
        interpRB2In=[REG2OUT,REG3OUT,REG4OUT,REG5OUT,data3,REG7OUT,REG9OUT,REG10OUT,REG11OUT,REG12OUT,REG14OUT];

        interpRB2=coreNet.addSignal2('Type',inType,'Name','interpRB2Out');
        interpRB2Out=interpRB2;

        pirelab.instantiateNetwork(coreNet,interpRB2Net,interpRB2In,interpRB2Out,'InterpolateRB2');
    elseif blockInfo.NumPixels==2
        for ii=1:blockInfo.NumPixels
            if ii==1

                interpRB2In=[MulPixREG1(1),MulPixREG3(2),MulPixREG3(1),MulPixREG4(2),data3Split(1),MulPixREG5(1),MulPixREG6(1),MulPixREG7(2),MulPixREG7(1),MulPixREG8(2),MulPixREG9(1)];
            else

                interpRB2In=[MulPixREG1(2),data2Split(1),MulPixREG3(2),MulPixREG3(1),data3Split(2),MulPixREG5(2),MulPixREG6(2),data4Split(1),MulPixREG7(2),MulPixREG7(1),MulPixREG9(2)];
            end
            interpRB2(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['interpRB2Out_',num2str(ii)]);%#ok<AGROW>
            pirelab.instantiateNetwork(coreNet,interpRB2Net,interpRB2In,interpRB2(ii),['InterpolateRB2_',num2str(ii)]);
        end
    elseif blockInfo.NumPixels==4||blockInfo.NumPixels==8
        for ii=1:blockInfo.NumPixels

            if ii==1
                interpRB2In=[MulPixREG1(ii),MulPixREG3(ii+1),MulPixREG3(ii),MulPixREG4(blockInfo.NumPixels),MulPixREG5(ii+2),MulPixREG5(ii),...
                MulPixREG6(blockInfo.NumPixels-1),MulPixREG7(ii+1),MulPixREG7(ii),MulPixREG8(blockInfo.NumPixels),MulPixREG9(ii)];
            elseif ii==2
                interpRB2In=[MulPixREG1(ii),MulPixREG3(ii+1),MulPixREG3(ii),MulPixREG3(ii-1),MulPixREG5(ii+2),MulPixREG5(ii),...
                MulPixREG6(blockInfo.NumPixels),MulPixREG7(ii+1),MulPixREG7(ii),MulPixREG7(ii-1),MulPixREG9(ii)];
            elseif ii<blockInfo.NumPixels-1
                interpRB2In=[MulPixREG1(ii),MulPixREG3(ii+1),MulPixREG3(ii),MulPixREG3(ii-1),MulPixREG5(ii+2),MulPixREG5(ii),...
                MulPixREG5(ii-2),MulPixREG7(ii+1),MulPixREG7(ii),MulPixREG7(ii-1),MulPixREG9(ii)];
            elseif ii<blockInfo.NumPixels
                interpRB2In=[MulPixREG1(ii),MulPixREG3(ii+1),MulPixREG3(ii),MulPixREG3(ii-1),data3Split(1),MulPixREG5(ii),...
                MulPixREG5(ii-2),MulPixREG7(ii+1),MulPixREG7(ii),MulPixREG7(ii-1),MulPixREG9(ii)];
            else
                interpRB2In=[MulPixREG1(ii),data2Split(1),MulPixREG3(ii),MulPixREG3(ii-1),data3Split(2),MulPixREG5(ii),...
                MulPixREG5(ii-2),data4Split(1),MulPixREG7(ii),MulPixREG7(ii-1),MulPixREG9(ii)];
            end
            interpRB2(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['interpRB2Out_',num2str(ii)]);%#ok<AGROW>
            pirelab.instantiateNetwork(coreNet,interpRB2Net,interpRB2In,interpRB2(ii),['InterpolateRB2_',num2str(ii)]);
        end
    end


    interpRB3Net=this.elabRB3(coreNet,blockInfo,sigInfo,dataRate);

    if blockInfo.NumPixels==1
        interpRB3In=[REG2OUT,REG3OUT,REG5OUT,data3,REG7OUT,REG9OUT,REG10OUT,REG12OUT,REG14OUT];

        interpRB3=coreNet.addSignal2('Type',inType,'Name','interpRB3Out');
        interpRB3Out=interpRB3;

        pirelab.instantiateNetwork(coreNet,interpRB3Net,interpRB3In,interpRB3Out,'InterpolateRB3');
    elseif blockInfo.NumPixels==2
        for ii=1:blockInfo.NumPixels
            if ii==1

                interpRB3In=[MulPixREG1(1),MulPixREG3(2),MulPixREG4(2),data3Split(1),MulPixREG5(1),MulPixREG6(1),MulPixREG7(2),MulPixREG8(2),MulPixREG9(1)];
            else

                interpRB3In=[MulPixREG1(2),data2Split(1),MulPixREG3(1),data3Split(2),MulPixREG5(2),MulPixREG6(2),data4Split(1),MulPixREG7(1),MulPixREG9(2)];
            end
            interpRB3(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['interpRB3Out_',num2str(ii)]);%#ok<AGROW>
            pirelab.instantiateNetwork(coreNet,interpRB3Net,interpRB3In,interpRB3(ii),['InterpolateRB3_',num2str(ii)]);
        end
    elseif blockInfo.NumPixels==4||blockInfo.NumPixels==8
        for ii=1:blockInfo.NumPixels

            if ii==1
                interpRB3In=[MulPixREG1(ii),MulPixREG3(ii+1),MulPixREG4(blockInfo.NumPixels),MulPixREG5(ii+2),MulPixREG5(ii),...
                MulPixREG6(blockInfo.NumPixels-1),MulPixREG7(ii+1),MulPixREG8(blockInfo.NumPixels),MulPixREG9(ii)];
            elseif ii==2
                interpRB3In=[MulPixREG1(ii),MulPixREG3(ii+1),MulPixREG3(ii-1),MulPixREG5(ii+2),MulPixREG5(ii),...
                MulPixREG6(blockInfo.NumPixels),MulPixREG7(ii+1),MulPixREG7(ii-1),MulPixREG9(ii)];
            elseif ii<blockInfo.NumPixels-1
                interpRB3In=[MulPixREG1(ii),MulPixREG3(ii+1),MulPixREG3(ii-1),MulPixREG5(ii+2),MulPixREG5(ii),...
                MulPixREG5(ii-2),MulPixREG7(ii+1),MulPixREG7(ii-1),MulPixREG9(ii)];
            elseif ii<blockInfo.NumPixels
                interpRB3In=[MulPixREG1(ii),MulPixREG3(ii+1),MulPixREG3(ii-1),data3Split(1),MulPixREG5(ii),...
                MulPixREG5(ii-2),MulPixREG7(ii+1),MulPixREG7(ii-1),MulPixREG9(ii)];
            else
                interpRB3In=[MulPixREG1(ii),data2Split(1),MulPixREG3(ii-1),data3Split(2),MulPixREG5(ii),...
                MulPixREG5(ii-2),data4Split(1),MulPixREG7(ii-1),MulPixREG9(ii)];
            end
            interpRB3(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['interpRB3Out_',num2str(ii)]);%#ok<AGROW>
            pirelab.instantiateNetwork(coreNet,interpRB3Net,interpRB3In,interpRB3(ii),['InterpolateRB3_',num2str(ii)]);
        end
    end

    if blockInfo.NumPixels==1
        passThru=coreNet.addSignal2('Type',inType,'Name','passThrough');
        pirelab.getIntDelayComp(coreNet,REG7OUT,passThru,3,'passThroughREG');
    else
        for ii=1:blockInfo.NumPixels
            passThru(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['passThrough_',num2str(ii)]);%#ok<AGROW>
            pirelab.getIntDelayComp(coreNet,MulPixREG5(ii),passThru(ii),3,['passThroughREG_',num2str(ii)]);
        end
    end


    ConstantZeroB=coreNet.addSignal2('Type',booleanT,'Name','ConstantZero');
    processDataREG=coreNet.addSignal2('Type',booleanT,'Name','processDataREG');
    validGateO=coreNet.addSignal2('Type',booleanT,'Name','validGateO');

    if blockInfo.NumPixels==1
        GMUXOut=coreNet.addSignal2('Type',inType,'Name','GmuxOut');
        RMUXOut=coreNet.addSignal2('Type',inType,'Name','RmuxOut');
        BMUXOut=coreNet.addSignal2('Type',inType,'Name','BmuxOut');
        GMUXV=coreNet.addSignal2('Type',inType,'Name','GmuxV');
        RMUXV=coreNet.addSignal2('Type',inType,'Name','RmuxV');
        BMUXV=coreNet.addSignal2('Type',inType,'Name','BmuxV');
        ConstantZero=coreNet.addSignal2('Type',inType,'Name','ConstantZero');

        pirelab.getSwitchComp(coreNet,[interpG,passThru],GMUXOut,SELGD);
        pirelab.getSwitchComp(coreNet,[interpRB1,interpRB2,interpRB3,passThru],RMUXOut,SELRD);
        pirelab.getSwitchComp(coreNet,[interpRB1,interpRB2,interpRB3,passThru],BMUXOut,SELBD);

    else
        RMUXOut=coreNet.addSignal2('Type',dataRType,'Name','RmuxV');
        GMUXOut=coreNet.addSignal2('Type',dataRType,'Name','GmuxV');
        BMUXOut=coreNet.addSignal2('Type',dataRType,'Name','BmuxV');
        RMUXV=coreNet.addSignal2('Type',dataRType,'Name','RmuxV');
        GMUXV=coreNet.addSignal2('Type',dataRType,'Name','GmuxV');
        BMUXV=coreNet.addSignal2('Type',dataRType,'Name','BmuxV');
        ConstantZero=coreNet.addSignal2('Type',dataRType,'Name','ConstantZero');


        for ii=1:2
            SELRMulPix(ii)=coreNet.addSignal2('Type',selT.BaseType,'Name',['SELRMulPix_P',num2str(ii)]);%#ok<AGROW>
            SELGMulPix(ii)=coreNet.addSignal2('Type',selT.BaseType,'Name',['SELGMulPix_P',num2str(ii)]);%#ok<AGROW>
            SELBMulPix(ii)=coreNet.addSignal2('Type',selT.BaseType,'Name',['SELBMulPix_P',num2str(ii)]);%#ok<AGROW>

            pirelab.getSelectorComp(coreNet,SELRD,SELRMulPix(ii),'one-based',{'Index vector (dialog)','Index vector (dialog)'},{1,ii},{'1','1'},'2',['SELR_selector_(1,',num2str(ii),')']);
            pirelab.getSelectorComp(coreNet,SELGD,SELGMulPix(ii),'one-based',{'Index vector (dialog)','Index vector (dialog)'},{1,ii},{'1','1'},'2',['SELG_selector_(1,',num2str(ii),')']);
            pirelab.getSelectorComp(coreNet,SELBD,SELBMulPix(ii),'one-based',{'Index vector (dialog)','Index vector (dialog)'},{1,ii},{'1','1'},'2',['SELB_selector_(1,',num2str(ii),')']);
        end


        for ii=1:blockInfo.NumPixels
            RMUX(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['RmuxOut_',num2str(ii)]);%#ok<AGROW>
            GMUX(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['GmuxOut_',num2str(ii)]);%#ok<AGROW>
            BMUX(ii)=coreNet.addSignal2('Type',inType.BaseType,'Name',['BmuxOut_',num2str(ii)]);%#ok<AGROW>

            pirelab.getSwitchComp(coreNet,[interpRB1(ii),interpRB2(ii),interpRB3(ii),passThru(ii)],RMUX(ii),SELRMulPix(2-mod(ii,2)));
            pirelab.getSwitchComp(coreNet,[interpG(ii),passThru(ii)],GMUX(ii),SELGMulPix(2-mod(ii,2)));
            pirelab.getSwitchComp(coreNet,[interpRB1(ii),interpRB2(ii),interpRB3(ii),passThru(ii)],BMUX(ii),SELBMulPix(2-mod(ii,2)));
        end
    end

    ConstantZero.SimulinkRate=dataRate;
    ConstantZeroB.SimulinkRate=dataRate;

    pirelab.getConstComp(coreNet,ConstantZero,0);
    pirelab.getConstComp(coreNet,ConstantZeroB,0);


    processDataFlip=coreNet.addSignal2('Type',booleanT,'Name','holdREG');
    processDataFlipD=coreNet.addSignal2('Type',booleanT,'Name','holdREG');

    pirelab.getBitwiseOpComp(coreNet,validIn,processDataFlip,'not');
    pirelab.getIntDelayComp(coreNet,processDataFlip,processDataFlipD,5);


    if blockInfo.NumPixels==1
        pirelab.getUnitDelayComp(coreNet,GMUXOut,GMUXV);
        pirelab.getUnitDelayComp(coreNet,RMUXOut,RMUXV);
        pirelab.getUnitDelayComp(coreNet,BMUXOut,BMUXV);
    else
        pirelab.getMuxComp(coreNet,RMUX(:),RMUXOut);
        pirelab.getMuxComp(coreNet,GMUX(:),GMUXOut);
        pirelab.getMuxComp(coreNet,BMUX(:),BMUXOut);

        pirelab.getIntDelayComp(coreNet,RMUXOut,RMUXV,2,'RMuxOutREG');
        pirelab.getIntDelayComp(coreNet,GMUXOut,GMUXV,2,'GMuxOutREG');
        pirelab.getIntDelayComp(coreNet,BMUXOut,BMUXV,2,'BMuxOutREG');
    end

    pirelab.getSwitchComp(coreNet,[ConstantZero,RMUXV],R,validOut);
    pirelab.getSwitchComp(coreNet,[ConstantZero,GMUXV],G,validOut);
    pirelab.getSwitchComp(coreNet,[ConstantZero,BMUXV],B,validOut);


    hStartGate=coreNet.addSignal2('Type',booleanT,'Name','hStartGate');
    vStartGate=coreNet.addSignal2('Type',booleanT,'Name','vStartGate');
    validGate=coreNet.addSignal2('Type',booleanT,'Name','validGate');
    hEndPost=coreNet.addSignal2('Type',booleanT,'Name','hEndPost');

    pirelab.getIntDelayEnabledComp(coreNet,hStartIn,hStartPre,processDataIn,3);
    pirelab.getIntDelayComp(coreNet,REG15OUT,hStartGate,4);
    pirelab.getWireComp(coreNet,hStartGate,hStartOut);
    pirelab.getIntDelayComp(coreNet,hEndIn,hEndPost,3);
    pirelab.getIntDelayComp(coreNet,hEndPost,hEndOut,4);
    pirelab.getIntDelayEnabledComp(coreNet,vStartIn,vStartPre,processDataIn,3);
    pirelab.getIntDelayComp(coreNet,REG17OUT,vStartGate,4);
    pirelab.getWireComp(coreNet,vStartGate,vStartOut);
    pirelab.getIntDelayComp(coreNet,vEndIn,vEndOut,7);
    pirelab.getIntDelayEnabledComp(coreNet,validIn,preValid,processDataIn,3);
    if blockInfo.NumPixels==1
        pirelab.getUnitDelayComp(coreNet,processDataIn,processDataREG);
    else
        pirelab.getIntDelayComp(coreNet,processDataIn,processDataREG,2);
    end
    pirelab.getLogicComp(coreNet,[preValid,processDataREG],validGateO,'and');
    pirelab.getIntDelayComp(coreNet,validGateO,validGate,4);
    pirelab.getWireComp(coreNet,validGate,validOut);
