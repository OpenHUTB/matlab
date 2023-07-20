function hStreamNet=getVDMAControllerNetwork(...
    hN,topInSignals,topOutSignals,hPirInstance,networkName,...
    extra_delay)




    ufix1Type=pir_ufixpt_t(1,0);

    top_dut_enable=topInSignals(1);
    top_cnt_enable=topInSignals(2);
    top_num_of_col=topInSignals(3);
    top_num_of_row=topInSignals(4);

    top_fifo_out_sof=topOutSignals(1);
    top_fifo_out_eol=topOutSignals(2);
    top_eof_out=topOutSignals(3);

    hStreamNet=pirelab.createNewNetwork(...
    'PirInstance',hPirInstance,...
    'Network',hN,...
    'Name',networkName,...
    'InportNames',{'dut_enable','cnt_enable','num_of_col','num_of_row'},...
    'InportTypes',[top_dut_enable.Type,top_cnt_enable.Type,top_num_of_col.Type,top_num_of_row.Type],...
    'InportRates',[top_dut_enable.SimulinkRate,top_cnt_enable.SimulinkRate,top_num_of_col.SimulinkRate,top_num_of_row.SimulinkRate],...
    'OutportNames',{'sof_out','eol_out','eof_out'},...
    'OutportTypes',[top_fifo_out_sof.Type,top_fifo_out_eol.Type,top_eof_out.Type]...
    );


    dut_enable=hStreamNet.PirInputSignals(1);
    cnt_enable=hStreamNet.PirInputSignals(2);
    num_of_col=hStreamNet.PirInputSignals(3);
    num_of_row=hStreamNet.PirInputSignals(4);

    sof_out=hStreamNet.PirOutputSignals(1);
    eol_out=hStreamNet.PirOutputSignals(2);
    eof_out=hStreamNet.PirOutputSignals(3);


    [~,clkenb,~]=hStreamNet.getClockBundle(dut_enable,1,1,0);
    const_1=hStreamNet.addSignal(ufix1Type,'const_1');
    pirelab.getConstComp(hStreamNet,const_1,1);
    pirelab.getWireComp(hStreamNet,const_1,clkenb);


    hVCNet=pirelab.createNewNetwork(...
    'PirInstance',hPirInstance,...
    'Network',hStreamNet,...
    'Name',sprintf('%s_core',networkName),...
    'InportNames',{'cnt_enable','num_of_col','num_of_row'},...
    'InportTypes',[top_cnt_enable.Type,top_num_of_col.Type,top_num_of_row.Type],...
    'InportRates',[top_cnt_enable.SimulinkRate,top_num_of_col.SimulinkRate,top_num_of_row.SimulinkRate],...
    'OutportNames',{'sof_out','eol_out','eof_out'},...
    'OutportTypes',[top_fifo_out_sof.Type,top_fifo_out_eol.Type,top_eof_out.Type]...
    );

    vc_cnt_enable=hVCNet.PirInputSignals(1);
    vc_num_of_col=hVCNet.PirInputSignals(2);
    vc_num_of_row=hVCNet.PirInputSignals(3);

    vc_sof_out=hVCNet.PirOutputSignals(1);
    vc_eol_out=hVCNet.PirOutputSignals(2);
    vc_eof_out=hVCNet.PirOutputSignals(3);


    [~,clkenb,~]=hVCNet.getClockBundle(vc_cnt_enable,1,1,0);
    pirelab.getWireComp(hVCNet,vc_cnt_enable,clkenb);

    hVCNet.addComponent2(...
    'kind','cgireml',...
    'Name','vsctrl',...
    'InputSignals',[vc_num_of_col,vc_num_of_row],...
    'OutputSignals',[vc_sof_out,vc_eol_out,vc_eof_out],...
    'EMLFileName','hdleml_vdma_controller'...
    );


    sof_out_ctrl=hStreamNet.addSignal(ufix1Type,'sof_out_ctrl');
    eol_out_ctrl=hStreamNet.addSignal(ufix1Type,'eol_out_ctrl');
    eof_out_ctrl=hStreamNet.addSignal(ufix1Type,'eof_out_ctrl');
    hInSignals=[cnt_enable,num_of_col,num_of_row];
    hOutSignals=[sof_out_ctrl,eol_out_ctrl,eof_out_ctrl];
    pirelab.instantiateNetwork(hStreamNet,hVCNet,hInSignals,hOutSignals,...
    sprintf('%s_core_inst',networkName));


    pirelab.getIntDelayEnabledComp(hStreamNet,sof_out_ctrl,sof_out,dut_enable,extra_delay);
    pirelab.getIntDelayEnabledComp(hStreamNet,eol_out_ctrl,eol_out,dut_enable,extra_delay);
    pirelab.getUnitDelayComp(hStreamNet,eof_out_ctrl,eof_out);

end

