function elaborateStreamMaster(obj,hElab,hChannel,...
    hN,hStreamNetInportSignals,hStreamNetOutportSignals,multiRateCountEnable,multiRateCountValue)



























    ufix1Type=pir_ufixpt_t(1,0);
    data_type=hStreamNetInportSignals(2).Type;


    port_tready=hStreamNetInportSignals(1);

    port_tdata=hStreamNetOutportSignals(1);
    port_tvalid=hStreamNetOutportSignals(2);
    port_tlast=hStreamNetOutportSignals(3);
    port_tuser=hStreamNetOutportSignals(4);


    user_data=hN.addSignal(data_type,'user_data');
    user_valid=hN.addSignal(ufix1Type,'user_valid');
    user_sof=hN.addSignal(ufix1Type,'user_sof');
    user_eol=hN.addSignal(ufix1Type,'user_eol');

    AdapterOutInput=hStreamNetInportSignals(2:end);
    AdapterOutOutput=[user_data,user_valid,user_eol,user_sof];

    pirtarget.getVHTAdapterOutNetwork(hN,AdapterOutInput,AdapterOutOutput);



    [internal_ready,fifo_push]=obj.elaborateMasterDataFIFO(hN,hElab,hChannel,...
    user_data,user_valid,port_tready,...
    port_tdata,port_tvalid,...
    multiRateCountEnable,multiRateCountValue);


    pirelab.getFIFOFWFTComp(hN,[user_sof,fifo_push,port_tready],port_tuser,...
    obj.FIFOSize,sprintf('%s_%s_sof_out',hElab.TopNetName,obj.FIFOName),obj.RamCorePrefix,false);

    pirelab.getFIFOFWFTComp(hN,[user_eol,fifo_push,port_tready],port_tlast,...
    obj.FIFOSize,sprintf('%s_%s_eol_out',hElab.TopNetName,obj.FIFOName),obj.RamCorePrefix,false);


    obj.elaborateMasterReadyLogic(hN,hChannel,internal_ready,hStreamNetOutportSignals);

end


