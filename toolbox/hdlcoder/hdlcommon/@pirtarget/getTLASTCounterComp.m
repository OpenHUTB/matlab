function hC=getTLASTCounterComp(hN,hInSignals,hOutSignals,counterBitWidth)







    counterType=pir_ufixpt_t(counterBitWidth,0);
    ufix1Type=pir_ufixpt_t(1,0);

    user_VALID=hInSignals(1);
    reg_packet_size=hInSignals(2);
    reg_packet_size_strobe=hInSignals(3);
    port_TLAST=hOutSignals;




    TLAST_reset=hN.addSignal(ufix1Type,'reset_TLAST');
    pirelab.getBitwiseOpComp(hN,[reg_packet_size_strobe,port_TLAST],TLAST_reset,'OR');


    tlast_counter_out=hN.addSignal(counterType,'tlast_counter_out');
    hCounterInSignals=[TLAST_reset,user_VALID];
    hC=pirelab.getCounterComp(hN,hCounterInSignals,tlast_counter_out,...
    'Free running',0,1,[],true,false,true,false,'tlast_counter');


    const_1=hN.addSignal(counterType,'const_1');
    tlast_rel_out=hN.addSignal(ufix1Type,'tlast_rel_out');
    tlast_size_value=hN.addSignal(counterType,'tlast_size_value');
    pirelab.getConstComp(hN,const_1,1);
    pirelab.getSubComp(hN,[reg_packet_size,const_1],tlast_size_value);
    pirelab.getRelOpComp(hN,[tlast_counter_out,tlast_size_value],tlast_rel_out,'==');


    pirelab.getBitwiseOpComp(hN,[user_VALID,tlast_rel_out],port_TLAST,'AND');


