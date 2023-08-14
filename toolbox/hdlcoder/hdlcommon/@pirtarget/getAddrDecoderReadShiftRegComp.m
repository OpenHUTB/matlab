function hC=getAddrDecoderReadShiftRegComp(hN,hInSignals,hOutSignals,...
    addrStart,addrLength,regID,addrBlockSize,needPipeReg)

















    if nargin<8
        needPipeReg=false;
    end

    if nargin<7
        addrBlockSize=0;
    end


    if addrLength<=1
        error(message('hdlcommon:workflow:ShiftRegisterScalar'));
    end

    data_read=hInSignals(1);
    addr_in=hInSignals(2);
    read_in=hInSignals(3);
    strobe_in=hInSignals(4);
    rd_enb=hInSignals(5);

    read_out=hOutSignals(1);

    ufix1Type=pir_ufixpt_t(1,0);

    [dimLen,registerBaseType]=pirelab.getVectorTypeInfo(data_read);
    if dimLen~=addrLength
        error(message('hdlcommon:workflow:VectorSizeMismatch',sprintf('read_decoder_sr_%s',regID)));
    end

    readDataType=read_out.Type;


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
    pirelab.getBitwiseOpComp(hN,[hAddrMatchSignal,rd_enb],reg_enb,'AND');


    read_reg=hN.addSignal(registerBaseType,sprintf('read_reg_%s',regID));
    tInSignals=[data_read,strobe_in,reg_enb];
    pireml.getSerializerSingleRateComp(hN,tInSignals,read_reg,sprintf('reg_%s',regID));


    data_in=hN.addSignal(readDataType,sprintf('data_in_%s',regID));
    pirelab.getDTCComp(hN,read_reg,data_in,'Floor','Wrap','SI');


    hC=pirelab.getSwitchComp(hN,[data_in,read_in],...
    read_out,hAddrMatchSignal,sprintf('decode_switch_%s',regID),'~=');

end

