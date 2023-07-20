function elabHDLChannelSynthesizer(this,ChannelSynthImpl,blockInfo)





    insignals=ChannelSynthImpl.PirInputSignals;
    outsignals=ChannelSynthImpl.PirOutputSignals;

    data_out=outsignals(1);
    valid_out=outsignals(2);

    [filterInDT,filterOutDT,OutputCastDT]=getFilterOutDT(this,blockInfo);
    dataIn=insignals(1);
    dataRate=dataIn.simulinkRate;
    dataInType=pirgetdatatypeinfo(dataIn.Type);
    DATA_VECSIZE=dataInType.dims;

    IFFTOut_DT=filterInDT;
    ifftOutType=hdlcoder.tp_complex(IFFTOut_DT);

    filterOutType=hdlcoder.tp_complex(filterOutDT);
    OutputCastType=hdlcoder.tp_complex(OutputCastDT);


    if blockInfo.inMode(2)&&~blockInfo.inResetSS
        syncReset=insignals(3);
        syncReset.SimulinkRate=dataRate;
        resetpin=true;
    else
        syncReset=ChannelSynthImpl.addSignal2('Type',pir_boolean_t,'Name','softReset');
        syncReset.SimulinkRate=dataRate;

        if blockInfo.inResetSS


            syncReset.setSynthResetInsideResetSS;

            blockInfo.inMode(2)=true;
            resetpin=true;
        else
            resetpin=false;


            pirelab.getConstComp(ChannelSynthImpl,syncReset,false);
        end
    end

    hAF=hdlcoder.tpc_arr_factory;
    hAF.addDimension(DATA_VECSIZE);
    hAF.addBaseType(OutputCastType);
    hAF.VectorOrientation='column';
    dType_array1=hdlcoder.tp_array(hAF);
    filterOut_DT=ChannelSynthImpl.addSignal2('Type',dType_array1,'Name','filterOut_DT');
    filterOut_DT.SimulinkRate=dataRate;

    hAF=hdlcoder.tpc_arr_factory;
    hAF.addDimension(DATA_VECSIZE);
    hAF.addBaseType(filterOutType);
    hAF.VectorOrientation='column';
    dType_array1=hdlcoder.tp_array(hAF);
    filterOut=ChannelSynthImpl.addSignal2('Type',dType_array1,'Name','filterOut');
    filterOut.SimulinkRate=dataRate;

    filterOut_vld=ChannelSynthImpl.addSignal2('Type',pir_boolean_t,'Name','filterOut_vld');
    filterOut_vld.SimulinkRate=dataRate;


    if blockInfo.inMode(2)
        ifftInSignals=[insignals(1),insignals(2),syncReset];
    else
        ifftInSignals=[insignals(1),insignals(2)];
    end

    hAF=hdlcoder.tpc_arr_factory;
    hAF.addDimension(DATA_VECSIZE);
    hAF.addBaseType(ifftOutType);
    hAF.VectorOrientation='column';
    dType_array=hdlcoder.tp_array(hAF);
    ifftOut=ChannelSynthImpl.addSignal2('Type',dType_array,'Name','ifftOut');
    ifftOut.SimulinkRate=dataRate;

    ifftOut_vld=ChannelSynthImpl.addSignal2('Type',pir_boolean_t,'Name','ifftOut_vld');
    ifftOut_vld.SimulinkRate=dataRate;

    filterIn_vld=ChannelSynthImpl.addSignal2('Type',pir_boolean_t,'Name','filterIn_vld');
    filterIn_vld.SimulinkRate=dataRate;

    filterIn=ChannelSynthImpl.addSignal2('Type',dType_array,'Name','filterIn');
    filterIn.SimulinkRate=dataRate;

    IFFTImpl=this.elabHDLIFFT(ChannelSynthImpl,blockInfo,ifftInSignals,[ifftOut,ifftOut_vld]);
    pirelab.instantiateNetwork(ChannelSynthImpl,IFFTImpl,ifftInSignals,[ifftOut,ifftOut_vld],'IFFT');
    pirelab.getWireComp(ChannelSynthImpl,ifftOut,filterIn);
    pirelab.getWireComp(ChannelSynthImpl,ifftOut_vld,filterIn_vld);

    if blockInfo.inMode(2)
        filterInSignals=[filterIn,filterIn_vld,syncReset];
    else
        filterInSignals=[filterIn,filterIn_vld];
    end

    filterOutSignals=[filterOut,filterOut_vld];
    FilterImpl=this.elabHDLFilterBank(ChannelSynthImpl,blockInfo,filterInSignals,filterOutSignals);
    pirelab.instantiateNetwork(ChannelSynthImpl,FilterImpl,filterInSignals,filterOutSignals,'FilterBank');
    pirelab.getDTCComp(ChannelSynthImpl,filterOut,filterOut_DT,blockInfo.RoundingMethod,blockInfo.OverflowAction);
    if resetpin
        pirelab.getUnitDelayResettableComp(ChannelSynthImpl,filterOut_DT,data_out,syncReset);
        pirelab.getUnitDelayResettableComp(ChannelSynthImpl,filterOut_vld,valid_out,syncReset);
    else
        pirelab.getUnitDelayComp(ChannelSynthImpl,filterOut_DT,data_out);
        pirelab.getUnitDelayComp(ChannelSynthImpl,filterOut_vld,valid_out);
    end
