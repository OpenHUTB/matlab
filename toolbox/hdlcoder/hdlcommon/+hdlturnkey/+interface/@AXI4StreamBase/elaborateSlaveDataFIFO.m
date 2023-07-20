function[fifo_rd_ack,stream_in_user_ready,stream_in_user_data,stream_in_user_valid]=...
    elaborateSlaveDataFIFO(obj,hN,hElab,...
    port_tdata,port_tvalid,port_tready,multiRateCountEnable,multiRateCountValue)




    ufix1Type=pir_ufixpt_t(1,0);
    data_type=port_tdata.Type;


    stream_in_user_ready=hN.addSignal(ufix1Type,'stream_in_user_ready');
    fifo_rd_ack=hN.addSignal(ufix1Type,'fifo_rd_ack');




    if multiRateCountEnable
        cntT_slave=hN.getType('FixedPoint','Signed',0,...
        'WordLength',8,'FractionLength',0);

        check_cnt_slave=hN.addSignal(cntT_slave,'count_check_slave');
        check_enb_slave=hN.addSignal(ufix1Type,'count_match_slave');
        pirelab.getCounterLimitedComp(hN,check_cnt_slave,multiRateCountValue,check_cnt_slave.SimulinkRate,'multirate_counter_slave');
        pirelab.getCompareToValueComp(hN,check_cnt_slave,check_enb_slave,...
        '==',multiRateCountValue,'multirate_count_compare_slave');
        pirelab.getBitwiseOpComp(hN,[check_enb_slave,stream_in_user_ready],fifo_rd_ack,'AND','new_user_ready_slave');

    else
        pirelab.getIntDelayComp(hN,stream_in_user_ready,fifo_rd_ack,obj.ReadyToValidLatency);
    end



    stream_fifo_user_data=hN.addSignal(data_type,'stream_in_fifo_user_data');
    fifo_empty=hN.addSignal(ufix1Type,'fifo_empty');
    fifo_full=hN.addSignal(ufix1Type,'fifo_full');
    DataInSignals=[port_tdata,port_tvalid,fifo_rd_ack];
    DataOutSignals=[stream_fifo_user_data,fifo_empty,fifo_full];

    pirelab.getFIFOFWFTComp(hN,DataInSignals,DataOutSignals,obj.FIFOSize,...
    sprintf('%s_%s_data',hElab.TopNetName,obj.FIFOName),obj.RamCorePrefix,true);



    pirelab.getBitwiseOpComp(hN,fifo_full,port_tready,'NOT');


    stream_in_user_valid=hN.addSignal(ufix1Type,'stream_in_user_valid');
    fifo_empty_neg=hN.addSignal(ufix1Type,'fifo_empty_neg');
    pirelab.getBitwiseOpComp(hN,fifo_empty,fifo_empty_neg,'NOT');




    if multiRateCountEnable
        stream_fifo_en_user_data=hN.addSignal(data_type,'stream_in_fifo_en_user_data');
        pirelab.getUnitDelayEnabledComp(hN,stream_fifo_user_data,stream_fifo_en_user_data,fifo_rd_ack,'multirate_user_data_slave');
        stream_in_user_data=stream_fifo_en_user_data;
        fifo_multirate_empty_neg=hN.addSignal(ufix1Type,'fifo_multirate_empty_neg');
        pirelab.getUnitDelayEnabledComp(hN,fifo_empty_neg,fifo_multirate_empty_neg,fifo_rd_ack,'multirate_user_data_valid');
        fifo_rd_ack_multirate=hN.addSignal(ufix1Type,'fifo_rd_ack_multirate');
        pirelab.getUnitDelayEnabledComp(hN,fifo_rd_ack,fifo_rd_ack_multirate,check_enb_slave,'multirate_fifo_rd_ack');
        pirelab.getBitwiseOpComp(hN,[fifo_multirate_empty_neg,fifo_rd_ack_multirate],stream_in_user_valid,'AND');

    else
        stream_in_user_data=stream_fifo_user_data;
        pirelab.getBitwiseOpComp(hN,[fifo_empty_neg,fifo_rd_ack],stream_in_user_valid,'AND');
    end



end


