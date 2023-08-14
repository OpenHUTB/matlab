function[hDecodeReadSignal,muxCounter,readDelayCount]=elabAddrDecoderReadModule(...
    hN,hElab,hAddr,hDecodeReadSignal,muxCounter,readDelayCount,AXI4RegisterReadbackPipelineRatioValue,registerWidth)














    data_write=hN.PirInputSignals(1);
    addr_sel=hN.PirInputSignals(2);
    wr_enb=hN.PirInputSignals(3);
    rd_enb=hN.PirInputSignals(4);

    ufix1Type=pir_ufixpt_t(1,0);
    readDataType=hDecodeReadSignal.Type;


    portID=hAddr.FlattenedPortName;
    addrStart=hAddr.AddressStart;
    addrLength=hAddr.AddressLength;
    portVectorSize=hAddr.PortVectorSize;


    hInternalSignals=hAddr.ElabInternalSignal;
    if portVectorSize~=length(hInternalSignals)
        error(message('hdlcommon:workflow:VectorSizeMismatch',sprintf('read_decoder_%s',portID)));
    end


    inPortName=sprintf('read_%s',portID);
    hDecoderNetInSignal=hAddr.addPirSignal(hN,inPortName);
    inportType=hDecoderNetInSignal.Type;


    if hAddr.NeedBitPacking
        packedWordLength=hAddr.PackedWordLength;
        packedVectorSize=hAddr.PackedVectorSize;
        packedType=pir_ufixpt_t(packedWordLength,0);
        registerType=pirelab.getPirVectorType(packedType,packedVectorSize);
    else
        registerType=inportType;
    end


    if hAddr.NeedBitPacking
        hPackOutSignal=hN.addSignal(registerType,sprintf('bitpacking_%s',portID));
        pirtarget.getBitPackingComp(hN,hDecoderNetInSignal,hPackOutSignal,portID);
    else
        hPackOutSignal=hDecoderNetInSignal;
    end


    needPipeReg=hAddr.AddrDecoderPipeline;
    needStrobe=false;
    if hElab.hTurnkey.isCoProcessorMode

        if hAddr.isDUTAddress
            needStrobe=true;
            hStrobeSig=hN.addSignal(ufix1Type,'cop_reg_strobe');
            hElab.connectSignalFrom('cop_reg_strobe',hStrobeSig);
        end
    else
        if hAddr.NeedStrobe

            needStrobe=true;
            addrStrobe=hAddr.AddressStrobe;
            hStrobeSig=hN.addSignal(ufix1Type,sprintf('strobe_reg_%s',portID));
            tInSignals=[data_write,addr_sel,wr_enb];
            pirtarget.getAddrDecoderStrobeRegComp(hN,tInSignals,hStrobeSig,addrStrobe,portID,needPipeReg);
        end
    end


    decode_rd=hN.addSignal(readDataType,sprintf('decode_rd_%s',portID));
    if hAddr.UseShiftRegister

        tInSignals=[hPackOutSignal,addr_sel,hDecodeReadSignal,hStrobeSig,rd_enb];


        addrBlockSize=hAddr.AddrBlockSize;
        pirtarget.getAddrDecoderReadShiftRegComp(hN,tInSignals,decode_rd,addrStart,addrLength,portID,addrBlockSize,needPipeReg);

    else



        if needStrobe

            read_reg=hN.addSignal(registerType,sprintf('sync_reg_%s',portID));
            pirelab.getUnitDelayEnabledComp(hN,hPackOutSignal,read_reg,hStrobeSig,sprintf('reg_%s',portID));
        else

            read_reg=hN.addSignal(registerType,sprintf('read_reg_%s',portID));
            pirelab.getUnitDelayComp(hN,hPackOutSignal,read_reg,sprintf('reg_%s',portID));
        end

        tInSignals=[read_reg,addr_sel,hDecodeReadSignal];
        [~,muxCounter,readDelayCount]=pirtarget.getAddrDecoderReadRegComp(hN,tInSignals,decode_rd,addrStart,addrLength,portID,...
        muxCounter,readDelayCount,AXI4RegisterReadbackPipelineRatioValue,registerWidth,needPipeReg);
    end
    hDecodeReadSignal=decode_rd;


    if hElab.hTurnkey.hD.isIPCoreGen
        pirtarget.connectSignals(hElab,...
        hInternalSignals,{hDecoderNetInSignal},inPortName);
    else

        newSigName=sprintf('inst_%s',portID);
        pirtarget.connectSignalsWithHierarchy(...
        hInternalSignals,{hDecoderNetInSignal},'down',inPortName,newSigName);
    end

end

