function elaborateStreamMaster(obj,hElab,hChannel,...
    hN,hStreamNetInportSignals,hStreamNetOutportSignals,multiRateCountEnable,multiRateCountValue)

































    ufix1Type=pir_ufixpt_t(1,0);


    port_tready=hStreamNetInportSignals(1);
    user_data=hStreamNetInportSignals(2);

    if~hChannel.isSampleControlBusAssigned
        user_valid=hStreamNetInportSignals(3);
    else
        user_start=hStreamNetInportSignals(3);%#ok<NASGU>
        user_end=hStreamNetInportSignals(4);
        user_valid=hStreamNetInportSignals(5);
    end

    port_tdata=hStreamNetOutportSignals(1);
    port_tvalid=hStreamNetOutportSignals(2);
    port_tlast=hStreamNetOutportSignals(3);



    [internal_ready,fifo_push]=obj.elaborateMasterDataFIFO(hN,hElab,hChannel,...
    user_data,user_valid,port_tready,...
    port_tdata,port_tvalid,...
    multiRateCountEnable,multiRateCountValue);


    if hChannel.isSampleControlBusAssigned


        tlast_in_signal=user_end;

    elseif hChannel.isTLASTPortAssigned


        tlast_in_signal=hStreamNetInportSignals(...
        length(hChannel.ExtInportNames)+hChannel.UserInportList.('TLAST').Index);

    else







        counterBitWidth=32;
        counterType=pir_ufixpt_t(counterBitWidth,0);



        hBus=obj.getDefaultBusInterface(hElab);

        registerID=sprintf('packet_size_%s',lower(hChannel.ChannelPortLabel));
        hAddr=hBus.getBaseAddrWithName(registerID);
        reg_packet_size=hN.addSignal(counterType,'reg_packet_size');
        hAddr.assignScheduledElab(reg_packet_size,hdlturnkey.data.DecoderType.WRITE);

        reg_packet_size_strobe=hN.addSignal(ufix1Type,'reg_packet_size_strobe');
        hAddr.assignStrobeSignal(reg_packet_size_strobe);


        auto_tlast=hN.addSignal(ufix1Type,'auto_tlast');
        pirtarget.getTLASTCounterComp(hN,...
        [fifo_push,reg_packet_size,reg_packet_size_strobe],auto_tlast,counterBitWidth);


        tlast_in_signal=auto_tlast;
    end


    pirelab.getFIFOFWFTComp(hN,[tlast_in_signal,fifo_push,port_tready],port_tlast,...
    obj.FIFOSize,sprintf('%s_%s_TLAST_OUT',hElab.TopNetName,obj.FIFOName),obj.RamCorePrefix,false);


    for ii=1:length(hChannel.UserAssignedInportPorts)
        subPortID=hChannel.UserAssignedInportPorts{ii};
        hSubPort=hChannel.getPort(subPortID);

        if~hdlturnkey.interface.AXI4Stream.isSideBandPortGroup(hSubPort)
            continue;
        end


        subPortName=hSubPort.PortName;
        port_signal=hStreamNetOutportSignals(hChannel.ExtOutportList.(subPortName).Index);
        user_signal=hStreamNetInportSignals(length(hChannel.ExtInportNames)+...
        hChannel.UserInportList.(subPortName).Index);


        pirelab.getFIFOFWFTComp(hN,[user_signal,fifo_push,port_tready],port_signal,...
        obj.FIFOSize,sprintf('%s_%s_%s_OUT',hElab.TopNetName,obj.FIFOName,subPortName),obj.RamCorePrefix,false);
    end


    obj.elaborateMasterReadyLogic(hN,hChannel,internal_ready,hStreamNetOutportSignals);

end



