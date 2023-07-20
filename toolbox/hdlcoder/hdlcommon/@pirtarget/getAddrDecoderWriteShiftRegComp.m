function[hC,reg_enb]=getAddrDecoderWriteShiftRegComp(hN,hInSignals,hOutSignals,addrStart,addrLength,regID,addrBlockSize,needPipeReg,init_value)












    if nargin<8
        needPipeReg=false;
    end

    if nargin<7
        addrBlockSize=0;
    end

    data_write=hInSignals(1);
    addr_in=hInSignals(2);
    wr_enb=hInSignals(3);

    reg_out=hOutSignals(1);

    ufix1Type=pir_ufixpt_t(1,0);


    [dimLen,outportBaseType]=pirelab.getVectorTypeInfo(reg_out);
    if dimLen~=addrLength
        error(message('hdlcommon:workflow:VectorSizeMismatch',sprintf('write_decoder_sr_%s',regID)));
    end


    data_in=hN.addSignal(outportBaseType,sprintf('data_in_%s',regID));
    pirelab.getDTCComp(hN,data_write,data_in,'Floor','Wrap','SI');


    addr_match=hN.addSignal(ufix1Type,sprintf('addr_match_%s',regID));


    pirtarget.getAddrBlockDetectionComp(hN,addr_in,addr_match,addrStart,addrBlockSize,regID);


    if needPipeReg
        addr_match_pipe=hN.addSignal(ufix1Type,sprintf('addr_match_pipe_%s',regID));
        pirelab.getUnitDelayComp(hN,addr_match,addr_match_pipe,sprintf('match_pipe_%s',regID));
        hAddrMatchSignal=addr_match_pipe;
    else
        hAddrMatchSignal=addr_match;
    end




    reg_enb=hN.addSignal(ufix1Type,sprintf('reg_enb_%s',regID));
    pirelab.getBitwiseOpComp(hN,[hAddrMatchSignal,wr_enb],reg_enb,'AND');


    hC=pirelab.getTapDelayEnabledComp(hN,data_in,reg_out,reg_enb,addrLength,sprintf('tapdelay_%s',regID),init_value);


end


