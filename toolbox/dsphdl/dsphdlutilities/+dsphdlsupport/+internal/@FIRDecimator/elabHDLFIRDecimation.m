function elabHDLFIRDecimation(this,FIRDecimImpl,blockInfo)








    insignals=FIRDecimImpl.PirInputSignals;
    outsignals=FIRDecimImpl.PirOutputSignals;


    [FilterIn_DT,FilterOut_FPDT]=getFilterOutDT(this,blockInfo);

    dataIn=insignals(1);
    validIn=insignals(2);
    dataRate=dataIn.simulinkRate;
    dataInType=pirgetdatatypeinfo(dataIn.Type);
    DATAIN_VECSIZE=dataInType.dims;
    DATAIN_ISCOMPLEX=dataInType.iscomplex;

    dataOut=outsignals(1);
    dataOutType=pirgetdatatypeinfo(dataOut.Type);
    DATAOUT_VECSIZE=dataOutType.dims;
    DATAOUT_ISCOMPLEX=dataOutType.iscomplex;

    filterOutType_cmplx=hdlcoder.tp_complex(FilterOut_FPDT);
    filterInType_cmplx=hdlcoder.tp_complex(FilterIn_DT);



    if blockInfo.inMode(2)
        syncReset=insignals(3);
        syncReset.SimulinkRate=dataRate;
    else
        syncReset=FIRDecimImpl.addSignal2('Type',pir_boolean_t,'Name','syncReset');
        syncReset.SimulinkRate=dataRate;
        if blockInfo.inResetSS


            syncReset.setSynthResetInsideResetSS;

            blockInfo.inMode(2)=true;
        else


            pirelab.getConstComp(FIRDecimImpl,syncReset,false);
        end
    end








    if DATAIN_ISCOMPLEX
        if DATAIN_VECSIZE==1
            filterInData=FIRDecimImpl.addSignal2('Type',filterInType_cmplx,'Name','filterIn_cmplx');
            filterInData.SimulinkRate=dataRate;
        else
            hAF=hdlcoder.tpc_arr_factory;
            hAF.addDimension(DATAIN_VECSIZE);
            hAF.addBaseType(filterInType_cmplx);
            hAF.VectorOrientation='column';
            dType_array=hdlcoder.tp_array(hAF);
            filterInData=FIRDecimImpl.addSignal2('Type',dType_array,'Name','filterIn');
            filterInData.SimulinkRate=dataRate;
        end
    else
        if DATAIN_VECSIZE==1
            filterInData=FIRDecimImpl.addSignal2('Type',FilterIn_DT,'Name','filterIn');
            filterInData.SimulinkRate=dataRate;
        else
            hAF=hdlcoder.tpc_arr_factory;
            hAF.addDimension(DATAIN_VECSIZE);
            hAF.addBaseType(FilterIn_DT);
            hAF.VectorOrientation='column';
            dType_array=hdlcoder.tp_array(hAF);
            filterInData=FIRDecimImpl.addSignal2('Type',dType_array,'Name','filterIn');
            filterInData.SimulinkRate=dataRate;
        end
    end
    pirelab.getDTCComp(FIRDecimImpl,insignals(1),filterInData);
    if DATAIN_VECSIZE==1
        if blockInfo.NumCycles==1
            dataIn=filterInData;
            vldIn=validIn;
        else
            dataIn=FIRDecimImpl.addSignal2('Type',filterInData.Type,'Name','dataIn');
            dataIn.SimulinkRate=dataRate;
            vldIn=FIRDecimImpl.addSignal2('Type',pir_boolean_t,...
            'Name','vldIn','SimulinkRate',dataRate);

            rdyReg=FIRDecimImpl.addSignal2('Type',pir_boolean_t,...
            'Name','rdyReg','SimulinkRate',dataRate);

            pirelab.getIntDelayEnabledResettableComp(FIRDecimImpl,filterInData,dataIn,'',syncReset,1);
            fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
            '+dsphdlsupport','+internal','@FIRDecimator','cgireml','dropEarlyData.m'),'r');
            fcnBody=fread(fid,Inf,'char=>char')';
            fclose(fid);

            desc='dropEarlyData';

            dropEarlyData=FIRDecimImpl.addComponent2(...
            'kind','cgireml',...
            'Name','dropEarlyData',...
            'InputSignals',validIn,...
            'OutputSignals',[vldIn,rdyReg],...
            'EMLFileName','dropEarlyData',...
            'EMLFileBody',fcnBody,...
            'EMLParams',{blockInfo.DecimationFactor,blockInfo.NumCycles},...
            'ExternalSynchronousResetSignal',syncReset,...
            'EMLFlag_TreatInputIntsAsFixpt',true,...
            'EMLFlag_SaturateOnIntOverflow',false,...
            'EMLFlag_TreatInputBoolsAsUfix1',false,...
            'BlockComment',desc);

            dropEarlyData.runConcurrencyMaximizer(0);
        end
    else
        dataIn=filterInData;
        vldIn=validIn;
    end

    if blockInfo.inMode(2)
        filterInSignals=[dataIn,vldIn,syncReset];
    else
        filterInSignals=[dataIn,vldIn];
    end



    if DATAOUT_ISCOMPLEX
        if DATAIN_VECSIZE==1
            filterOut=FIRDecimImpl.addSignal2('Type',filterOutType_cmplx,'Name','filterOut_cmplx');
            filterOut.SimulinkRate=dataRate;
        else
            hAF=hdlcoder.tpc_arr_factory;
            hAF.addDimension(DATAIN_VECSIZE);
            hAF.addBaseType(filterOutType_cmplx);
            hAF.VectorOrientation='column';
            dType_array=hdlcoder.tp_array(hAF);
            filterOut=FIRDecimImpl.addSignal2('Type',dType_array,'Name','filterOut');
            filterOut.SimulinkRate=dataRate;
        end
    else
        if DATAIN_VECSIZE==1
            filterOut=FIRDecimImpl.addSignal2('Type',FilterOut_FPDT,'Name','filterOut');
            filterOut.SimulinkRate=dataRate;
        else
            hAF=hdlcoder.tpc_arr_factory;
            hAF.addDimension(DATAIN_VECSIZE);
            hAF.addBaseType(FilterOut_FPDT);
            hAF.VectorOrientation='column';
            dType_array=hdlcoder.tp_array(hAF);
            filterOut=FIRDecimImpl.addSignal2('Type',dType_array,'Name','filterOut');
            filterOut.SimulinkRate=dataRate;
        end
    end


    filterOut_vld=FIRDecimImpl.addSignal2('Type',pir_boolean_t,'Name','filterOut_vld');
    filterOut_vld.SimulinkRate=dataRate;
    blkInfo=getFilterBlkInfo(this,blockInfo);
    FilterImpl=this.elabHDLFilterBank(FIRDecimImpl,blkInfo,filterInSignals,[filterOut,filterOut_vld]);
    pirelab.instantiateNetwork(FIRDecimImpl,FilterImpl,filterInSignals,[filterOut,filterOut_vld],'FilterBank');


    blockInfo.FINALDECIM=blockInfo.DecimationFactor/DATAIN_VECSIZE;
    if DATAIN_VECSIZE==1

        integImpl=this.elabDecimInteg(FIRDecimImpl,blockInfo,[filterOut,filterOut_vld,syncReset],outsignals);
        pirelab.instantiateNetwork(FIRDecimImpl,integImpl,[filterOut,filterOut_vld,syncReset],outsignals,'FirDecimInteg');
    elseif DATAIN_VECSIZE==blockInfo.DecimationFactor


        accumImpl=dsphdlshared.internal.elabSumTree(FIRDecimImpl,[filterOut,filterOut_vld,syncReset],outsignals,...
        blockInfo.RoundingMethod,blockInfo.OverflowAction,blockInfo.inMode(2));
        pirelab.instantiateNetwork(FIRDecimImpl,accumImpl,[filterOut,filterOut_vld,syncReset],outsignals,'FirDecimAcc');
    elseif DATAIN_VECSIZE<blockInfo.DecimationFactor

        accumOut=FIRDecimImpl.addSignal2('Type',filterOut.Type.BaseType,'Name','accumOut');
        accumOut.SimulinkRate=dataRate;
        accumOutVld=FIRDecimImpl.addSignal2('Type',pir_boolean_t,'Name','accumOutVld');
        accumOutVld.SimulinkRate=dataRate;

        accumImpl=dsphdlshared.internal.elabSumTree(FIRDecimImpl,[filterOut,filterOut_vld,syncReset],[accumOut,accumOutVld],...
        blockInfo.RoundingMethod,blockInfo.OverflowAction,blockInfo.inMode(2));
        pirelab.instantiateNetwork(FIRDecimImpl,accumImpl,[filterOut,filterOut_vld,syncReset],[accumOut,accumOutVld],'FirDecimAcc');
        integImpl=this.elabDecimInteg(FIRDecimImpl,blockInfo,[accumOut,accumOutVld,syncReset],outsignals);
        pirelab.instantiateNetwork(FIRDecimImpl,integImpl,[accumOut,accumOutVld,syncReset],outsignals,'FirDecimInteg');
    else

    end



end
