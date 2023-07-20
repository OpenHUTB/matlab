function elaborateStreamSlave(obj,hElab,hChannel,...
    hN,hStreamNetInportSignals,hStreamNetOutportSignals,multiRateCountEnable,multiRateCountValue)






































    ufix1Type=pir_ufixpt_t(1,0);


    port_tdata=hStreamNetInportSignals(1);
    port_tvalid=hStreamNetInportSignals(2);

    port_tready=hStreamNetOutportSignals(1);
    user_data=hStreamNetOutportSignals(2);



    [fifo_rd_ack,stream_in_user_ready,stream_in_user_data,stream_in_user_valid]=...
    obj.elaborateSlaveDataFIFO(hN,hElab,...
    port_tdata,port_tvalid,port_tready,multiRateCountEnable,multiRateCountValue);

    pirelab.getWireComp(hN,stream_in_user_data,user_data);


    if hChannel.isSampleControlBusAssigned

        port_tlast=hStreamNetInportSignals(3);

        user_start=hStreamNetOutportSignals(3);
        user_end=hStreamNetOutportSignals(4);
        user_valid=hStreamNetOutportSignals(5);

        user_tlast=hN.addSignal(ufix1Type,'user_tlast');


        pirelab.getFIFOFWFTComp(hN,[port_tlast,port_tvalid,fifo_rd_ack],user_tlast,...
        obj.FIFOSize,sprintf('%s_%s_TLAST',hElab.TopNetName,obj.FIFOName),obj.RamCorePrefix,false);

        pirelab.getWireComp(hN,user_tlast,user_end);


        start_counter_rst=hN.addSignal(ufix1Type,'start_counter_rst');
        start_counter_enb=hN.addSignal(ufix1Type,'start_counter_enb');
        start_counter_out=hN.addSignal(ufix1Type,'start_counter_out');
        start_counter_cmp=hN.addSignal(ufix1Type,'start_counter_cmp');
        pirelab.getBitwiseOpComp(hN,[stream_in_user_valid,user_tlast],start_counter_rst,'AND');
        pirelab.getBitwiseOpComp(hN,[stream_in_user_valid,start_counter_cmp],start_counter_enb,'AND');
        pirelab.getCounterComp(hN,[start_counter_rst,start_counter_enb],start_counter_out,...
        'Free running',0,1,1,true,false,true,false,'start_counter');
        pirelab.getCompareToValueComp(hN,start_counter_out,start_counter_cmp,'==',0);

        pirelab.getWireComp(hN,start_counter_cmp,user_start);
    else

        user_valid=hStreamNetOutportSignals(3);

        if hChannel.isTLASTPortAssigned

            port_tlast=hStreamNetInportSignals(3);
            user_tlast=hStreamNetOutportSignals(4);


            pirelab.getFIFOFWFTComp(hN,[port_tlast,port_tvalid,fifo_rd_ack],user_tlast,...
            obj.FIFOSize,sprintf('%s_%s_TLAST',hElab.TopNetName,obj.FIFOName),obj.RamCorePrefix,false);
        end
    end

    pirelab.getWireComp(hN,stream_in_user_valid,user_valid);


    for ii=1:length(hChannel.UserAssignedOutportPorts)
        subPortID=hChannel.UserAssignedOutportPorts{ii};
        hSubPort=hChannel.getPort(subPortID);

        if~hdlturnkey.interface.AXI4Stream.isSideBandPortGroup(hSubPort)
            continue;
        end


        subPortName=hSubPort.PortName;
        port_signal=hStreamNetInportSignals(hChannel.ExtInportList.(subPortName).Index);
        user_signal=hStreamNetOutportSignals(length(hChannel.ExtOutportNames)+...
        hChannel.UserOutportList.(subPortName).Index);


        pirelab.getFIFOFWFTComp(hN,[port_signal,port_tvalid,fifo_rd_ack],user_signal,...
        obj.FIFOSize,sprintf('%s_%s_%s',hElab.TopNetName,obj.FIFOName,subPortName),obj.RamCorePrefix,false);
    end


    internal_ready=obj.elaborateSlaveReadyLogic(hN,hChannel,hStreamNetInportSignals);

    pirelab.getWireComp(hN,internal_ready,stream_in_user_ready);

end

