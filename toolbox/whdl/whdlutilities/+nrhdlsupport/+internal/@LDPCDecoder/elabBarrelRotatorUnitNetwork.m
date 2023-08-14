function brNet=elabBarrelRotatorUnitNetwork(this,topNet,blockInfo,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    vType=pir_ufixpt_t(9,0);

    sType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    sVType=pirelab.getPirVectorType(sType,384);
    sV1Type=pirelab.getPirVectorType(sType,384);


    brNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','BarrelRotator',...
    'Inportnames',{'data','shift'},...
    'InportTypes',[sVType,vType],...
    'InportRates',[dataRate,dataRate],...
    'Outportnames',{'shiftData'},...
    'OutportTypes',sV1Type...
    );

    data=brNet.PirInputSignals(1);
    shift=brNet.PirInputSignals(2);

    sdata=brNet.PirOutputSignals(1);


    vshift_1=brNet.addSignal(ufix1Type,'vShift1');
    vshift_2=brNet.addSignal(ufix1Type,'vShift2');
    vshift_3=brNet.addSignal(ufix1Type,'vShift3');
    vshift_4=brNet.addSignal(ufix1Type,'vShift4');
    vshift_5=brNet.addSignal(ufix1Type,'vShift5');
    vshift_6=brNet.addSignal(ufix1Type,'vShift6');
    vshift_7=brNet.addSignal(ufix1Type,'vShift7');
    vshift_8=brNet.addSignal(ufix1Type,'vShift8');
    vshift_9=brNet.addSignal(ufix1Type,'vShift9');
    pirelab.getBitSliceComp(brNet,shift,vshift_1,0,0,'bitextract1');
    pirelab.getBitSliceComp(brNet,shift,vshift_2,1,1,'bitextract2');
    pirelab.getBitSliceComp(brNet,shift,vshift_3,2,2,'bitextract3');
    pirelab.getBitSliceComp(brNet,shift,vshift_4,3,3,'bitextract4');
    pirelab.getBitSliceComp(brNet,shift,vshift_5,4,4,'bitextract5');
    pirelab.getBitSliceComp(brNet,shift,vshift_6,5,5,'bitextract6');
    pirelab.getBitSliceComp(brNet,shift,vshift_7,6,6,'bitextract7');
    pirelab.getBitSliceComp(brNet,shift,vshift_8,7,7,'bitextract8');
    pirelab.getBitSliceComp(brNet,shift,vshift_9,8,8,'bitextract9');

    dataarray=this.demuxSignal(brNet,data,'dataArray');

    Y_Stage1=[2:384,1];
    Y_Stage2=[3:384,1:2];
    Y_Stage3=[5:384,1:4];
    Y_Stage4=[9:384,1:8];
    Y_Stage5=[17:384,1:16];
    Y_Stage6=[33:384,1:32];
    Y_Stage7=[65:384,1:64];
    Y_Stage8=[129:384,1:128];
    Y_Stage9=[257:384,1:256];


    for idx=1:384

        dstage_arr1(idx)=brNet.addSignal(sType,['data_stage1_',num2str(idx)]);%#ok<*AGROW>
        dout_stage1(idx)=brNet.addSignal(sType,['dout_stage1_',num2str(idx)]);%#ok<*AGROW>


        dstage_arr2(idx)=brNet.addSignal(sType,['data_stage2_',num2str(idx)]);
        dout_stage2(idx)=brNet.addSignal(sType,['dout_stage2_',num2str(idx)]);


        dstage_arr3(idx)=brNet.addSignal(sType,['data_stage3_',num2str(idx)]);
        dout_stage3(idx)=brNet.addSignal(sType,['dout_stage3_',num2str(idx)]);


        dstage_arr4(idx)=brNet.addSignal(sType,['data_stage4_',num2str(idx)]);
        dout_stage4(idx)=brNet.addSignal(sType,['dout_stage4_',num2str(idx)]);


        dstage_arr5(idx)=brNet.addSignal(sType,['data_stage5_',num2str(idx)]);
        dout_stage5(idx)=brNet.addSignal(sType,['dout_stage5_',num2str(idx)]);


        dstage_arr6(idx)=brNet.addSignal(sType,['data_stage6_',num2str(idx)]);
        dout_stage6(idx)=brNet.addSignal(sType,['dout_stage6_',num2str(idx)]);


        dstage_arr7(idx)=brNet.addSignal(sType,['data_stage7_',num2str(idx)]);
        dout_stage7(idx)=brNet.addSignal(sType,['dout_stage7_',num2str(idx)]);


        dstage_arr8(idx)=brNet.addSignal(sType,['data_stage8_',num2str(idx)]);
        dout_stage8(idx)=brNet.addSignal(sType,['dout_stage8_',num2str(idx)]);
    end

    for idx=1:384

        dstage_arr9(idx)=brNet.addSignal(sType,['data_stage9_',num2str(idx)]);
        dout_stage9(idx)=brNet.addSignal(sType,['dout_stage9_',num2str(idx)]);
    end

    for idx1=1:384

        pirelab.getWireComp(brNet,dataarray(Y_Stage1(idx1)),dstage_arr1(idx1),'');
        pirelab.getSwitchComp(brNet,[dstage_arr1(idx1),dataarray(idx1)],dout_stage1(idx1),vshift_1,'sel','~=',0,'Floor','Wrap');
    end

    for idx1=1:384

        pirelab.getWireComp(brNet,dout_stage1(Y_Stage2(idx1)),dstage_arr2(idx1),'');
        pirelab.getSwitchComp(brNet,[dout_stage1(idx1),dstage_arr2(idx1)],dout_stage2(idx1),vshift_2,'sel','==',0,'Floor','Wrap');
    end

    for idx1=1:384

        pirelab.getWireComp(brNet,dout_stage2(Y_Stage3(idx1)),dstage_arr3(idx1),'');
        pirelab.getSwitchComp(brNet,[dout_stage2(idx1),dstage_arr3(idx1)],dout_stage3(idx1),vshift_3,'sel','==',0,'Floor','Wrap');
    end

    for idx1=1:384

        pirelab.getWireComp(brNet,dout_stage3(Y_Stage4(idx1)),dstage_arr4(idx1),'');
        pirelab.getSwitchComp(brNet,[dout_stage3(idx1),dstage_arr4(idx1)],dout_stage4(idx1),vshift_4,'sel','==',0,'Floor','Wrap');
    end

    for idx1=1:384

        pirelab.getWireComp(brNet,dout_stage4(Y_Stage5(idx1)),dstage_arr5(idx1),'');
        pirelab.getSwitchComp(brNet,[dout_stage4(idx1),dstage_arr5(idx1)],dout_stage5(idx1),vshift_5,'sel','==',0,'Floor','Wrap');
    end

    for idx1=1:384

        pirelab.getWireComp(brNet,dout_stage5(Y_Stage6(idx1)),dstage_arr6(idx1),'');
        pirelab.getSwitchComp(brNet,[dout_stage5(idx1),dstage_arr6(idx1)],dout_stage6(idx1),vshift_6,'sel','==',0,'Floor','Wrap');
    end

    for idx1=1:384

        pirelab.getWireComp(brNet,dout_stage6(Y_Stage7(idx1)),dstage_arr7(idx1),'');
        pirelab.getSwitchComp(brNet,[dout_stage6(idx1),dstage_arr7(idx1)],dout_stage7(idx1),vshift_7,'sel','==',0,'Floor','Wrap');
    end

    for idx1=1:384

        pirelab.getWireComp(brNet,dout_stage7(Y_Stage8(idx1)),dstage_arr8(idx1),'');
        pirelab.getSwitchComp(brNet,[dout_stage7(idx1),dstage_arr8(idx1)],dout_stage8(idx1),vshift_8,'sel','==',0,'Floor','Wrap');
    end

    for idx1=1:384

        pirelab.getWireComp(brNet,dout_stage8(Y_Stage9(idx1)),dstage_arr9(idx1),'');
        pirelab.getSwitchComp(brNet,[dout_stage8(idx1),dstage_arr9(idx1)],dout_stage9(idx1),vshift_9,'sel','==',0,'Floor','Wrap');
    end

    this.muxSignal(brNet,dout_stage9,sdata);

end





