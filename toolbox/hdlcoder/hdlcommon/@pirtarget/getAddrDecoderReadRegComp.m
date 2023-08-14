function[hC,muxCounter,readDelayCount]=getAddrDecoderReadRegComp(hN,hInSignals,hOutSignals,addrStart,addrLength,regID,...
    muxCounter,readDelayCount,AXI4RegisterReadbackPipelineRatioValue,registerWidth,needPipeReg,useDecodeSelSigs,decodeSelSigs)


























    if nargin<12
        useDecodeSelSigs=false;
    end

    if nargin<11
        needPipeReg=false;
    end

    if nargin<10
        registerWidth=32;
    end

    data_read=hInSignals(1);
    addr_in=hInSignals(2);
    read_in=hInSignals(3);

    read_out=hOutSignals(1);


    readDataType=read_out.Type;


    [dimLen,readRegBaseType]=pirelab.getVectorTypeInfo(data_read);

    readRegWordLength=readRegBaseType.WordLength;
    dataSections=ceil(double(readRegWordLength)/registerWidth);

    if dimLen*dataSections~=addrLength
        error(message('hdlcommon:workflow:VectorSizeMismatch',sprintf('read_decoder_%s',regID)));
    end



    data_slice=hdlhandles(dataSections,1);
    readVecType=pirelab.getPirVectorType(readDataType,dimLen);
    msb=uint32(readRegWordLength-1);
    lsb=uint32(readRegWordLength-registerWidth);
    for ii=1:dataSections

        if readRegWordLength>registerWidth
            sliceType=pir_ufixpt_t(msb-lsb+1,0);
        else
            sliceType=readRegBaseType;
        end
        sliceVecType=pirelab.getPirVectorType(sliceType,dimLen);
        read_reg_slice=hN.addSignal(sliceVecType,sprintf('read_reg_slice_%s_%d',regID,ii));
        pirelab.getBitSliceComp(hN,data_read,read_reg_slice,msb,lsb,sprintf('bit_slice_%s_%d',regID,ii));


        data_slice(ii)=hN.addSignal(readVecType,sprintf('data_slice_%s_%d',regID,ii));
        pirelab.getDTCComp(hN,read_reg_slice,data_slice(ii),'Floor','Wrap','SI');
        msb=msb-registerWidth;
        lsb=lsb-registerWidth;
    end




    hDecodeReadInSignal=read_in;
    for ii=1:dataSections
        addrNum=addrStart;
        data_in=hdlhandles(dimLen,1);
        for jj=1:dimLen

            data_in(jj)=hN.addSignal(readDataType,sprintf('data_in_%s_%d_%d',regID,ii,jj));
            decode_rd=hN.addSignal(readDataType,sprintf('decode_rd_%s_%d_%d',regID,ii,jj));
            tInSignals=[data_in(jj),addr_in,hDecodeReadInSignal];
            [muxCounter,readDelayCount,insertMuxPipelineRegister]=getMuxReadDelayCount(muxCounter,readDelayCount,AXI4RegisterReadbackPipelineRatioValue);
            if useDecodeSelSigs
                hC=getAddrDecoderReadLogic(hN,tInSignals,decode_rd,addrNum,sprintf('%s_%d_%d',regID,ii,jj),needPipeReg,insertMuxPipelineRegister,readDelayCount,useDecodeSelSigs,decodeSelSigs(addrNum));
            else
                hC=getAddrDecoderReadLogic(hN,tInSignals,decode_rd,addrNum,sprintf('%s_%d_%d',regID,ii,jj),needPipeReg,insertMuxPipelineRegister,readDelayCount);
            end


            hDecodeReadInSignal=decode_rd;
            addrNum=addrNum+dataSections;
        end

        pirelab.getDemuxComp(hN,data_slice(ii),data_in);


        addrStart=addrStart+1;
    end


    pirelab.getWireComp(hN,hDecodeReadInSignal,read_out);

end


function hC=getAddrDecoderReadLogic(hN,hInSignals,hOutSignals,addrNum,regID,needPipeReg,insertMuxPipelineRegister,readDelayCount,useDecodeSelSigs,decodeSelSig)











    if nargin<9
        useDecodeSelSigs=false;
    end

    data_read=hInSignals(1);
    addr_in=hInSignals(2);
    read_in=hInSignals(3);
    read_inType=read_in.Type;

    if(insertMuxPipelineRegister)
        opt_reg_out=hOutSignals(1);
        read_out=hN.addSignal(read_inType,sprintf('read_opt_reg_out_%s_%d',regID));
    else
        read_out=hOutSignals(1);
    end

    ufix1Type=pir_ufixpt_t(1,0);






    if useDecodeSelSigs
        decode_sel=decodeSelSig;
    else
        decode_sel=hN.addSignal(ufix1Type,sprintf('decode_sel_%s',regID));
        pirelab.getCompareToValueComp(hN,addr_in,decode_sel,'==',addrNum);
    end


    if needPipeReg
        decode_sel_pipe=hN.addSignal(ufix1Type,sprintf('decode_sel_pipe_%s',regID));
        pirelab.getUnitDelayComp(hN,decode_sel,decode_sel_pipe,sprintf('sel_pipe_%s',regID));
        hSelSignal=decode_sel_pipe;
    else
        hSelSignal=decode_sel;
    end

    hSelSignal_type=hSelSignal.Type;




    data_read_middle=hN.addSignal(read_inType,sprintf('reg_data_read_middle_%s_%d',regID));
    hSelSignalDelay=hN.addSignal(hSelSignal_type,sprintf('hSelSignalDelay_%s_%d',regID));





    if((readDelayCount>0)&&(insertMuxPipelineRegister==1))
        inputDelayCount=readDelayCount-1;
    elseif((readDelayCount>0)&&(insertMuxPipelineRegister==0))
        inputDelayCount=readDelayCount;
    else
        inputDelayCount=0;
    end


    pirelab.getIntDelayComp(hN,data_read,data_read_middle,inputDelayCount,'reg_data_read_middle');
    pirelab.getIntDelayComp(hN,hSelSignal,hSelSignalDelay,inputDelayCount,'reg_hSelSignalDelay');


    hC=pirelab.getSwitchComp(hN,[data_read_middle,read_in],...
    read_out,hSelSignalDelay,sprintf('decode_switch_%s',regID),'~=');




    if(insertMuxPipelineRegister)
        pirelab.getUnitDelayComp(hN,read_out,opt_reg_out,sprintf('read_opt_reg_%s_%d',regID));
    end

end