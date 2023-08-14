function[hDecodeReadSignal,muxCounter,readDelayCount]=elabAddrDecoderWriteModule(...
    hN,hElab,hAddr,hDecodeReadSignal,muxCounter,readDelayCount,AXI4RegisterReadbackPipelineRatioValue,registerWidth)














    data_write=hN.PirInputSignals(1);
    addr_sel=hN.PirInputSignals(2);
    wr_enb=hN.PirInputSignals(3);
    ufix1Type=pir_ufixpt_t(1,0);




    AXI4RegisterReadback=hElab.hTurnkey.hD.hIP.getAXI4ReadbackEnable;



    if strcmpi(hAddr.AddressType,'USER')
        PortlevelAXI4RegisterReadback=hAddr.PortlevelRegisterReadback;
    else
        PortlevelAXI4RegisterReadback='inherit';
    end








    if strcmpi(hAddr.AddressType,'USER')
        if strcmpi(PortlevelAXI4RegisterReadback,'on')
            AXI4RegisterReadbackEnable=1;
        elseif strcmpi(PortlevelAXI4RegisterReadback,'off')
            AXI4RegisterReadbackEnable=0;
        else
            AXI4RegisterReadbackEnable=AXI4RegisterReadback;
        end
    else
        AXI4RegisterReadbackEnable=AXI4RegisterReadback;
    end


    portID=hAddr.FlattenedPortName;
    addrStart=hAddr.AddressStart;
    addrLength=hAddr.AddressLength;
    portVectorSize=hAddr.PortVectorSize;
    portWordLength=hAddr.PortWordLength;



    if AXI4RegisterReadbackEnable
        read_in=hDecodeReadSignal;
        readOutType=hDecodeReadSignal.Type;
    end


    hInternalSignals=hAddr.ElabInternalSignal;
    if portVectorSize~=length(hInternalSignals)
        error(message('hdlcommon:workflow:VectorSizeMismatch',sprintf('write_decoder_%s',portID)));
    end


    outPortName=sprintf('write_%s',portID);
    hDecoderNetOutSignal=hAddr.addPirSignal(hN,outPortName);
    outportType=hDecoderNetOutSignal.Type;


    if hAddr.NeedBitPacking
        packedWordLength=hAddr.PackedWordLength;
        packedVectorSize=hAddr.PackedVectorSize;
        packedType=pir_ufixpt_t(packedWordLength,0);
        registerType=pirelab.getPirVectorType(packedType,packedVectorSize);
    else
        registerType=outportType;
    end



    write_reg=hN.addSignal(registerType,sprintf('write_reg_%s',portID));
    needPipeReg=hAddr.AddrDecoderPipeline;


    init_value=hAddr.InitValue;



    hIOPortList=hElab.hTurnkey.hTable.hIOPortList;
    if hIOPortList.isValidPortName(portID)


        hIOPort=hIOPortList.getIOPort(portID);
        if hIOPort.isDouble
            init_value=double(init_value);
            init_value=typecast(init_value,'uint64');
        elseif hIOPort.isSingle
            init_value=single(init_value);
            init_value=typecast(init_value,'uint32');
        end
    else

        if outportType.isFloatType
            error(message('hdlcommon:workflow:UnsupportedWrapperPortDataType',portID));
        end
    end


    init_value=pirelab.getTypeInfoAsFi(outportType,'Floor','Wrap',init_value);



    if hAddr.NeedBitPacking
        packNumber=floor(packedWordLength/portWordLength);
        if packNumber~=packedWordLength/portWordLength
            error(message('hdlcommon:workflow:BitPackingUnsupported',sprintf('bitpacking_%s',portID)));
        end




        init_value(end+1:packNumber*packedVectorSize)=init_value(end);


        packedFiType=pirelab.getTypeInfoAsFi(packedType,'Floor','Wrap');
        packed_init_value=zeros(packedVectorSize,1,'like',packedFiType);


























        for ii=1:packedVectorSize
            lidx=(ii-1)*packNumber+1;
            ridx=ii*packNumber;


            packed_init_value(ii)=bitconcat(init_value(ridx:-1:lidx));
        end


        init_value=packed_init_value;
    end


    if hAddr.UseShiftRegister

        tInSignals=[data_write,addr_sel,wr_enb];
        addrBlockSize=hAddr.AddrBlockSize;
        [~,reg_enb]=pirtarget.getAddrDecoderWriteShiftRegComp(hN,tInSignals,write_reg,addrStart,addrLength,portID,addrBlockSize,needPipeReg,init_value);
    else



        tInSignals=[data_write,addr_sel,wr_enb];
        tOutSignals=write_reg;
        [~,addr_sel_sigs,reg_enb]=pirtarget.getAddrDecoderWriteRegComp(hN,tInSignals,tOutSignals,addrStart,addrLength,portID,registerWidth,...
        needPipeReg,AXI4RegisterReadbackEnable,init_value);
    end


    if~hAddr.NeedStrobe||hElab.hTurnkey.isCoProcessorMode

        hRegOutSignal=write_reg;
    else

        addrStrobe=hAddr.AddressStrobe;
        strobe_reg=hN.addSignal(ufix1Type,sprintf('strobe_reg_%s',portID));
        pirtarget.getAddrDecoderStrobeRegComp(hN,tInSignals,strobe_reg,addrStrobe,portID,needPipeReg);


        sync_reg=hN.addSignal(registerType,sprintf('sync_reg_%s',portID));
        pirelab.getUnitDelayEnabledComp(hN,write_reg,sync_reg,strobe_reg,sprintf('sync_reg_%s',portID),init_value);


        hRegOutSignal=sync_reg;
    end



    if AXI4RegisterReadbackEnable&&~hAddr.UseShiftRegister
        decode_rd=hN.addSignal(readOutType,sprintf('decode_rd_%s',portID));
        tInSignals=[hRegOutSignal,addr_sel,read_in];
        tOutSignals=decode_rd;
        needPipeReg=false;
        readBack=true;


        [~,muxCounter,readDelayCount]=pirtarget.getAddrDecoderReadRegComp(hN,tInSignals,tOutSignals,addrStart,addrLength,portID,...
        muxCounter,readDelayCount,AXI4RegisterReadbackPipelineRatioValue,registerWidth,needPipeReg,readBack,addr_sel_sigs);
        hDecodeReadSignal=decode_rd;
    end


    if hAddr.NeedBitPacking
        pirtarget.getBitUnpackingComp(hN,hRegOutSignal,hDecoderNetOutSignal,portID);
    else
        pirelab.getWireComp(hN,hRegOutSignal,hDecoderNetOutSignal);
    end


    if hAddr.RequestStrobePort

        strobeOutPortName=sprintf('strobe_%s',portID);
        hStrobeSignal=hAddr.ElabStrobeSignal;


        pirtarget.connectSignals(hElab,...
        {reg_enb},{hStrobeSignal},strobeOutPortName);
    end


    if hElab.hTurnkey.hD.isIPCoreGen
        pirtarget.connectSignals(hElab,...
        {hDecoderNetOutSignal},hInternalSignals,outPortName);
    else

        newSigName=sprintf('inst_%s',portID);
        pirtarget.connectSignalsWithHierarchy(...
        {hDecoderNetOutSignal},hInternalSignals,'up',outPortName,newSigName);
    end

end
