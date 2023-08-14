function bmNet=elabBetaMemoryNetwork(this,topNet,blockInfo,dataRate)



    ufix1Type=pir_ufixpt_t(1,0);
    ufix6Type=pir_ufixpt_t(6,0);
    bc1Type=pir_ufixpt_t(25,0);
    bc2Type=pir_ufixpt_t(blockInfo.betadecmpWL,0);
    bcVType1=pirelab.getPirVectorType(bc1Type,384);
    bcVType2=pirelab.getPirVectorType(bc2Type,384);

    bcType1_1=pir_ufixpt_t(6,0);
    bcType1_2=pir_ufixpt_t(9,0);
    bcType1_3=pir_ufixpt_t(10,0);

    muxbcType1_2=pir_ufixpt_t(36,0);

    if blockInfo.VectorSize==64
        muxbcType1_1=pir_ufixpt_t(36,0);
        uVType=ufix1Type;
    else
        muxbcType1_1=pir_ufixpt_t(24,0);
        uVType=pirelab.getPirVectorType(ufix1Type,384);
    end

    bmNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CheckNodeRAM',...
    'Inportnames',{'bdecomp1','bdecomp2','countlayer','enbread','bvalid',},...
    'InportTypes',[bcVType1,bcVType2,ufix6Type,ufix1Type,uVType],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'bdecomp1Out','bdecomp2Out','bvalidOut'},...
    'OutportTypes',[bcVType1,bcVType2,ufix1Type]...
    );

    beta1=bmNet.PirInputSignals(1);
    beta2=bmNet.PirInputSignals(2);
    countlayer=bmNet.PirInputSignals(3);
    enbread=bmNet.PirInputSignals(4);
    validin=bmNet.PirInputSignals(5);

    betaout1=bmNet.PirOutputSignals(1);
    betaout2=bmNet.PirOutputSignals(2);
    validout=bmNet.PirOutputSignals(3);

    beta1_reg=bmNet.addSignal(beta1.Type,'bdecmp1Reg');
    beta2_reg=bmNet.addSignal(beta2.Type,'bdecmp2Reg');
    layer_reg=bmNet.addSignal(countlayer.Type,'layerReg');
    valid_reg=bmNet.addSignal(validin.Type,'validReg');

    pirelab.getUnitDelayComp(bmNet,beta1,beta1_reg,'beta1',0);
    pirelab.getUnitDelayComp(bmNet,beta2,beta2_reg,'beta2',0);
    pirelab.getIntDelayComp(bmNet,countlayer,layer_reg,2,'layer',0);
    pirelab.getUnitDelayComp(bmNet,validin,valid_reg,'valid',0);

    beta1_array=this.demuxSignal(bmNet,beta1_reg,'beta1_array');
    beta2_array=this.demuxSignal(bmNet,beta2_reg,'beta2_array');

    if blockInfo.VectorSize==64
        for i=1:384
            valid_array(i)=bmNet.addSignal(ufix1Type,['valid_array_',num2str(i)]);
            pirelab.getWireComp(bmNet,valid_reg,valid_array(i));
        end
    else
        valid_array=this.demuxSignal(bmNet,valid_reg,'valid_array');
    end

    for idx=1:384
        decomp1_1(idx)=bmNet.addSignal(bcType1_1,['decomp1_1_',num2str(idx)]);%#ok<*AGROW>
        decomp1_2(idx)=bmNet.addSignal(bcType1_2,['decomp1_2_',num2str(idx)]);%#ok<*AGROW>
        decomp1_3(idx)=bmNet.addSignal(bcType1_3,['decomp1_3_',num2str(idx)]);%#ok<*AGROW>
        pirelab.getBitSliceComp(bmNet,beta1_array(idx),decomp1_1(idx),24,19,'ext1');
        pirelab.getBitSliceComp(bmNet,beta1_array(idx),decomp1_2(idx),8,0,'ext2');
        pirelab.getBitSliceComp(bmNet,beta1_array(idx),decomp1_3(idx),18,9,'ext3');
        betaout1_3(idx)=bmNet.addSignal(bcType1_3,['betaout1_3_arr_',num2str(idx)]);%#ok<*AGROW>
        pirelab.getSimpleDualPortRamComp(bmNet,[decomp1_3(idx),layer_reg,valid_array(idx),layer_reg],betaout1_3(idx),'CheckNodeRAM1_3',1,-1,[],'','',blockInfo.ramAttr_dist);
    end

    if blockInfo.VectorSize==64
        for idx=1:6:379
            bcomp1_arr((idx-1)/6+1)=bmNet.addSignal(muxbcType1_1,['betacomp1_1_arr_',num2str(idx)]);%#ok<*AGROW>
            betao1_1((idx-1)/6+1)=bmNet.addSignal(muxbcType1_1,['betao1_1_arr_',num2str(idx)]);%#ok<*AGROW>
            pirelab.getBitConcatComp(bmNet,[decomp1_1(idx),decomp1_1(idx+1),decomp1_1(idx+2),decomp1_1(idx+3),decomp1_1(idx+4),...
            decomp1_1(idx+5)],bcomp1_arr((idx-1)/6+1),'bitConcat1');
            pirelab.getSimpleDualPortRamComp(bmNet,[bcomp1_arr((idx-1)/6+1),layer_reg,valid_array(idx),layer_reg],betao1_1((idx-1)/6+1),'CheckNodeRAM1_1',1,-1,[],'','',blockInfo.ramAttr_block);


            betaout1_1(idx)=bmNet.addSignal(bcType1_1,['betaout1_1_arr_',num2str(idx)]);%#ok<*AGROW>
            betaout1_1(idx+1)=bmNet.addSignal(bcType1_1,['betaout1_1_arr_',num2str(idx)]);%#ok<*AGROW>
            betaout1_1(idx+2)=bmNet.addSignal(bcType1_1,['betaout1_1_arr_',num2str(idx)]);%#ok<*AGROW>
            betaout1_1(idx+3)=bmNet.addSignal(bcType1_1,['betaout1_1_arr_',num2str(idx)]);%#ok<*AGROW>
            betaout1_1(idx+4)=bmNet.addSignal(bcType1_1,['betaout1_1_arr_',num2str(idx)]);%#ok<*AGROW>
            betaout1_1(idx+5)=bmNet.addSignal(bcType1_1,['betaout1_1_arr_',num2str(idx)]);%#ok<*AGROW>
            pirelab.getBitSliceComp(bmNet,betao1_1((idx-1)/6+1),betaout1_1(idx),35,30,'ext1');
            pirelab.getBitSliceComp(bmNet,betao1_1((idx-1)/6+1),betaout1_1(idx+1),29,24,'ext2');
            pirelab.getBitSliceComp(bmNet,betao1_1((idx-1)/6+1),betaout1_1(idx+2),23,18,'ext3');
            pirelab.getBitSliceComp(bmNet,betao1_1((idx-1)/6+1),betaout1_1(idx+3),17,12,'ext4');
            pirelab.getBitSliceComp(bmNet,betao1_1((idx-1)/6+1),betaout1_1(idx+4),11,6,'ext5');
            pirelab.getBitSliceComp(bmNet,betao1_1((idx-1)/6+1),betaout1_1(idx+5),5,0,'ext6');
        end
    else
        for idx=1:4:381
            bcomp1_arr((idx-1)/4+1)=bmNet.addSignal(muxbcType1_1,['betacomp1_1_arr_',num2str(idx)]);%#ok<*AGROW>
            betao1_1((idx-1)/4+1)=bmNet.addSignal(muxbcType1_1,['betao1_1_arr_',num2str(idx)]);%#ok<*AGROW>
            pirelab.getBitConcatComp(bmNet,[decomp1_1(idx),decomp1_1(idx+1),decomp1_1(idx+2),decomp1_1(idx+3)],bcomp1_arr((idx-1)/4+1),'bitConcat1');
            pirelab.getSimpleDualPortRamComp(bmNet,[bcomp1_arr((idx-1)/4+1),layer_reg,valid_array(idx),layer_reg],betao1_1((idx-1)/4+1),'CheckNodeRAM1_1',1,-1,[],'','',blockInfo.ramAttr_block);

            betaout1_1(idx)=bmNet.addSignal(bcType1_1,['betaout1_1_arr_',num2str(idx)]);%#ok<*AGROW>
            betaout1_1(idx+1)=bmNet.addSignal(bcType1_1,['betaout1_1_arr_',num2str(idx)]);%#ok<*AGROW>
            betaout1_1(idx+2)=bmNet.addSignal(bcType1_1,['betaout1_1_arr_',num2str(idx)]);%#ok<*AGROW>
            betaout1_1(idx+3)=bmNet.addSignal(bcType1_1,['betaout1_1_arr_',num2str(idx)]);%#ok<*AGROW>

            pirelab.getBitSliceComp(bmNet,betao1_1((idx-1)/4+1),betaout1_1(idx),23,18,'ext1');
            pirelab.getBitSliceComp(bmNet,betao1_1((idx-1)/4+1),betaout1_1(idx+1),17,12,'ext2');
            pirelab.getBitSliceComp(bmNet,betao1_1((idx-1)/4+1),betaout1_1(idx+2),11,6,'ext3');
            pirelab.getBitSliceComp(bmNet,betao1_1((idx-1)/4+1),betaout1_1(idx+3),5,0,'ext4');
        end
    end


    for idx=1:4:381
        bcomp2_arr((idx-1)/4+1)=bmNet.addSignal(muxbcType1_2,['betacomp1_2_arr_',num2str(idx)]);%#ok<*AGROW>
        betao1_2((idx-1)/4+1)=bmNet.addSignal(muxbcType1_2,['betao1_2_arr_',num2str(idx)]);%#ok<*AGROW>
        pirelab.getBitConcatComp(bmNet,[decomp1_2(idx),decomp1_2(idx+1),decomp1_2(idx+2),decomp1_2(idx+3)],bcomp2_arr((idx-1)/4+1),'bitConcat1');
        pirelab.getSimpleDualPortRamComp(bmNet,[bcomp2_arr((idx-1)/4+1),layer_reg,valid_array(idx),layer_reg],betao1_2((idx-1)/4+1),'CheckNodeRAM1_2',1,-1,[],'','',blockInfo.ramAttr_block);


        betaout1_2(idx)=bmNet.addSignal(bcType1_2,['betaout1_2_arr_',num2str(idx)]);%#ok<*AGROW>
        betaout1_2(idx+1)=bmNet.addSignal(bcType1_2,['betaout1_2_arr_',num2str(idx)]);%#ok<*AGROW>
        betaout1_2(idx+2)=bmNet.addSignal(bcType1_2,['betaout1_2_arr_',num2str(idx)]);%#ok<*AGROW>
        betaout1_2(idx+3)=bmNet.addSignal(bcType1_2,['betaout1_2_arr_',num2str(idx)]);%#ok<*AGROW>
        pirelab.getBitSliceComp(bmNet,betao1_2((idx-1)/4+1),betaout1_2(idx),35,27,'ext1');
        pirelab.getBitSliceComp(bmNet,betao1_2((idx-1)/4+1),betaout1_2(idx+1),26,18,'ext2');
        pirelab.getBitSliceComp(bmNet,betao1_2((idx-1)/4+1),betaout1_2(idx+2),17,9,'ext3');
        pirelab.getBitSliceComp(bmNet,betao1_2((idx-1)/4+1),betaout1_2(idx+3),8,0,'ext4');
    end

    for idx=1:384
        betaout1_tmp(idx)=bmNet.addSignal(bc1Type,['betaout1_tmp_arr_',num2str(idx)]);%#ok<*AGROW>
        pirelab.getBitConcatComp(bmNet,[betaout1_1(idx),betaout1_3(idx),betaout1_2(idx)],betaout1_tmp(idx),'bitConcat1');
    end

    this.muxSignal(bmNet,betaout1_tmp,betaout1);

    for idx=1:384
        betaout2_array(idx)=bmNet.addSignal(bc2Type,['betaout2_arr_',num2str(idx)]);%#ok<*AGROW>
        pirelab.getSimpleDualPortRamComp(bmNet,[beta2_array(idx),layer_reg,valid_array(idx),layer_reg],betaout2_array(idx),'CheckNodeRAM2',1,-1,[],'','',blockInfo.ramAttr_dist);

    end

    this.muxSignal(bmNet,betaout1_tmp,betaout1);
    this.muxSignal(bmNet,betaout2_array,betaout2);

    pirelab.getUnitDelayComp(bmNet,enbread,validout,'valid',0);


end
