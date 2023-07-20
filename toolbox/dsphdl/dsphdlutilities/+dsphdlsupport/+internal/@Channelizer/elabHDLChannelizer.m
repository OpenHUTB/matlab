function elabHDLChannelizer(this,ChannelizerImpl,blockInfo)






    insignals=ChannelizerImpl.PirInputSignals;
    outsignals=ChannelizerImpl.PirOutputSignals;


    [FilterIn_DT,FilterOut_DT]=getFilterOutDT(this,blockInfo);
    dataIn=insignals(1);
    dataRate=dataIn.simulinkRate;
    dataInType=pirgetdatatypeinfo(dataIn.Type);
    DATA_VECSIZE=dataInType.dims;
    DATA_ISCOMPLEX=dataInType.iscomplex;
    filterOutType_cmplx=hdlcoder.tp_complex(FilterOut_DT);
    filterInType_cmplx=hdlcoder.tp_complex(FilterIn_DT);

    FIILTEROUT_ISCOMPLEX=~isreal(blockInfo.FilterCoefficient);


    if blockInfo.inMode(2)
        syncReset=insignals(3);
        syncReset.SimulinkRate=dataRate;
    else
        syncReset=ChannelizerImpl.addSignal2('Type',pir_boolean_t,'Name','softReset');
        syncReset.SimulinkRate=dataRate;
        if blockInfo.inResetSS


            syncReset.setSynthResetInsideResetSS;

            blockInfo.inMode(2)=true;
        else


            pirelab.getConstComp(ChannelizerImpl,syncReset,false);
        end
    end
    if dataInType.issigned
        filterInData=insignals(1);
    else
        if DATA_ISCOMPLEX
            if DATA_VECSIZE==1
                filterInData=ChannelizerImpl.addSignal2('Type',filterInType_cmplx,'Name','filterIn_cmplx');
                filterInData.SimulinkRate=dataRate;
            else
                hAF=hdlcoder.tpc_arr_factory;
                hAF.addDimension(DATA_VECSIZE);
                hAF.addBaseType(filterInType_cmplx);
                hAF.VectorOrientation='column';
                dType_array=hdlcoder.tp_array(hAF);
                filterInData=ChannelizerImpl.addSignal2('Type',dType_array,'Name','filterIn');
                filterInData.SimulinkRate=dataRate;
            end
        else
            if DATA_VECSIZE==1
                filterInData=ChannelizerImpl.addSignal2('Type',FilterIn_DT,'Name','filterOut');
                filterInData.SimulinkRate=dataRate;
            else
                hAF=hdlcoder.tpc_arr_factory;
                hAF.addDimension(DATA_VECSIZE);
                hAF.addBaseType(FilterIn_DT);
                hAF.VectorOrientation='column';
                dType_array=hdlcoder.tp_array(hAF);
                filterInData=ChannelizerImpl.addSignal2('Type',dType_array,'Name','filterOut');
                filterInData.SimulinkRate=dataRate;
            end
        end
        pirelab.getDTCComp(ChannelizerImpl,insignals(1),filterInData);

    end

    if blockInfo.inMode(2)
        filterInSignals=[filterInData,insignals(2),syncReset];
    else
        filterInSignals=[filterInData,insignals(2)];
    end

    if DATA_ISCOMPLEX||FIILTEROUT_ISCOMPLEX
        if DATA_VECSIZE==1
            filterOut=ChannelizerImpl.addSignal2('Type',filterOutType_cmplx,'Name','filterOut_cmplx');
            filterOut.SimulinkRate=dataRate;
        else
            hAF=hdlcoder.tpc_arr_factory;
            hAF.addDimension(DATA_VECSIZE);
            hAF.addBaseType(filterOutType_cmplx);
            hAF.VectorOrientation='column';
            dType_array=hdlcoder.tp_array(hAF);
            filterOut=ChannelizerImpl.addSignal2('Type',dType_array,'Name','filterOut');
            filterOut.SimulinkRate=dataRate;
        end
    else
        if DATA_VECSIZE==1
            filterOut=ChannelizerImpl.addSignal2('Type',FilterOut_DT,'Name','filterOut');
            filterOut.SimulinkRate=dataRate;
        else
            hAF=hdlcoder.tpc_arr_factory;
            hAF.addDimension(DATA_VECSIZE);
            hAF.addBaseType(FilterOut_DT);
            hAF.VectorOrientation='column';
            dType_array=hdlcoder.tp_array(hAF);
            filterOut=ChannelizerImpl.addSignal2('Type',dType_array,'Name','filterOut');
            filterOut.SimulinkRate=dataRate;
        end
    end

    filterOut_vld=ChannelizerImpl.addSignal2('Type',pir_boolean_t,'Name','filterOut_vld');
    filterOut_vld.SimulinkRate=dataRate;

    FilterImpl=this.elabHDLFilterBank(ChannelizerImpl,blockInfo,filterInSignals,[filterOut,filterOut_vld]);
    pirelab.instantiateNetwork(ChannelizerImpl,FilterImpl,filterInSignals,[filterOut,filterOut_vld],'FilterBank');

    if strcmpi(blockInfo.OutputSize,'Same as number of frequency bands')
        dataOut=outsignals(1);
        dataOutType=pirgetdatatypeinfo(dataOut.Type);
        FFTOutType=pir_fixpt_t(1,dataOutType.wordsize,dataOutType.binarypoint);
        FFTType_cmplx=hdlcoder.tp_complex(FFTOutType);
        if DATA_VECSIZE==1
            FFTOut=ChannelizerImpl.addSignal2('Type',FFTType_cmplx,'Name','FFTOut');
            FFTOut.SimulinkRate=dataRate;
        else
            hAF=hdlcoder.tpc_arr_factory;
            hAF.addDimension(DATA_VECSIZE);
            hAF.addBaseType(FFTType_cmplx);
            hAF.VectorOrientation='column';
            dType_array=hdlcoder.tp_array(hAF);
            FFTOut=ChannelizerImpl.addSignal2('Type',dType_array,'Name','FFTOut');
            FFTOut.SimulinkRate=dataRate;
        end

        FFTVldOut=ChannelizerImpl.addSignal2('Type',pir_boolean_t,'Name','FFTVldOut');
        FFTVldOut.SimulinkRate=dataRate;
        if blockInfo.inMode(2)
            FFTImpl=this.elabHDLFFT(ChannelizerImpl,blockInfo,[filterOut,filterOut_vld,syncReset],[FFTOut,FFTVldOut]);
            pirelab.instantiateNetwork(ChannelizerImpl,FFTImpl,[filterOut,filterOut_vld,syncReset],[FFTOut,FFTVldOut],'FFT');
        else
            FFTImpl=this.elabHDLFFT(ChannelizerImpl,blockInfo,[filterOut,filterOut_vld],[FFTOut,FFTVldOut]);
            pirelab.instantiateNetwork(ChannelizerImpl,FFTImpl,[filterOut,filterOut_vld],[FFTOut,FFTVldOut],'FFT');
        end
        resizeImpl=this.elabResize(ChannelizerImpl,blockInfo,dataRate,FFTOut,FFTVldOut,syncReset,outsignals(:));%#ok<NASGU>


    else
        if blockInfo.inMode(2)
            FFTImpl=this.elabHDLFFT(ChannelizerImpl,blockInfo,[filterOut,filterOut_vld,syncReset],outsignals);
            pirelab.instantiateNetwork(ChannelizerImpl,FFTImpl,[filterOut,filterOut_vld,syncReset],outsignals,'FFT');
        else
            FFTImpl=this.elabHDLFFT(ChannelizerImpl,blockInfo,[filterOut,filterOut_vld],outsignals);
            pirelab.instantiateNetwork(ChannelizerImpl,FFTImpl,[filterOut,filterOut_vld],outsignals,'FFT');
        end
    end

end
