function mNet=elabMetricCalculatorNetwork(this,topNet,blockInfo,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    ufix3Type=pir_ufixpt_t(3,0);
    ufix5Type=pir_ufixpt_t(5,0);
    ufix6Type=pir_ufixpt_t(6,0);
    ufix9Type=pir_ufixpt_t(9,0);
    aType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    bc1Type=pir_ufixpt_t(25,0);
    bc2Type=pir_ufixpt_t(blockInfo.betadecmpWL,0);

    aV1Type=pirelab.getPirVectorType(aType,384);
    aV2Type=pirelab.getPirVectorType(aType,blockInfo.memDepth);
    if blockInfo.ScalingFactor==1
        RAMAddr=64/blockInfo.RAMOptFactor;
    else
        RAMAddr=64;
    end
    uVType=pirelab.getPirVectorType(ufix1Type,RAMAddr);
    uV1Type=pirelab.getPirVectorType(ufix1Type,384);

    if blockInfo.RAMOptimize&&blockInfo.ScalingFactor==1
        wrDataType=pir_ufixpt_t(blockInfo.RAMOptFactor*blockInfo.alphaWL,0);
        colDataType=pir_ufixpt_t(blockInfo.alphaWL,0);
    else
        wrDataType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
        colDataType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    end
    wrDataVType=pirelab.getPirVectorType(wrDataType,RAMAddr);
    colDataVType=pirelab.getPirVectorType(colDataType,64);

    bc1VType_1=pirelab.getPirVectorType(bc1Type,blockInfo.memDepth);
    bc2VType_1=pirelab.getPirVectorType(bc2Type,blockInfo.memDepth);

    bc1VType_2=pirelab.getPirVectorType(bc1Type,384);
    bc2VType_2=pirelab.getPirVectorType(bc2Type,384);



    if blockInfo.VectorSize==64
        mNet=pirelab.createNewNetwork(...
        'Network',topNet,...
        'Name','MetricCalculator',...
        'Inportnames',{'data','valid','countlayer','enable','count','reset','validreg'},...
        'InportTypes',[aV1Type,ufix1Type,ufix6Type,ufix1Type,ufix5Type,ufix1Type,ufix1Type],...
        'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
        'Outportnames',{'gamma','valid',},...
        'OutportTypes',[aV2Type,ufix1Type]...
        );


        data=mNet.PirInputSignals(1);
        valid=mNet.PirInputSignals(2);
        countlayer=mNet.PirInputSignals(3);
        enable=mNet.PirInputSignals(4);
        count=mNet.PirInputSignals(5);
        reset=mNet.PirInputSignals(6);
        validEnb=mNet.PirInputSignals(7);
    else
        mNet=pirelab.createNewNetwork(...
        'Network',topNet,...
        'Name','MetricCalculator',...
        'Inportnames',{'data','liftsize','shift','valid','countlayer','enable','count','reset','funcenb','iterdone','validreg'},...
        'InportTypes',[aV1Type,ufix9Type,ufix9Type,ufix1Type,ufix6Type,ufix1Type,ufix5Type,ufix1Type,ufix1Type,ufix1Type,ufix1Type],...
        'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
        'Outportnames',{'gamma','valid',},...
        'OutportTypes',[aV2Type,ufix1Type]...
        );


        data=mNet.PirInputSignals(1);
        liftsize=mNet.PirInputSignals(2);
        shift=mNet.PirInputSignals(3);
        valid=mNet.PirInputSignals(4);
        countlayer=mNet.PirInputSignals(5);
        enable=mNet.PirInputSignals(6);
        count=mNet.PirInputSignals(7);
        reset=mNet.PirInputSignals(8);
        funcenb=mNet.PirInputSignals(9);
        iterdone=mNet.PirInputSignals(10);
        validEnb=mNet.PirInputSignals(11);

        shift_dtc=mNet.addSignal(ufix9Type,'shiftDTC');
        pirelab.getDTCComp(mNet,shift,shift_dtc,'Floor','Wrap','SI');

    end

    gamma=mNet.PirOutputSignals(1);
    validout=mNet.PirOutputSignals(2);

    sdata=mNet.addSignal(data.Type,'shift_data');
    svalid=mNet.addSignal(ufix1Type,'shift_valid');

    cdecomp1=mNet.addSignal(bc1VType_1,'betaDecomp1');
    bdecomp1=mNet.addSignal(bc1VType_1,'cnuDecomp1');

    cdecomp2=mNet.addSignal(bc2VType_1,'betaDecomp2');
    bdecomp2=mNet.addSignal(bc2VType_1,'cnuDecomp2');

    cvalid=mNet.addSignal(ufix1Type,'betaValid');
    bvalid=mNet.addSignal(ufix1Type,'cnuValid');

    reset_reg=mNet.addSignal(ufix1Type,'resetReg');
    pirelab.getUnitDelayComp(mNet,reset,reset_reg,'',0);

    betacomp1_reg=mNet.addSignal(bc1VType_1,'cnuDecomp1Reg');
    betacomp2_reg=mNet.addSignal(bc2VType_1,'cnuDecomp2Reg');
    bvalid_reg=mNet.addSignal(ufix1Type,'cnuValidReg');

    cdecomp1_mem=mNet.addSignal(bc1VType_2,'cDecomp1Mem');
    cdecomp2_mem=mNet.addSignal(bc2VType_2,'cDecomp2Mem');

    betacomp1_mem=mNet.addSignal(bc1VType_2,'bDecomp1Mem');
    betacomp2_mem=mNet.addSignal(bc2VType_2,'bDecomp2Mem');

    if blockInfo.VectorSize==64

        valid_reg=mNet.addSignal(ufix1Type,'validReg');
        pirelab.getUnitDelayComp(mNet,validEnb,valid_reg,'',0);

        valid_regN=mNet.addSignal(ufix1Type,'validRegN');
        pirelab.getLogicComp(mNet,valid_reg,valid_regN,'not');

        validN=mNet.addSignal(ufix1Type,'validN');
        rdenb=mNet.addSignal(ufix1Type,'readEnable');

        rdenb_reg=mNet.addSignal(ufix1Type,'readEnableReg');

        pirelab.getLogicComp(mNet,[valid_regN,validEnb],validN,'and');
        pirelab.getLogicComp(mNet,[validN,enable],rdenb,'and');

        pirelab.getUnitDelayComp(mNet,rdenb,rdenb_reg,'rdEnb',0);



        fNet=this.elabFunctionalUnitNetwork(mNet,blockInfo,dataRate);
        fNet.addComment('Functional_Unit');
        pirelab.instantiateNetwork(mNet,fNet,[data,valid,count,...
        cdecomp1_mem,cdecomp2_mem,cvalid,reset_reg],[gamma,validout,bdecomp1,...
        bdecomp2,bvalid],'Functional_Unit');

        pirelab.getIntDelayComp(mNet,bdecomp1,betacomp1_mem,1,'',0);
        pirelab.getIntDelayComp(mNet,bdecomp2,betacomp2_mem,1,'',0);
        pirelab.getIntDelayComp(mNet,bvalid,bvalid_reg,2,'',0);



        bmNet=this.elabBetaMemoryNetwork(mNet,blockInfo,dataRate);
        bmNet.addComment('BetaMemory');
        pirelab.instantiateNetwork(mNet,bmNet,[betacomp1_mem,betacomp2_mem,countlayer,rdenb_reg,bvalid_reg],...
        [cdecomp1_mem,cdecomp2_mem,cvalid],'BetaMemory');
    else



        cNet=this.elabSerialCircularShifterNetwork(mNet,blockInfo,dataRate);
        cNet.addComment('Circular_Shifter_Unit');
        pirelab.instantiateNetwork(mNet,cNet,[data,liftsize,shift_dtc,valid,count,iterdone],...
        [sdata,svalid],'Circular_Shifter_Unit');

        data1=mNet.addSignal(wrDataVType,'wrData1');
        data2=mNet.addSignal(wrDataVType,'wrData2');
        data3=mNet.addSignal(wrDataVType,'wrData3');
        data4=mNet.addSignal(wrDataVType,'wrData4');
        data5=mNet.addSignal(wrDataVType,'wrData5');
        data6=mNet.addSignal(wrDataVType,'wrData6');
        wren1=mNet.addSignal(uVType,'wrEnb1');
        wren2=mNet.addSignal(uVType,'wrEnb2');
        wren3=mNet.addSignal(uVType,'wrEnb3');
        wren4=mNet.addSignal(uVType,'wrEnb4');
        wren5=mNet.addSignal(uVType,'wrEnb5');
        wren6=mNet.addSignal(uVType,'wrEnb6');

        wraddr=mNet.addSignal(ufix5Type,'wrAddr');
        rdaddr=mNet.addSignal(ufix5Type,'rdAddr');
        selbank=mNet.addSignal(ufix3Type,'selBank');
        validreg=mNet.addSignal(ufix1Type,'validReg');
        validtrig=mNet.addSignal(ufix1Type,'validTrig');

        bankout1=mNet.addSignal(aV2Type,'bankData1');
        bankout2=mNet.addSignal(aV2Type,'bankData2');
        bankout3=mNet.addSignal(aV2Type,'bankData3');
        bankout4=mNet.addSignal(aV2Type,'bankData4');
        bankout5=mNet.addSignal(aV2Type,'bankData5');
        bankout6=mNet.addSignal(aV2Type,'bankData6');

        bankout1_dtc=mNet.addSignal(colDataVType,'bankData1DTC');
        bankout2_dtc=mNet.addSignal(colDataVType,'bankData2DTC');
        bankout3_dtc=mNet.addSignal(colDataVType,'bankData3DTC');
        bankout4_dtc=mNet.addSignal(colDataVType,'bankData4DTC');
        bankout5_dtc=mNet.addSignal(colDataVType,'bankData5DTC');
        bankout6_dtc=mNet.addSignal(colDataVType,'bankData6DTC');

        sdata_reg=mNet.addSignal(sdata.Type,'sDataReg');
        svalid_reg=mNet.addSignal(svalid.Type,'sValidRef');

        pirelab.getUnitDelayComp(mNet,sdata,sdata_reg,'',0);
        pirelab.getUnitDelayComp(mNet,svalid,svalid_reg,'',0);


        RAMOptimize=blockInfo.RAMOptimize;
        RAMOptFactor=blockInfo.RAMOptFactor;
        alphaWL=blockInfo.alphaWL;
        alphaFL=-blockInfo.alphaFL;

        fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
        '+nrhdlsupport','+internal','@LDPCDecoder','cgireml','functionalInputController.m'),'r');
        functionalInputController=fread(fid,Inf,'char=>char');
        fclose(fid);

        mNet.addComponent2(...
        'kind','cgireml',...
        'Name','functionalInputController',...
        'InputSignals',[sdata_reg,svalid_reg,liftsize,count,reset,funcenb],...
        'OutputSignals',[data1,rdaddr,wren1,data2,wraddr,wren2,data3,wren3,data4,wren4,data5,wren5,data6,wren6,selbank,validreg,validtrig],...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','functionalInputController',...
        'EMLFileBody',functionalInputController,...
        'EmlParams',{RAMOptimize,RAMOptFactor,alphaWL,alphaFL},...
        'EMLFlag_TreatInputIntsAsFixpt',true);

        data1_array=this.demuxSignal(mNet,data1,'data1_array');
        data2_array=this.demuxSignal(mNet,data2,'data2_array');
        data3_array=this.demuxSignal(mNet,data3,'data3_array');
        data4_array=this.demuxSignal(mNet,data4,'data4_array');
        data5_array=this.demuxSignal(mNet,data5,'data5_array');
        data6_array=this.demuxSignal(mNet,data6,'data6_array');
        wren1_array=this.demuxSignal(mNet,wren1,'wren1_array');
        wren2_array=this.demuxSignal(mNet,wren2,'wren2_array');
        wren3_array=this.demuxSignal(mNet,wren3,'wren3_array');
        wren4_array=this.demuxSignal(mNet,wren4,'wren4_array');
        wren5_array=this.demuxSignal(mNet,wren5,'wren5_array');
        wren6_array=this.demuxSignal(mNet,wren6,'wren6_array');

        for idx=1:RAMAddr
            if blockInfo.RAMOptimize&&blockInfo.ScalingFactor==1
                coldata1_array(idx)=mNet.addSignal(wrDataType,['coldata1_array_',num2str(idx)]);%#ok<*AGROW>
                coldata2_array(idx)=mNet.addSignal(wrDataType,['coldata2_array_',num2str(idx)]);%#ok<*AGROW>
                coldata3_array(idx)=mNet.addSignal(wrDataType,['coldata3_array_',num2str(idx)]);%#ok<*AGROW>
                coldata4_array(idx)=mNet.addSignal(wrDataType,['coldata4_array_',num2str(idx)]);%#ok<*AGROW>
                coldata5_array(idx)=mNet.addSignal(wrDataType,['coldata5_array_',num2str(idx)]);%#ok<*AGROW>
                coldata6_array(idx)=mNet.addSignal(wrDataType,['coldata6_array_',num2str(idx)]);%#ok<*AGROW>

                pirelab.getSimpleDualPortRamComp(mNet,[data1_array(idx),wraddr,wren1_array(idx),rdaddr],coldata1_array(idx),'PF RAM1',1,-1,[],'','',blockInfo.ramAttr_block);
                pirelab.getSimpleDualPortRamComp(mNet,[data2_array(idx),wraddr,wren2_array(idx),rdaddr],coldata2_array(idx),'PF RAM2',1,-1,[],'','',blockInfo.ramAttr_block);
                pirelab.getSimpleDualPortRamComp(mNet,[data3_array(idx),wraddr,wren3_array(idx),rdaddr],coldata3_array(idx),'PF RAM3',1,-1,[],'','',blockInfo.ramAttr_block);
                pirelab.getSimpleDualPortRamComp(mNet,[data4_array(idx),wraddr,wren4_array(idx),rdaddr],coldata4_array(idx),'PF RAM4',1,-1,[],'','',blockInfo.ramAttr_block);
                pirelab.getSimpleDualPortRamComp(mNet,[data5_array(idx),wraddr,wren5_array(idx),rdaddr],coldata5_array(idx),'PF RAM5',1,-1,[],'','',blockInfo.ramAttr_block);
                pirelab.getSimpleDualPortRamComp(mNet,[data6_array(idx),wraddr,wren6_array(idx),rdaddr],coldata6_array(idx),'PF RAM6',1,-1,[],'','',blockInfo.ramAttr_block);



                bank1_array((idx-1)*4+1)=mNet.addSignal(colDataType,['bank1_array_',num2str((idx-1)*4+1)]);%#ok<*AGROW>
                bank1_array((idx-1)*4+2)=mNet.addSignal(colDataType,['bank1_array_',num2str((idx-1)*4+2)]);%#ok<*AGROW>
                bank1_array((idx-1)*4+3)=mNet.addSignal(colDataType,['bank1_array_',num2str((idx-1)*4+3)]);%#ok<*AGROW>
                bank1_array((idx-1)*4+4)=mNet.addSignal(colDataType,['bank1_array_',num2str((idx-1)*4+4)]);%#ok<*AGROW>

                pirelab.getBitSliceComp(mNet,coldata1_array(idx),bank1_array((idx-1)*4+1),4*alphaWL-1,3*alphaWL,'ext1');
                pirelab.getBitSliceComp(mNet,coldata1_array(idx),bank1_array((idx-1)*4+2),3*alphaWL-1,2*alphaWL,'ext2');
                pirelab.getBitSliceComp(mNet,coldata1_array(idx),bank1_array((idx-1)*4+3),2*alphaWL-1,alphaWL,'ext3');
                pirelab.getBitSliceComp(mNet,coldata1_array(idx),bank1_array((idx-1)*4+4),alphaWL-1,0,'ext4');

                bank2_array((idx-1)*4+1)=mNet.addSignal(colDataType,['bank2_array_',num2str((idx-1)*4+1)]);%#ok<*AGROW>
                bank2_array((idx-1)*4+2)=mNet.addSignal(colDataType,['bank2_array_',num2str((idx-1)*4+2)]);%#ok<*AGROW>
                bank2_array((idx-1)*4+3)=mNet.addSignal(colDataType,['bank2_array_',num2str((idx-1)*4+3)]);%#ok<*AGROW>
                bank2_array((idx-1)*4+4)=mNet.addSignal(colDataType,['bank2_array_',num2str((idx-1)*4+4)]);%#ok<*AGROW>

                pirelab.getBitSliceComp(mNet,coldata2_array(idx),bank2_array((idx-1)*4+1),4*alphaWL-1,3*alphaWL,'ext1');
                pirelab.getBitSliceComp(mNet,coldata2_array(idx),bank2_array((idx-1)*4+2),3*alphaWL-1,2*alphaWL,'ext2');
                pirelab.getBitSliceComp(mNet,coldata2_array(idx),bank2_array((idx-1)*4+3),2*alphaWL-1,alphaWL,'ext3');
                pirelab.getBitSliceComp(mNet,coldata2_array(idx),bank2_array((idx-1)*4+4),alphaWL-1,0,'ext4');

                bank3_array((idx-1)*4+1)=mNet.addSignal(colDataType,['bank3_array_',num2str((idx-1)*4+1)]);%#ok<*AGROW>
                bank3_array((idx-1)*4+2)=mNet.addSignal(colDataType,['bank3_array_',num2str((idx-1)*4+2)]);%#ok<*AGROW>
                bank3_array((idx-1)*4+3)=mNet.addSignal(colDataType,['bank3_array_',num2str((idx-1)*4+3)]);%#ok<*AGROW>
                bank3_array((idx-1)*4+4)=mNet.addSignal(colDataType,['bank3_array_',num2str((idx-1)*4+4)]);%#ok<*AGROW>

                pirelab.getBitSliceComp(mNet,coldata3_array(idx),bank3_array((idx-1)*4+1),4*alphaWL-1,3*alphaWL,'ext1');
                pirelab.getBitSliceComp(mNet,coldata3_array(idx),bank3_array((idx-1)*4+2),3*alphaWL-1,2*alphaWL,'ext2');
                pirelab.getBitSliceComp(mNet,coldata3_array(idx),bank3_array((idx-1)*4+3),2*alphaWL-1,alphaWL,'ext3');
                pirelab.getBitSliceComp(mNet,coldata3_array(idx),bank3_array((idx-1)*4+4),alphaWL-1,0,'ext4');

                bank4_array((idx-1)*4+1)=mNet.addSignal(colDataType,['bank4_array_',num2str((idx-1)*4+1)]);%#ok<*AGROW>
                bank4_array((idx-1)*4+2)=mNet.addSignal(colDataType,['bank4_array_',num2str((idx-1)*4+2)]);%#ok<*AGROW>
                bank4_array((idx-1)*4+3)=mNet.addSignal(colDataType,['bank4_array_',num2str((idx-1)*4+3)]);%#ok<*AGROW>
                bank4_array((idx-1)*4+4)=mNet.addSignal(colDataType,['bank4_array_',num2str((idx-1)*4+4)]);%#ok<*AGROW>

                pirelab.getBitSliceComp(mNet,coldata4_array(idx),bank4_array((idx-1)*4+1),4*alphaWL-1,3*alphaWL,'ext1');
                pirelab.getBitSliceComp(mNet,coldata4_array(idx),bank4_array((idx-1)*4+2),3*alphaWL-1,2*alphaWL,'ext2');
                pirelab.getBitSliceComp(mNet,coldata4_array(idx),bank4_array((idx-1)*4+3),2*alphaWL-1,alphaWL,'ext3');
                pirelab.getBitSliceComp(mNet,coldata4_array(idx),bank4_array((idx-1)*4+4),alphaWL-1,0,'ext4');

                bank5_array((idx-1)*4+1)=mNet.addSignal(colDataType,['bank5_array_',num2str((idx-1)*4+1)]);%#ok<*AGROW>
                bank5_array((idx-1)*4+2)=mNet.addSignal(colDataType,['bank5_array_',num2str((idx-1)*4+2)]);%#ok<*AGROW>
                bank5_array((idx-1)*4+3)=mNet.addSignal(colDataType,['bank5_array_',num2str((idx-1)*4+3)]);%#ok<*AGROW>
                bank5_array((idx-1)*4+4)=mNet.addSignal(colDataType,['bank5_array_',num2str((idx-1)*4+4)]);%#ok<*AGROW>

                pirelab.getBitSliceComp(mNet,coldata5_array(idx),bank5_array((idx-1)*4+1),4*alphaWL-1,3*alphaWL,'ext1');
                pirelab.getBitSliceComp(mNet,coldata5_array(idx),bank5_array((idx-1)*4+2),3*alphaWL-1,2*alphaWL,'ext2');
                pirelab.getBitSliceComp(mNet,coldata5_array(idx),bank5_array((idx-1)*4+3),2*alphaWL-1,alphaWL,'ext3');
                pirelab.getBitSliceComp(mNet,coldata5_array(idx),bank5_array((idx-1)*4+4),alphaWL-1,0,'ext4');

                bank6_array((idx-1)*4+1)=mNet.addSignal(colDataType,['bank6_array_',num2str((idx-1)*4+1)]);%#ok<*AGROW>
                bank6_array((idx-1)*4+2)=mNet.addSignal(colDataType,['bank6_array_',num2str((idx-1)*4+2)]);%#ok<*AGROW>
                bank6_array((idx-1)*4+3)=mNet.addSignal(colDataType,['bank6_array_',num2str((idx-1)*4+3)]);%#ok<*AGROW>
                bank6_array((idx-1)*4+4)=mNet.addSignal(colDataType,['bank6_array_',num2str((idx-1)*4+4)]);%#ok<*AGROW>

                pirelab.getBitSliceComp(mNet,coldata6_array(idx),bank6_array((idx-1)*4+1),4*alphaWL-1,3*alphaWL,'ext1');
                pirelab.getBitSliceComp(mNet,coldata6_array(idx),bank6_array((idx-1)*4+2),3*alphaWL-1,2*alphaWL,'ext2');
                pirelab.getBitSliceComp(mNet,coldata6_array(idx),bank6_array((idx-1)*4+3),2*alphaWL-1,alphaWL,'ext3');
                pirelab.getBitSliceComp(mNet,coldata6_array(idx),bank6_array((idx-1)*4+4),alphaWL-1,0,'ext4');

            else
                bank1_array(idx)=mNet.addSignal(aType,['bank1_array_',num2str(idx)]);%#ok<*AGROW>
                bank2_array(idx)=mNet.addSignal(aType,['bank2_array_',num2str(idx)]);%#ok<*AGROW>
                bank3_array(idx)=mNet.addSignal(aType,['bank3_array_',num2str(idx)]);%#ok<*AGROW>
                bank4_array(idx)=mNet.addSignal(aType,['bank4_array_',num2str(idx)]);%#ok<*AGROW>
                bank5_array(idx)=mNet.addSignal(aType,['bank5_array_',num2str(idx)]);%#ok<*AGROW>
                bank6_array(idx)=mNet.addSignal(aType,['bank6_array_',num2str(idx)]);%#ok<*AGROW>

                pirelab.getSimpleDualPortRamComp(mNet,[data1_array(idx),wraddr,wren1_array(idx),rdaddr],bank1_array(idx),'PF RAM1',1,-1,[],'','',blockInfo.ramAttr_dist);
                pirelab.getSimpleDualPortRamComp(mNet,[data2_array(idx),wraddr,wren2_array(idx),rdaddr],bank2_array(idx),'PF RAM2',1,-1,[],'','',blockInfo.ramAttr_dist);
                pirelab.getSimpleDualPortRamComp(mNet,[data3_array(idx),wraddr,wren3_array(idx),rdaddr],bank3_array(idx),'PF RAM3',1,-1,[],'','',blockInfo.ramAttr_dist);
                pirelab.getSimpleDualPortRamComp(mNet,[data4_array(idx),wraddr,wren4_array(idx),rdaddr],bank4_array(idx),'PF RAM4',1,-1,[],'','',blockInfo.ramAttr_dist);
                pirelab.getSimpleDualPortRamComp(mNet,[data5_array(idx),wraddr,wren5_array(idx),rdaddr],bank5_array(idx),'PF RAM5',1,-1,[],'','',blockInfo.ramAttr_dist);
                pirelab.getSimpleDualPortRamComp(mNet,[data6_array(idx),wraddr,wren6_array(idx),rdaddr],bank6_array(idx),'PF RAM6',1,-1,[],'','',blockInfo.ramAttr_dist);

            end
        end

        this.muxSignal(mNet,bank1_array,bankout1_dtc);
        pirelab.getDTCComp(mNet,bankout1_dtc,bankout1,'Floor','Wrap','SI');
        this.muxSignal(mNet,bank2_array,bankout2_dtc);
        pirelab.getDTCComp(mNet,bankout2_dtc,bankout2,'Floor','Wrap','SI');
        this.muxSignal(mNet,bank3_array,bankout3_dtc);
        pirelab.getDTCComp(mNet,bankout3_dtc,bankout3,'Floor','Wrap','SI');
        this.muxSignal(mNet,bank4_array,bankout4_dtc);
        pirelab.getDTCComp(mNet,bankout4_dtc,bankout4,'Floor','Wrap','SI');
        this.muxSignal(mNet,bank5_array,bankout5_dtc);
        pirelab.getDTCComp(mNet,bankout5_dtc,bankout5,'Floor','Wrap','SI');
        this.muxSignal(mNet,bank6_array,bankout6_dtc);
        pirelab.getDTCComp(mNet,bankout6_dtc,bankout6,'Floor','Wrap','SI');

        x=[bankout1,bankout1,bankout2,bankout3,bankout4,bankout5,bankout6];
        fundata=mNet.addSignal(aV2Type,'funcData');
        pirelab.getMultiPortSwitchComp(mNet,[selbank,x],fundata,1,1,'Floor','Wrap');


        fid1=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
        '+nrhdlsupport','+internal','@LDPCDecoder','cgireml','betaMemoryInputController.m'),'r');
        betaMemoryInputController=fread(fid1,Inf,'char=>char');
        fclose(fid1);

        bvalid_regd=mNet.addSignal(uV1Type,'cnuValidRegD');

        mNet.addComponent2(...
        'kind','cgireml',...
        'Name','betaMemoryInputController',...
        'InputSignals',[betacomp1_reg,betacomp2_reg,bvalid_reg,selbank],...
        'OutputSignals',[betacomp1_mem,betacomp2_mem,bvalid_regd],...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','betaMemoryInputController',...
        'EMLFileBody',betaMemoryInputController,...
        'EMLFlag_TreatInputIntsAsFixpt',true);

        valid_reg=mNet.addSignal(ufix1Type,'validReg');
        pirelab.getUnitDelayComp(mNet,validtrig,valid_reg,'',0);

        valid_regN=mNet.addSignal(ufix1Type,'validRegN');
        pirelab.getLogicComp(mNet,valid_reg,valid_regN,'not');

        rdenb_tmp=mNet.addSignal(ufix1Type,'rdEnbTmp');
        pirelab.getLogicComp(mNet,[valid_regN,validtrig],rdenb_tmp,'and');

        rdenb=mNet.addSignal(ufix1Type,'readEnable');
        pirelab.getLogicComp(mNet,[rdenb_tmp,enable],rdenb,'and');



        bmNet=this.elabBetaMemoryNetwork(mNet,blockInfo,dataRate);
        bmNet.addComment('BetaMemory');
        pirelab.instantiateNetwork(mNet,bmNet,[betacomp1_mem,betacomp2_mem,countlayer,rdenb,bvalid_regd],...
        [cdecomp1_mem,cdecomp2_mem,cvalid],'BetaMemory');

        fid2=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
        '+nrhdlsupport','+internal','@LDPCDecoder','cgireml','betaMemoryOutputController.m'),'r');
        betaMemoryOutputController=fread(fid2,Inf,'char=>char');
        fclose(fid2);

        cdecomp1_1=mNet.addSignal(bc1VType_1,'bDecomp1_1');
        cdecomp2_1=mNet.addSignal(bc2VType_1,'bDecomp2_1');
        cdecomp1_2=mNet.addSignal(bc1VType_1,'bDecomp1_2');
        cdecomp2_2=mNet.addSignal(bc2VType_1,'bDecomp2_2');
        cdecomp1_3=mNet.addSignal(bc1VType_1,'bDecomp1_3');
        cdecomp2_3=mNet.addSignal(bc2VType_1,'bDecomp2_3');
        cdecomp1_4=mNet.addSignal(bc1VType_1,'bDecomp1_4');
        cdecomp2_4=mNet.addSignal(bc2VType_1,'bDecomp2_4');
        cdecomp1_5=mNet.addSignal(bc1VType_1,'bDecomp1_5');
        cdecomp2_5=mNet.addSignal(bc2VType_1,'bDecomp2_5');
        cdecomp1_6=mNet.addSignal(bc1VType_1,'bDecomp1_6');
        cdecomp2_6=mNet.addSignal(bc2VType_1,'bDecomp2_7');

        mNet.addComponent2(...
        'kind','cgireml',...
        'Name','betaMemoryOutputController',...
        'InputSignals',[cdecomp1_mem,cdecomp2_mem],...
        'OutputSignals',[cdecomp1_1,cdecomp1_2,cdecomp1_3,cdecomp1_4,cdecomp1_5,cdecomp1_6,cdecomp2_1,cdecomp2_2,cdecomp2_3,cdecomp2_4,cdecomp2_5,cdecomp2_6],...
        'ExternalSynchronousResetSignal','',...
        'EMLFileName','betaMemoryOutputController',...
        'EMLFileBody',betaMemoryOutputController,...
        'EMLFlag_TreatInputIntsAsFixpt',true);

        x1=[cdecomp1_1,cdecomp1_1,cdecomp1_2,cdecomp1_3,cdecomp1_4,cdecomp1_5,cdecomp1_6];
        pirelab.getMultiPortSwitchComp(mNet,[selbank,x1],cdecomp1,1,1,'Floor','Wrap');

        x2=[cdecomp2_1,cdecomp2_1,cdecomp2_2,cdecomp2_3,cdecomp2_4,cdecomp2_5,cdecomp2_6];
        pirelab.getMultiPortSwitchComp(mNet,[selbank,x2],cdecomp2,1,1,'Floor','Wrap');

        cvalid_reg=mNet.addSignal(ufix1Type,'cValidReg');
        cvalid_tmp1=mNet.addSignal(ufix1Type,'cValidTmp1');
        cvalid_tmp2=mNet.addSignal(ufix1Type,'cValidTmp2');

        pirelab.getUnitDelayEnabledResettableComp(mNet,rdenb,cvalid_tmp2,rdenb,reset_reg,'enableOut',0);

        pirelab.getLogicComp(mNet,[cvalid,funcenb],cvalid_tmp1,'or');
        pirelab.getLogicComp(mNet,[cvalid_tmp1,cvalid_tmp2],cvalid_reg,'and');

        cvalid_reg1=mNet.addSignal(ufix1Type,'cValidReg1');
        pirelab.getUnitDelayComp(mNet,cvalid_reg,cvalid_reg1,'c_valid',0);



        fNet=this.elabFunctionalUnitNetwork(mNet,blockInfo,dataRate);
        fNet.addComment('Functional_Unit');
        pirelab.instantiateNetwork(mNet,fNet,[fundata,validreg,count,...
        cdecomp1,cdecomp2,cvalid_reg1,reset_reg],[gamma,validout,bdecomp1,...
        bdecomp2,bvalid],'Functional_Unit');

        pirelab.getIntDelayComp(mNet,bdecomp1,betacomp1_reg,2,'',0);
        pirelab.getIntDelayComp(mNet,bdecomp2,betacomp2_reg,2,'',0);
        pirelab.getIntDelayComp(mNet,bvalid,bvalid_reg,2,'',0);

    end

end
