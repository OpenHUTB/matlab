function elaborateWriteMaster(obj,hElab,hChannel,hN)





    ufix1Type=pir_ufixpt_t(1,0);
    ufix2Type=pir_ufixpt_t(2,0);
    ufix3Type=pir_ufixpt_t(3,0);
    ufix4Type=pir_ufixpt_t(4,0);
    ufixByteEnType=pir_ufixpt_t(hChannel.NumDataBytes,0);
    ufixAXIDataType=pir_ufixpt_t(hChannel.AXIDataWidth,0);
    ufixIDWidthType=pir_ufixpt_t(hChannel.AXIIDWidth,0);


    port_awid=hChannel.getExtOutportSignal('AWID');
    port_awaddr=hChannel.getExtOutportSignal('AWADDR');
    port_awlen=hChannel.getExtOutportSignal('AWLEN');
    port_awsize=hChannel.getExtOutportSignal('AWSIZE');
    port_awburst=hChannel.getExtOutportSignal('AWBURST');
    port_awlock=hChannel.getExtOutportSignal('AWLOCK');
    port_awcache=hChannel.getExtOutportSignal('AWCACHE');
    port_awprot=hChannel.getExtOutportSignal('AWPROT');
    port_awvalid=hChannel.getExtOutportSignal('AWVALID');
    port_wdata=hChannel.getExtOutportSignal('WDATA');
    port_wstrb=hChannel.getExtOutportSignal('WSTRB');
    port_wlast=hChannel.getExtOutportSignal('WLAST');
    port_wvalid=hChannel.getExtOutportSignal('WVALID');
    port_bready=hChannel.getExtOutportSignal('BREADY');

    port_awready=hChannel.getExtInportSignal('AWREADY');
    port_wready=hChannel.getExtInportSignal('WREADY');
    port_bid=hChannel.getExtInportSignal('BID');
    port_bresp=hChannel.getExtInportSignal('BRESP');
    port_bvalid=hChannel.getExtInportSignal('BVALID');


    awsize_val=log2(hChannel.NumDataBytes);
    byte_en_val=2^(hChannel.NumDataBytes)-1;

    const_1_1=hN.addSignal(ufix1Type,'const_1_1');
    pirelab.getConstComp(hN,const_1_1,1);
    const_0_1=hN.addSignal(ufix1Type,'const_0_1');
    pirelab.getConstComp(hN,const_0_1,0);
    const_IDWidth=hN.addSignal(ufixIDWidthType,'const_IDWidth');
    pirelab.getConstComp(hN,const_IDWidth,0);


    const_wstrb=hN.addSignal(ufixByteEnType,'const_wstrb');
    pirelab.getConstComp(hN,const_wstrb,byte_en_val);
    pirelab.getWireComp(hN,const_wstrb,port_wstrb);


    const_awsize=hN.addSignal(ufix3Type,'const_awsize');
    pirelab.getConstComp(hN,const_awsize,awsize_val);
    pirelab.getWireComp(hN,const_awsize,port_awsize);


    const_1_2=hN.addSignal(ufix2Type,'const_1_2');
    pirelab.getConstComp(hN,const_1_2,1);
    pirelab.getWireComp(hN,const_1_2,port_awburst);











    const_3_4=hN.addSignal(ufix4Type,'const_3_4');
    pirelab.getConstComp(hN,const_3_4,obj.AXIAxCACHEValue);
    pirelab.getWireComp(hN,const_3_4,port_awcache);


    pirelab.getWireComp(hN,const_0_1,port_awlock);


    const_0_3=hN.addSignal(ufix3Type,'const_0_3');
    pirelab.getConstComp(hN,const_0_3,0);
    pirelab.getWireComp(hN,const_0_3,port_awprot);


    if~hChannel.isAnySubPortAssigned

        const_awaddr=hN.addSignal(port_awaddr.Type,'const_awaddr');
        pirelab.getConstComp(hN,const_awaddr,0);
        pirelab.getWireComp(hN,const_awaddr,port_awaddr);

        const_awlen=hN.addSignal(port_awlen.Type,'const_awlen');
        pirelab.getConstComp(hN,const_awlen,0);
        pirelab.getWireComp(hN,const_awlen,port_awlen);

        const_wdata=hN.addSignal(port_wdata.Type,'const_awlen');
        pirelab.getConstComp(hN,const_wdata,0);
        pirelab.getWireComp(hN,const_wdata,port_wdata);

        pirelab.getWireComp(hN,const_0_1,port_awvalid);
        pirelab.getWireComp(hN,const_0_1,port_wlast);
        pirelab.getWireComp(hN,const_0_1,port_wvalid);
        pirelab.getWireComp(hN,const_1_1,port_bready);


        pirelab.getWireComp(hN,const_IDWidth,port_awid);

        return;
    end


    user_wr_ready=hChannel.getUserOutportSignal('wr_ready',true);

    if hChannel.getBusMemberIsAssigned('wr_bvalid')
        user_wr_bvalid=hChannel.getUserOutportSignal('wr_bvalid',true);
    end
    if hChannel.getBusMemberIsAssigned('wr_bresp')
        user_wr_bresp=hChannel.getUserOutportSignal('wr_bresp',true);
    end
    if hChannel.getBusMemberIsAssigned('wr_complete')
        user_wr_complete=hChannel.getUserOutportSignal('wr_complete',true);
    end

    user_wr_data=hChannel.getUserInportSignal('DATA');
    user_wr_addr=hChannel.getUserInportSignal('wr_addr',true);
    user_wr_len=hChannel.getUserInportSignal('wr_len',true);
    user_wr_valid=hChannel.getUserInportSignal('wr_valid',true);

    userDataType=user_wr_data.Type;
    ufixAddrType=pir_ufixpt_t(user_wr_addr.Type.WordLength,0);
    ufixLenType=pir_ufixpt_t(user_wr_len.Type.WordLength,0);



    [~,clkenb,~]=hN.getClockBundle(port_awaddr,1,1,0);
    pirelab.getWireComp(hN,const_1_1,clkenb);


    full_addr=obj.getFullAddr(hElab,hChannel,hN,user_wr_addr);


    len_val=obj.getLenVal(hN,user_wr_len);


    wr_fifo_ack=hN.addSignal(ufix1Type,'wr_fifo_ack');
    wr_fifo_empty=hN.addSignal(ufix1Type,'wr_fifo_empty');
    wr_fifo_afull=hN.addSignal(ufix1Type,'wr_fifo_afull');

    wr_fifo_data=hN.addSignal(userDataType,'wr_fifo_data');
    wr_fifo_addr=hN.addSignal(ufixAddrType,'wr_fifo_addr');
    wr_fifo_len=hN.addSignal(ufixLenType,'wr_fifo_len');
    wr_fifo_awid=hN.addSignal(ufixIDWidthType,'wr_fifo_awid');

    wr_valid_internal=hN.addSignal(ufix1Type,'wr_valid_internal');


    FIFOInputs=[user_wr_data,user_wr_valid,wr_fifo_ack];
    FIFOOutputs=[wr_fifo_data,wr_fifo_empty,wr_fifo_afull];
    pirelab.getFIFOFWFTComp(hN,FIFOInputs,FIFOOutputs,obj.WriteInputFIFODepth,...
    sprintf('%s_wr_data_fifo',hElab.TopNetName),obj.RamCorePrefix,true,obj.MaxReadyToValidLatency);


    pirelab.getBitwiseOpComp(hN,wr_fifo_empty,wr_valid_internal,'NOT');


    pirelab.getBitwiseOpComp(hN,wr_fifo_afull,user_wr_ready,'NOT');


    FIFOInputs=[full_addr,user_wr_valid,wr_fifo_ack];
    FIFOOutputs=wr_fifo_addr;
    pirelab.getFIFOFWFTComp(hN,FIFOInputs,FIFOOutputs,obj.WriteInputFIFODepth,...
    sprintf('%s_wr_addr_fifo',hElab.TopNetName),obj.RamCorePrefix,false);


    FIFOInputs=[len_val,user_wr_valid,wr_fifo_ack];
    FIFOOutputs=wr_fifo_len;
    pirelab.getFIFOFWFTComp(hN,FIFOInputs,FIFOOutputs,obj.WriteInputFIFODepth,...
    sprintf('%s_wr_len_fifo',hElab.TopNetName),obj.RamCorePrefix,false);


    if hChannel.getBusMemberIsAssigned('wr_awid')
        user_wr_awid=hChannel.getUserInportSignal('wr_awid',true);
        FIFOInputs=[user_wr_awid,user_wr_valid,wr_fifo_ack];
        FIFOOutputs=wr_fifo_awid;
        pirelab.getFIFOFWFTComp(hN,FIFOInputs,FIFOOutputs,obj.WriteInputFIFODepth,...
        sprintf('%s_wr_awid_fifo',hElab.TopNetName),obj.RamCorePrefix,false);
    else

        pirelab.getWireComp(hN,const_IDWidth,wr_fifo_awid);
    end



    if userDataType.isArrayType
        ufixAXIDataType=pirelab.getPirVectorType(ufixAXIDataType,userDataType.Dimensions);
    end
    wr_fifo_data_axi=hN.addSignal(ufixAXIDataType,'wr_fifo_data_axi');
    pirelab.getDTCComp(hN,wr_fifo_data,wr_fifo_data_axi,'Floor','Wrap','SI');


    if~hElab.getDefaultBusInterface.isEmptyAXI4SlaveInterface



        [in_burst,soft_reset_pending]=obj.registerResetHoldSignals(hN,hChannel,hElab);


        ufix9Type=pir_ufixpt_t(9,0);
        accumType=pir_sfixpt_t(obj.ResetHoldAccumWidth,0);

        const_1_9=hN.addSignal(ufix9Type,'const_1_9');
        pirelab.getConstComp(hN,const_1_9,1);
        const_0_9=hN.addSignal(ufix9Type,'const_0_9');
        pirelab.getConstComp(hN,const_0_9,0);


        pirelab.getWireComp(hN,const_1_1,port_bready);


        aw_transfer=hN.addSignal(ufix1Type,'aw_transfer');
        pirelab.getBitwiseOpComp(hN,[port_awready,port_awvalid],aw_transfer,'AND');


        w_transfer=hN.addSignal(ufix1Type,'w_transfer');
        pirelab.getBitwiseOpComp(hN,[port_bready,port_bvalid],w_transfer,'AND');


        awlen_plusone=hN.addSignal(ufix9Type,'awlen_plusone');
        pirelab.getWireComp(hN,const_1_9,awlen_plusone);


        aw_transfer_len=hN.addSignal(ufix9Type,'aw_transfer_len');
        pirelab.getSwitchComp(hN,[awlen_plusone,const_0_9],aw_transfer_len,aw_transfer,'switch_aw','==',1);


        w_transfer_len=hN.addSignal(ufix9Type,'w_transfer_len');
        pirelab.getSwitchComp(hN,[const_1_9,const_0_9],w_transfer_len,w_transfer,'switch_w','==',1);

        accum_value=hN.addSignal(accumType,'accum_value');
        accum_aw_len=hN.addSignal(accumType,'accum_aw_len');
        accum_w_len=hN.addSignal(accumType,'accum_w_len');
        pirelab.getAddComp(hN,[aw_transfer_len,accum_value],accum_aw_len,'Floor','wrap','accum_awlen_adder',accumType,'++');
        pirelab.getAddComp(hN,[accum_aw_len,w_transfer_len],accum_w_len,'Floor','wrap','accum_wlen_adder',accumType,'+-');
        pirelab.getUnitDelayComp(hN,accum_w_len,accum_value,'reg_accum');
        pirelab.getCompareToValueComp(hN,accum_value,in_burst,'>',0);

    else


        soft_reset_pending=hN.addSignal(ufix1Type,'soft_reset_pending');
        pirelab.getWireComp(hN,const_0_1,soft_reset_pending);










        pirelab.getWireComp(hN,const_1_1,port_bready);

    end


    out_fifo_wdata=hN.addSignal(ufixAXIDataType,'out_fifo_wdata');
    out_fifo_push=hN.addSignal(ufix1Type,'out_fifo_push');
    out_fifo_wlast=hN.addSignal(ufix1Type,'out_fifo_wlast');
    out_fifo_afull=hN.addSignal(ufix1Type,'out_fifo_afull');

    wr_complete_internal=hN.addSignal(ufix1Type,'wr_complete_internal');
    wr_transfer=hN.addSignal(ufix1Type,'wr_transfer');

    TotalDataWidth=hChannel.AXIDataTotalWidth;
    hN.addComponent2(...
    'kind','cgireml',...
    'Name',sprintf('axi4_master_wr'),...
    'InputSignals',[port_awready,...
    wr_fifo_len,wr_valid_internal,wr_fifo_addr,wr_fifo_awid,...
    out_fifo_afull,...
    soft_reset_pending],...
    'OutputSignals',[port_awvalid,port_awaddr,port_awlen,port_awid...
    ,out_fifo_push,out_fifo_wlast,...
    wr_fifo_ack,...
    wr_transfer,...
    wr_complete_internal],...
    'EMLFileName','hdleml_axi4_wr_master',...
    'EMLParams',{TotalDataWidth,obj.AXILenWidth}...
    );

    if hChannel.getBusMemberIsAssigned('wr_bvalid')
        pirelab.getWireComp(hN,port_bvalid,user_wr_bvalid);
    end
    if hChannel.getBusMemberIsAssigned('wr_bresp')
        pirelab.getWireComp(hN,port_bresp,user_wr_bresp);
    end
    if hChannel.getBusMemberIsAssigned('wr_complete')
        pirelab.getWireComp(hN,wr_complete_internal,user_wr_complete);
    end
    if hChannel.getBusMemberIsAssigned('wr_bid')
        user_wr_bid=hChannel.getUserOutportSignal('wr_bid',true);
        pirelab.getWireComp(hN,port_bid,user_wr_bid);
    end


    pirelab.getUnitDelayEnabledComp(hN,wr_fifo_data_axi,out_fifo_wdata,wr_transfer,'wr_transfer_reg');


    out_fifo_ack=hN.addSignal(ufix1Type,'out_fifo_ack');
    out_fifo_empty=hN.addSignal(ufix1Type,'out_fifo_empty');
    wvalid_internal=hN.addSignal(ufix1Type,'wvalid_internal');


    FIFOInputs=[out_fifo_wdata,out_fifo_push,out_fifo_ack];
    FIFOOutputs=[port_wdata,out_fifo_empty,out_fifo_afull];

    pirelab.getFIFOFWFTComp(hN,FIFOInputs,FIFOOutputs,obj.WriteOutputFIFODepth,...
    sprintf('%s_wdata_fifo',hElab.TopNetName),obj.RamCorePrefix,true,1);


    pirelab.getBitwiseOpComp(hN,out_fifo_empty,wvalid_internal,'NOT');
    pirelab.getWireComp(hN,wvalid_internal,port_wvalid);


    pirelab.getBitwiseOpComp(hN,[port_wready,wvalid_internal],out_fifo_ack,'AND');


    FIFOInputs=[out_fifo_wlast,out_fifo_push,out_fifo_ack];
    FIFOOutputs=port_wlast;
    pirelab.getFIFOFWFTComp(hN,FIFOInputs,FIFOOutputs,obj.WriteOutputFIFODepth,...
    sprintf('%s_wlast_fifo',hElab.TopNetName),obj.RamCorePrefix,false);

end







