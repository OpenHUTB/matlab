function elaborateReadMaster(obj,hElab,hChannel,hN)





    ufix1Type=pir_ufixpt_t(1,0);
    ufix2Type=pir_ufixpt_t(2,0);
    ufix3Type=pir_ufixpt_t(3,0);
    ufix4Type=pir_ufixpt_t(4,0);
    ufixIDWidthType=pir_ufixpt_t(hChannel.AXIIDWidth,0);


    port_arid=hChannel.getExtOutportSignal('ARID');
    port_araddr=hChannel.getExtOutportSignal('ARADDR');
    port_arlen=hChannel.getExtOutportSignal('ARLEN');
    port_arsize=hChannel.getExtOutportSignal('ARSIZE');
    port_arburst=hChannel.getExtOutportSignal('ARBURST');
    port_arlock=hChannel.getExtOutportSignal('ARLOCK');
    port_arcache=hChannel.getExtOutportSignal('ARCACHE');
    port_arprot=hChannel.getExtOutportSignal('ARPROT');
    port_arvalid=hChannel.getExtOutportSignal('ARVALID');
    port_rready=hChannel.getExtOutportSignal('RREADY');

    port_rdata=hChannel.getExtInportSignal('RDATA');
    port_rlast=hChannel.getExtInportSignal('RLAST');%#ok<NASGU>
    port_rvalid=hChannel.getExtInportSignal('RVALID');
    port_rid=hChannel.getExtInportSignal('RID');
    port_rresp=hChannel.getExtInportSignal('RRESP');
    port_arready=hChannel.getExtInportSignal('ARREADY');


    const_1_1=hN.addSignal(ufix1Type,'const_1_1');
    pirelab.getConstComp(hN,const_1_1,1);
    const_0_1=hN.addSignal(ufix1Type,'const_0_1');
    pirelab.getConstComp(hN,const_0_1,0);
    const_IDWidth=hN.addSignal(ufixIDWidthType,'const_IDWidth');
    pirelab.getConstComp(hN,const_IDWidth,0);


    arsize_val=log2(hChannel.NumDataBytes);
    const_arsize=hN.addSignal(ufix3Type,'const_arsize');
    pirelab.getConstComp(hN,const_arsize,arsize_val);
    pirelab.getWireComp(hN,const_arsize,port_arsize);


    const_1_2=hN.addSignal(ufix2Type,'const_1_2');
    pirelab.getConstComp(hN,const_1_2,1);
    pirelab.getWireComp(hN,const_1_2,port_arburst);











    const_3_4=hN.addSignal(ufix4Type,'const_3_4');
    pirelab.getConstComp(hN,const_3_4,obj.AXIAxCACHEValue);
    pirelab.getWireComp(hN,const_3_4,port_arcache);


    pirelab.getWireComp(hN,const_0_1,port_arlock);


    const_0_3=hN.addSignal(ufix3Type,'const_0_3 ');
    pirelab.getConstComp(hN,const_0_3,0);
    pirelab.getWireComp(hN,const_0_3,port_arprot);


    if~hChannel.isAnySubPortAssigned

        const_araddr=hN.addSignal(port_araddr.Type,'const_araddr');
        pirelab.getConstComp(hN,const_araddr,0);
        pirelab.getWireComp(hN,const_araddr,port_araddr);

        const_arlen=hN.addSignal(port_arlen.Type,'const_arlen');
        pirelab.getConstComp(hN,const_arlen,0);
        pirelab.getWireComp(hN,const_arlen,port_arlen);

        pirelab.getWireComp(hN,const_0_1,port_arvalid);
        pirelab.getWireComp(hN,const_1_1,port_rready);

        pirelab.getWireComp(hN,const_IDWidth,port_arid);

        return;
    end


    user_rd_data=hChannel.getUserOutportSignal('DATA');
    user_rd_aready=hChannel.getUserOutportSignal('rd_aready',true);
    user_rd_dvalid=hChannel.getUserOutportSignal('rd_dvalid',true);

    if hChannel.getBusMemberIsAssigned('rd_rresp')
        user_rd_rresp=hChannel.getUserOutportSignal('rd_rresp',true);
    end

    user_rd_addr=hChannel.getUserInportSignal('rd_addr',true);
    user_rd_len=hChannel.getUserInportSignal('rd_len',true);
    user_rd_avalid=hChannel.getUserInportSignal('rd_avalid',true);

    if hChannel.getBusMemberIsAssigned('rd_dready')
        user_rd_dready=hChannel.getUserInportSignal('rd_dready',true);
    end

    userDataType=user_rd_data.Type;
    if userDataType.isArrayType
        ufixDataType=pir_ufixpt_t(userDataType.BaseType.WordLength,0);
        ufixDataType=pirelab.getPirVectorType(ufixDataType,userDataType.Dimensions);
    else
        ufixDataType=pir_ufixpt_t(userDataType.WordLength,0);
    end
    ufixAddrType=pir_ufixpt_t(user_rd_addr.Type.WordLength,0);
    ufixLenType=pir_ufixpt_t(user_rd_len.Type.WordLength,0);



    [~,clkenb,~]=hN.getClockBundle(port_araddr,1,1,0);
    pirelab.getWireComp(hN,const_1_1,clkenb);


    full_addr=obj.getFullAddr(hElab,hChannel,hN,user_rd_addr);


    len_val=obj.getLenVal(hN,user_rd_len);


    rd_fifo_ack=hN.addSignal(ufix1Type,'rd_fifo_ack');
    rd_fifo_empty=hN.addSignal(ufix1Type,'rd_fifo_empty');
    rd_fifo_afull=hN.addSignal(ufix1Type,'rd_fifo_afull');

    rd_fifo_addr=hN.addSignal(ufixAddrType,'rd_fifo_addr');
    rd_fifo_len=hN.addSignal(ufixLenType,'rd_fifo_len');
    rd_fifo_arid=hN.addSignal(ufixIDWidthType,'rd_fifo_arid');

    rd_valid_internal=hN.addSignal(ufix1Type,'rd_valid_internal');


    FIFOInputs=[full_addr,user_rd_avalid,rd_fifo_ack];
    FIFOOutputs=[rd_fifo_addr,rd_fifo_empty,rd_fifo_afull];
    pirelab.getFIFOFWFTComp(hN,FIFOInputs,FIFOOutputs,obj.ReadRequestFIFODepth,...
    sprintf('%s_rd_addr_fifo',hElab.TopNetName),obj.RamCorePrefix,true,obj.MaxReadyToValidLatency);


    pirelab.getBitwiseOpComp(hN,rd_fifo_empty,rd_valid_internal,'NOT');


    pirelab.getBitwiseOpComp(hN,rd_fifo_afull,user_rd_aready,'NOT');


    FIFOInputs=[len_val,user_rd_avalid,rd_fifo_ack];
    FIFOOutputs=rd_fifo_len;
    pirelab.getFIFOFWFTComp(hN,FIFOInputs,FIFOOutputs,obj.ReadRequestFIFODepth,...
    sprintf('%s_rd_len_fifo',hElab.TopNetName),obj.RamCorePrefix,false);


    if hChannel.getBusMemberIsAssigned('rd_arid')



        user_rd_arid=hChannel.getUserInportSignal('rd_arid',true);
        FIFOInputs=[user_rd_arid,user_rd_avalid,rd_fifo_ack];
        FIFOOutputs=rd_fifo_arid;
        pirelab.getFIFOFWFTComp(hN,FIFOInputs,FIFOOutputs,obj.ReadRequestFIFODepth,...
        sprintf('%s_rd_arid_fifo',hElab.TopNetName),obj.RamCorePrefix,false);
    else

        pirelab.getWireComp(hN,const_IDWidth,rd_fifo_arid);
    end


    if~hElab.getDefaultBusInterface.isEmptyAXI4SlaveInterface



        [in_burst,soft_reset_pending]=obj.registerResetHoldSignals(hN,hChannel,hElab);


        ufix9Type=pir_ufixpt_t(9,0);
        accumType=pir_sfixpt_t(obj.ResetHoldAccumWidth,0);

        const_1_9=hN.addSignal(ufix9Type,'const_1_9');
        pirelab.getConstComp(hN,const_1_9,1);
        const_0_9=hN.addSignal(ufix9Type,'const_0_9');
        pirelab.getConstComp(hN,const_0_9,0);

        ar_transfer=hN.addSignal(ufix1Type,'ar_transfer');
        pirelab.getBitwiseOpComp(hN,[port_arready,port_arvalid],ar_transfer,'AND');

        r_transfer=hN.addSignal(ufix1Type,'r_transfer');
        pirelab.getBitwiseOpComp(hN,[port_rready,port_rvalid],r_transfer,'AND');

        arlen_plusone=hN.addSignal(ufix9Type,'arlen_plusone');
        pirelab.getAddComp(hN,[port_arlen,const_1_9],arlen_plusone,'Floor','wrap','arlen_adder',ufix9Type,'++');

        ar_transfer_len=hN.addSignal(ufix9Type,'ar_transfer_len');
        pirelab.getSwitchComp(hN,[arlen_plusone,const_0_9],ar_transfer_len,ar_transfer,'switch_ar','==',1);

        r_transfer_len=hN.addSignal(ufix9Type,'r_transfer_len');
        pirelab.getSwitchComp(hN,[const_1_9,const_0_9],r_transfer_len,r_transfer,'switch_r','==',1);

        accum_value=hN.addSignal(accumType,'accum_value');
        accum_ar_len=hN.addSignal(accumType,'accum_ar_len');
        accum_r_len=hN.addSignal(accumType,'accum_ar_len');
        pirelab.getAddComp(hN,[ar_transfer_len,accum_value],accum_ar_len,'Floor','wrap','accum_arlen_adder',accumType,'++');
        pirelab.getAddComp(hN,[accum_ar_len,r_transfer_len],accum_r_len,'Floor','wrap','accum_rlen_adder',accumType,'+-');
        pirelab.getUnitDelayComp(hN,accum_r_len,accum_value,'reg_accum');
        pirelab.getCompareToValueComp(hN,accum_value,in_burst,'>',0);

    else


        soft_reset_pending=hN.addSignal(ufix1Type,'soft_reset_pending');
        pirelab.getWireComp(hN,const_0_1,soft_reset_pending);

    end


    TotalDataWidth=hChannel.AXIDataTotalWidth;
    hN.addComponent2(...
    'kind','cgireml',...
    'Name',sprintf('axi4_master_rd'),...
    'InputSignals',[port_arready,rd_fifo_len,rd_valid_internal,rd_fifo_addr,rd_fifo_arid,...
    soft_reset_pending],...
    'OutputSignals',[port_arvalid,port_araddr,port_arlen,port_arid,rd_fifo_ack],...
    'EMLFileName','hdleml_axi4_rd_master',...
    'EMLParams',{TotalDataWidth,obj.AXILenWidth}...
    );


    out_fifo_data=hN.addSignal(ufixDataType,'out_fifo_data');
    pirelab.getDTCComp(hN,port_rdata,out_fifo_data,'Floor','Wrap','SI');


    rdata_fifo_empty=hN.addSignal(ufix1Type,'rdata_fifo_empty');
    rdata_fifo_valid=hN.addSignal(ufix1Type,'rdata_fifo_valid');
    rdata_fifo_full=hN.addSignal(ufix1Type,'rdata_fifo_full');
    rd_dvalid=hN.addSignal(ufix1Type,'rd_dvalid');
    rd_dready_reg=hN.addSignal(ufix1Type,'rd_dready_reg');


    if hChannel.getBusMemberIsAssigned('rd_dready')



        pirelab.getIntDelayComp(hN,user_rd_dready,rd_dready_reg,1,'rdy_reg_comp');
    else
        pirelab.getWireComp(hN,const_1_1,rd_dready_reg);
    end


    if hChannel.getBusMemberIsAssigned('rd_rid')




        user_rd_rid=hChannel.getUserOutportSignal('rd_rid',true);
        FIFOInputs=[port_rid,port_rvalid,rd_dready_reg];
        FIFOOutputs=user_rd_rid;
        pirelab.getFIFOFWFTComp(hN,FIFOInputs,FIFOOutputs,obj.ReadInputFIFODepth,...
        sprintf('%s_rid_fifo',hElab.TopNetName),obj.RamCorePrefix,false);
    end


    FIFOInputs=[out_fifo_data,port_rvalid,rd_dready_reg];
    FIFOOutputs=[user_rd_data,rdata_fifo_empty,rdata_fifo_full];
    pirelab.getFIFOFWFTComp(hN,FIFOInputs,FIFOOutputs,obj.ReadInputFIFODepth,...
    sprintf('%s_rdata_fifo',hElab.TopNetName),obj.RamCorePrefix,true);


    pirelab.getBitwiseOpComp(hN,rdata_fifo_full,port_rready,'NOT');


    pirelab.getBitwiseOpComp(hN,rdata_fifo_empty,rdata_fifo_valid,'NOT');


    pirelab.getBitwiseOpComp(hN,[rdata_fifo_valid,rd_dready_reg],rd_dvalid,'AND');
    pirelab.getWireComp(hN,rd_dvalid,user_rd_dvalid);


    if hChannel.getBusMemberIsAssigned('rd_rresp')
        FIFOInputs=[port_rresp,port_rvalid,rd_dready_reg];
        FIFOOutputs=user_rd_rresp;
        pirelab.getFIFOFWFTComp(hN,FIFOInputs,FIFOOutputs,obj.ReadInputFIFODepth,...
        sprintf('%s_rresp_fifo',hElab.TopNetName),obj.RamCorePrefix,false);
    end

end







