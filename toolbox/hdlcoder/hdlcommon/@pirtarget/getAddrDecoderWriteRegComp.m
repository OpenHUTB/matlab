function[hC,decode_sel_sigs,reg_enb]=getAddrDecoderWriteRegComp(hN,hInSignals,hOutSignals,addrStart,addrLength,regID,...
    registerWidth,needPipeReg,saveDecodeSelSigs,init_value)























    if nargin<10
        init_value=0;
    end

    if nargin<9
        saveDecodeSelSigs=false;
    end

    if nargin<8
        needPipeReg=false;
    end

    if nargin<7
        registerWidth=32;
    end

    data_write=hInSignals(1);
    addr_in=hInSignals(2);
    wr_enb=hInSignals(3);
    reg_out=hOutSignals(1);


    init_value=pirelab.getTypeInfoAsFi(reg_out.Type,'Floor','Wrap',init_value);


    [dimLen,outportBaseType]=pirelab.getVectorTypeInfo(reg_out);

    outportWordLength=outportBaseType.WordLength;
    dataSections=ceil(double(outportWordLength)/registerWidth);

    if dimLen*dataSections~=addrLength
        error(message('hdlcommon:workflow:VectorSizeMismatch',sprintf('write_decoder_%s',regID)));
    end

    if outportWordLength>registerWidth

        dataportBaseType=pir_ufixpt_t(registerWidth,0);
        concatBaseType=pir_ufixpt_t(outportWordLength,0);
    else
        dataportBaseType=outportBaseType;
        concatBaseType=outportBaseType;
    end


    data_in=hN.addSignal(dataportBaseType,sprintf('data_in_%s',regID));
    pirelab.getDTCComp(hN,data_write,data_in,'Floor','Wrap','SI');



    remainingBits=mod(outportWordLength,dataportBaseType.WordLength);
    hasRemainingBits=(remainingBits~=0);
    if hasRemainingBits
        remainderBaseType=pir_ufixpt_t(remainingBits,0);
        data_in_rem=hN.addSignal(remainderBaseType,sprintf('data_in_rem_%s',regID));
        pirelab.getDTCComp(hN,data_write,data_in_rem,'Floor','Wrap','SI');
    end




    write_concats=hdlhandles(dimLen,1);
    addrNum=addrStart;

    decode_sel_sigs=containers.Map('KeyType','uint32','ValueType','any');
    for ii=1:dimLen

        write_concats(ii)=hN.addSignal(outportBaseType,sprintf('write_concats_%s_%d',regID,ii));
        data_regs=hdlhandles(dataSections,1);

        msb=uint32(outportWordLength-1);
        lsb=uint32(outportWordLength-registerWidth);
        for jj=1:dataSections
            if hasRemainingBits&&jj==dataSections

                dataRegBaseType=remainderBaseType;
                data_sig=data_in_rem;
            else

                dataRegBaseType=dataportBaseType;
                data_sig=data_in;
            end


            dataRegFiType=numerictype(pirelab.getTypeInfoAsFi(dataRegBaseType));
            initValSlice=bitsliceget(init_value(ii),msb+1,lsb+1);
            initValSlice=reinterpretcast(initValSlice,dataRegFiType);
            msb=msb-registerWidth;
            lsb=lsb-registerWidth;


            data_regs(jj)=hN.addSignal(dataRegBaseType,sprintf('data_reg_%s_%d_%d',regID,ii,jj));
            tInSignals=[data_sig,addr_in,wr_enb];
            tOutSignals=data_regs(jj);
            if saveDecodeSelSigs
                [hC,decode_sel_sigs(addrNum),reg_enb]=getAddrDecoderWriteLogic(hN,tInSignals,tOutSignals,addrNum,sprintf('%s_%d_%d',regID,ii,jj),needPipeReg,initValSlice);
            else
                [hC,~,reg_enb]=getAddrDecoderWriteLogic(hN,tInSignals,tOutSignals,addrNum,sprintf('%s_%d_%d',regID,ii,jj),needPipeReg,initValSlice);
            end


            addrNum=addrNum+1;
        end


        data_concat=hN.addSignal(concatBaseType,sprintf('data_concat_%s_%d',regID,ii));
        pirelab.getBitConcatComp(hN,data_regs,data_concat,sprintf('bit_concat_%s_%d',regID,ii));


        pirelab.getDTCComp(hN,data_concat,write_concats(ii),'Floor','Wrap','SI');
    end


    pirelab.getMuxComp(hN,write_concats,reg_out);

end

function[hC,decode_sel,reg_enb]=getAddrDecoderWriteLogic(hN,hInSignals,hOutSignals,addrNum,regID,needPipeReg,init_value)








    if nargin<7
        init_value=0;
    end

    data_in=hInSignals(1);
    addr_in=hInSignals(2);
    wr_enb=hInSignals(3);

    reg_out=hOutSignals(1);


    init_value=pirelab.getTypeInfoAsFi(reg_out.Type,'Floor','Wrap',init_value);

    ufix1Type=pir_ufixpt_t(1,0);


    decode_sel=hN.addSignal(ufix1Type,sprintf('decode_sel_%s',regID));
    pirelab.getCompareToValueComp(hN,addr_in,decode_sel,'==',addrNum);


    if needPipeReg
        decode_sel_pipe=hN.addSignal(ufix1Type,sprintf('decode_sel_pipe_%s',regID));
        pirelab.getUnitDelayComp(hN,decode_sel,decode_sel_pipe,sprintf('sel_pipe_%s',regID));
        hSelSignal=decode_sel_pipe;
    else
        hSelSignal=decode_sel;
    end




    reg_enb=hN.addSignal(ufix1Type,sprintf('reg_enb_%s',regID));
    pirelab.getBitwiseOpComp(hN,[hSelSignal,wr_enb],reg_enb,'AND');


    hC=pirelab.getUnitDelayEnabledComp(hN,data_in,...
    reg_out,reg_enb,sprintf('reg_%s',regID),init_value);

end
