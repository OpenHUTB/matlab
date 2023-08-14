function hC=getAddrDecoderStrobeRegComp(hN,hInSignals,hOutSignals,addrNum,regID,needPipeReg)














    data_in=hInSignals(1);
    addr_in=hInSignals(2);
    wr_enb=hInSignals(3);

    reg_out=hOutSignals(1);

    outportType=reg_out.Type;

    ufix1Type=pir_ufixpt_t(1,0);


    strobe_in=hN.addSignal(outportType,sprintf('strobe_in_%s',regID));
    pirelab.getDTCComp(hN,data_in,strobe_in,'Floor','Wrap','SI');


    decode_sel=hN.addSignal(ufix1Type,sprintf('decode_sel_%s',regID));
    pirelab.getCompareToValueComp(hN,addr_in,decode_sel,'==',addrNum);


    if needPipeReg
        decode_sel_pipe=hN.addSignal(ufix1Type,sprintf('decode_sel_pipe_%s',regID));
        pirelab.getUnitDelayComp(hN,decode_sel,decode_sel_pipe,sprintf('sel_pipe_%s',regID));
        hSelSignal=decode_sel_pipe;
    else
        hSelSignal=decode_sel;
    end


    strobe_sel=hN.addSignal(ufix1Type,sprintf('strobe_sel_%s',regID));
    pirelab.getBitwiseOpComp(hN,[hSelSignal,wr_enb],strobe_sel,'AND');


    const_zero=hN.addSignal(outportType,'const_zero');
    pirelab.getConstComp(hN,const_zero,0);
    strobe_sw=hN.addSignal(outportType,sprintf('strobe_sw_%s',regID));
    pirelab.getSwitchComp(hN,[strobe_in,const_zero],...
    strobe_sw,strobe_sel,'decode_switch','~=');


    hC=pirelab.getUnitDelayComp(hN,strobe_sw,reg_out);


