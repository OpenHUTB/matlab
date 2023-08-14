function[internal_ready,fifo_push]=elaborateMasterDataFIFO(obj,hN,hElab,hChannel,...
    user_data,user_valid,port_tready,...
    port_tdata,port_tvalid,...
    multiRateCountEnable,multiRateCountValue)




    ufix1Type=pir_ufixpt_t(1,0);

    fifo_push=hN.addSignal(ufix1Type,'fifo_push');
    fifo_empty_data=hN.addSignal(ufix1Type,'fifo_empty_data');
    fifo_afull_data=hN.addSignal(ufix1Type,'fifo_afull_data');
    internal_ready=hN.addSignal(ufix1Type,'internal_ready');
    fifo_port_tready=hN.addSignal(ufix1Type,'fifo_port_tready');




    if multiRateCountEnable
        cntT_master=hN.getType('FixedPoint','Signed',0,...
        'WordLength',8,'FractionLength',0);

        check_cnt_master=hN.addSignal(cntT_master,'count_check_master');

        check_enb_master=hN.addSignal(ufix1Type,'count_match_master');
        out_fifo_push_master=hN.addSignal(ufix1Type,'out_fifo_push_master');

        pirelab.getCounterLimitedComp(hN,check_cnt_master,multiRateCountValue,check_cnt_master.SimulinkRate,'multirate_counter_master');

        pirelab.getCompareToValueComp(hN,check_cnt_master,check_enb_master,...
        '==',multiRateCountValue,'multirate_count_compare_master');
        pirelab.getBitwiseOpComp(hN,[check_enb_master,user_valid],out_fifo_push_master,'AND','new_user_valid_master');
        user_valid=out_fifo_push_master;

        pirelab.getIntDelayComp(hN,port_tready,fifo_port_tready,multiRateCountValue,'multirate_int_delay_port_tready');

    else
        fifo_port_tready=port_tready;
    end


    pirelab.getFIFOFWFTComp(hN,[user_data,fifo_push,fifo_port_tready],[port_tdata,fifo_empty_data,fifo_afull_data],...
    obj.FIFOSize,sprintf('%s_%s_data_OUT',hElab.TopNetName,obj.FIFOName),obj.RamCorePrefix,true,obj.ReadyToValidLatency);


    pirelab.getBitwiseOpComp(hN,fifo_empty_data,port_tvalid,'NOT');


    pirelab.getBitwiseOpComp(hN,fifo_afull_data,internal_ready,'NOT');




























    if hChannel.isReadyPortAssigned


        pirelab.getWireComp(hN,user_valid,fifo_push);
    else

        if hChannel.NeedAutoReadyWiring

            internal_ready_delayed=hN.addSignal(ufix1Type,'internal_ready_delayed');
            pirelab.getIntDelayComp(hN,internal_ready,internal_ready_delayed,obj.ReadyToValidLatency);


            pirelab.getBitwiseOpComp(hN,[internal_ready_delayed,user_valid],fifo_push,'AND');
        else












            pirelab.getWireComp(hN,user_valid,fifo_push);
        end
    end

end


