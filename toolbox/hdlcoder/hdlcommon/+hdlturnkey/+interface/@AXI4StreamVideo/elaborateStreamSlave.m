function elaborateStreamSlave(obj,hElab,hChannel,...
    hN,hStreamNetInportSignals,hStreamNetOutportSignals,multiRateCountEnable,multiRateCountValue)



























    ufix1Type=pir_ufixpt_t(1,0);
    addr_type=pir_ufixpt_t(13,0);


    port_tdata=hStreamNetInportSignals(1);
    port_tvalid=hStreamNetInportSignals(2);
    port_tlast=hStreamNetInportSignals(3);
    port_tuser=hStreamNetInportSignals(4);

    port_tready=hStreamNetOutportSignals(1);
    user_valid=hStreamNetOutportSignals(7);



    [fifo_rd_ack,stream_in_user_ready,stream_in_user_data,stream_in_user_valid]=...
    obj.elaborateSlaveDataFIFO(hN,hElab,...
    port_tdata,port_tvalid,port_tready,multiRateCountEnable,multiRateCountValue);


    stream_in_user_sof=hN.addSignal(ufix1Type,'stream_in_user_sof');
    stream_in_user_eol=hN.addSignal(ufix1Type,'stream_in_user_eol');

    pirelab.getFIFOFWFTComp(hN,[port_tuser,port_tvalid,fifo_rd_ack],stream_in_user_sof,...
    obj.FIFOSize,sprintf('%s_%s_sof',hElab.TopNetName,obj.FIFOName),obj.RamCorePrefix,false);

    pirelab.getFIFOFWFTComp(hN,[port_tlast,port_tvalid,fifo_rd_ack],stream_in_user_eol,...
    obj.FIFOSize,sprintf('%s_%s_eol',hElab.TopNetName,obj.FIFOName),obj.RamCorePrefix,false);


    hBus=obj.getDefaultBusInterface(hElab);


    registerID=sprintf('%s_image_width',lower(hChannel.ChannelPortLabel));
    hAddr=hBus.getBaseAddrWithName(registerID);
    image_length=hN.addSignal(addr_type,'image_width');
    hAddr.assignScheduledElab(image_length,hdlturnkey.data.DecoderType.WRITE);


    registerID=sprintf('%s_image_height',lower(hChannel.ChannelPortLabel));
    hAddr=hBus.getBaseAddrWithName(registerID);
    image_height=hN.addSignal(addr_type,'image_height');
    hAddr.assignScheduledElab(image_height,hdlturnkey.data.DecoderType.WRITE);


    registerID=sprintf('%s_hporch',lower(hChannel.ChannelPortLabel));
    hAddr=hBus.getBaseAddrWithName(registerID);
    hporch=hN.addSignal(addr_type,'hporch');
    hAddr.assignScheduledElab(hporch,hdlturnkey.data.DecoderType.WRITE);


    registerID=sprintf('%s_vporch',lower(hChannel.ChannelPortLabel));
    hAddr=hBus.getBaseAddrWithName(registerID);
    vporch=hN.addSignal(addr_type,'vporch');
    hAddr.assignScheduledElab(vporch,hdlturnkey.data.DecoderType.WRITE);


    adapter_in_enable=hN.addSignal(ufix1Type,'adapter_in_enable');
    adapter_in_ready_out=hN.addSignal(ufix1Type,'adapter_in_ready_out');
    adapter_in_valid_out=hN.addSignal(ufix1Type,'adapter_in_valid_out');


    AdapterInInput=[stream_in_user_data,stream_in_user_valid,stream_in_user_sof,stream_in_user_eol,...
    image_length,image_height,hporch,vporch,adapter_in_enable];

    AdapterInOutput=[hStreamNetOutportSignals(2),hStreamNetOutportSignals(3:6),...
    adapter_in_valid_out,adapter_in_ready_out];

    obj.elaborateVHTAdapterIn(hElab,hChannel,hN,AdapterInInput,AdapterInOutput);


    internal_ready=obj.elaborateSlaveReadyLogic(hN,hChannel,hStreamNetInportSignals);


    pirelab.getUnitDelayComp(hN,internal_ready,adapter_in_enable);


    pirelab.getBitwiseOpComp(hN,[internal_ready,adapter_in_ready_out],stream_in_user_ready,'AND');



    pirelab.getBitwiseOpComp(hN,[adapter_in_enable,adapter_in_valid_out],user_valid,'AND');

end



