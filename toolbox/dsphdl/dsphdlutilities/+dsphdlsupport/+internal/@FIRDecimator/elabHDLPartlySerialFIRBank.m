function elabHDLPartlySerialFIRBank(this,FIRDecimImpl,blockInfo)




    insignals=FIRDecimImpl.PirInputSignals;
    outsignals=FIRDecimImpl.PirOutputSignals;




    [FilterIn_DT,FilterOut_FPDT]=getFilterOutDT(this,blockInfo);

    dataIn=insignals(1);
    dataRate=dataIn.simulinkRate;
    dataInType=pirgetdatatypeinfo(dataIn.Type);
    DATAIN_ISCOMPLEX=dataInType.iscomplex;

    validIn=insignals(2);

    dataOut=outsignals(1);
    dataOutType=pirgetdatatypeinfo(dataOut.Type);
    DATAOUT_VECSIZE=dataOutType.dims;
    DATAOUT_ISCOMPLEX=dataOutType.iscomplex;

    validOut=outsignals(2);

    if DATAOUT_ISCOMPLEX
        filterOutType=hdlcoder.tp_complex(FilterOut_FPDT);
    else
        filterOutType=FilterOut_FPDT;
    end

    if DATAIN_ISCOMPLEX
        DataInType=hdlcoder.tp_complex(FilterIn_DT);
    else
        DataInType=FilterIn_DT;
    end


    out_FPDT=dataOut.Type.BaseType.BaseType;
    if DATAOUT_ISCOMPLEX
        accOutType=hdlcoder.tp_complex(out_FPDT);
    else
        accOutType=out_FPDT;
    end



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


    dataIn_cast=FIRDecimImpl.addSignal2('Type',DataInType,'Name','dataIn_cast');
    dataIn_cast.SimulinkRate=dataRate;


    pirelab.getDTCComp(FIRDecimImpl,dataIn,dataIn_cast);


    ctrl=FIRDecimImpl.addSignal2('Type',pir_boolean_t,'Name','ctrl');%#ok<*AGROW> 
    ctrl.SimulinkRate=dataRate;
    ready=FIRDecimImpl.addSignal2('Type',pir_boolean_t,'Name','ready');%#ok<*AGROW> 
    ready.SimulinkRate=dataRate;
    partlySerialCtrl=this.elabPartlySerialCtrl(FIRDecimImpl,blockInfo,[validIn,syncReset],[ctrl,ready]);
    pirelab.instantiateNetwork(FIRDecimImpl,partlySerialCtrl,[validIn,syncReset],[ctrl,ready],'partlySerialCtrl');

    numsubfilters=blockInfo.DecimationFactor;
    dIn=dataIn_cast;
    for ii=1:numsubfilters
        delayLine(ii)=FIRDecimImpl.addSignal2('Type',DataInType,'Name','delayLine');%#ok<*AGROW> 
        delayLine(ii).SimulinkRate=dataRate;
        vldAndRdy(ii)=FIRDecimImpl.addSignal2('Type',pir_boolean_t,'Name','vldAndRdy');%#ok<*AGROW> 
        vldAndRdy(ii).SimulinkRate=dataRate;
        pirelab.getBitwiseOpComp(FIRDecimImpl,[validIn,ready],vldAndRdy(ii),'AND');
        pirelab.getIntDelayEnabledResettableComp(FIRDecimImpl,dIn,delayLine(ii),vldAndRdy(ii),syncReset,1);
        dIn=delayLine(ii);
    end


    vldOutIdx=blockInfo.vldIdx;


    nonzerosubfilter=false(numsubfilters,1);
    nonZeroSubFilteridx=1;
    blkInfo=getFIRPartlySerialBlkInfo(this,blockInfo);

    for ii=1:numsubfilters

        subfilteroutData(ii)=FIRDecimImpl.addSignal2('Type',filterOutType,...
        'Name',['subfilterOut_',num2str(ii)],'SimulinkRate',dataRate);
        subfilteroutVld(ii)=FIRDecimImpl.addSignal2('Type',pir_boolean_t,...
        'Name',['subfilterOut_vld',num2str(ii)],'SimulinkRate',dataRate);
        subfilteroutRdy(ii)=FIRDecimImpl.addSignal2('Type',pir_boolean_t,...
        'Name',['subfilterOut_rdy',num2str(ii)],'SimulinkRate',dataRate);
        subfilteroutData_tmp(ii)=FIRDecimImpl.addSignal2('Type',filterOutType,...
        'Name',['subfilterOutTmp_',num2str(ii)],'SimulinkRate',dataRate);
        subfilteroutVld_tmp(ii)=FIRDecimImpl.addSignal2('Type',pir_boolean_t,...
        'Name',['subfilterOutTmp_vld',num2str(ii)],'SimulinkRate',dataRate);
        subfilteroutRdy_tmp(ii)=FIRDecimImpl.addSignal2('Type',pir_boolean_t,...
        'Name',['subfilterOutTmp_rdy',num2str(ii)],'SimulinkRate',dataRate);


        if all(blkInfo.FilterCoefficient(ii,:)==0)||all(fi(blkInfo.FilterCoefficient(ii,:),numerictype(blockInfo.NumeratorQuantized))==0)


            c=pirelab.getConstComp(FIRDecimImpl,subfilteroutData(ii),0);
            c.addComment(['All zero coefficient for phase ',num2str(ii)]);
        else

            blkInfo.Numerator=blkInfo.FilterCoefficient(ii,:);
            subfilterBankImpl(ii)=this.elabHDLPartlySerialFIR(FIRDecimImpl,blkInfo,...
            [delayLine(ii),ctrl,syncReset],[subfilteroutData_tmp(ii),subfilteroutVld_tmp(ii),subfilteroutRdy_tmp(ii)]);


            pirelab.instantiateNetwork(FIRDecimImpl,subfilterBankImpl(ii),...
            [delayLine(ii),ctrl,syncReset],[subfilteroutData_tmp(ii),subfilteroutVld_tmp(ii),subfilteroutRdy_tmp(ii)],...
            ['FIRDecim_phase_',num2str(ii)]);
            delayBalancVecor=blockInfo.delayBalanceVector;
            if delayBalancVecor(ii)==0
                pirelab.getWireComp(FIRDecimImpl,subfilteroutData_tmp(ii),subfilteroutData(ii));
                pirelab.getWireComp(FIRDecimImpl,subfilteroutVld_tmp(ii),subfilteroutVld(ii));
            else
                pirelab.getIntDelayEnabledResettableComp(FIRDecimImpl,subfilteroutData_tmp(ii),subfilteroutData(ii),'',syncReset,delayBalancVecor(ii));
                pirelab.getIntDelayEnabledResettableComp(FIRDecimImpl,subfilteroutVld_tmp(ii),subfilteroutVld(ii),'',syncReset,delayBalancVecor(ii));
            end
            nonzerosubfilter(ii)=true;
            nonZeroSubFilterSignal(nonZeroSubFilteridx)=subfilteroutData(ii);
            nonZeroSubFilteridx=nonZeroSubFilteridx+1;
        end
    end


    numnonzerosubfilters=sum(nonzerosubfilter);







    hAF=hdlcoder.tpc_arr_factory;
    hAF.addDimension(numnonzerosubfilters);
    hAF.addBaseType(filterOutType);
    hAF.VectorOrientation='column';
    if numnonzerosubfilters~=1
        accIn_array=hdlcoder.tp_array(hAF);
    else
        accIn_array=filterOutType;
    end
    accIn=FIRDecimImpl.addSignal2('Type',accIn_array,'Name','accIn');
    accIn.SimulinkRate=dataRate;

    pirelab.getMuxComp(FIRDecimImpl,nonZeroSubFilterSignal,accIn);
    if vldOutIdx~=0
        accInVld=subfilteroutVld(vldOutIdx);
    else
        error(message('dsphdl:FIRDecim:AllZeroCoeffs'));
    end


    accOut=FIRDecimImpl.addSignal2('Type',accOutType,'Name','accOut');
    accOut.SimulinkRate=dataRate;
    accOutVld=FIRDecimImpl.addSignal2('Type',pir_boolean_t,'Name','accOutVld');
    accOutVld.SimulinkRate=dataRate;
    accumImpl=dsphdlshared.internal.elabSumTree(FIRDecimImpl,...
    [accIn,accInVld,syncReset],[accOut,accOutVld],...
    blkInfo.RoundingMethod,blkInfo.OverflowAction,blkInfo.inMode(2),...
    'sumTree_firdecim');%#ok<*NASGU> 

    pirelab.instantiateNetwork(FIRDecimImpl,accumImpl,...
    [accIn,accInVld,syncReset],[accOut,accOutVld],...
    ['FirDecimAccum_',num2str(ii)]);



    ZERO_OUT=FIRDecimImpl.addSignal2('Type',accOut.Type,'Name','ZERO_OUT');
    ZERO_OUT.SimulinkRate=dataRate;
    muxOut=FIRDecimImpl.addSignal2('Type',accOut.Type,'Name','muxOut');
    muxOut.SimulinkRate=dataRate;
    pirelab.getConstComp(FIRDecimImpl,ZERO_OUT,0);
    pirelab.getSwitchComp(FIRDecimImpl,[accOut,ZERO_OUT],muxOut,accOutVld,'','==',1);

    pirelab.getIntDelayEnabledResettableComp(FIRDecimImpl,muxOut,dataOut,'',syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(FIRDecimImpl,accOutVld,validOut,'',syncReset,1);

end

