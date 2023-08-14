function elabHDLFIRDecimationV(this,FIRDecimImpl,blockInfo)




    insignals=FIRDecimImpl.PirInputSignals;
    outsignals=FIRDecimImpl.PirOutputSignals;



    d=blockInfo.DecimationFactor;
    n=blockInfo.Numerator;
    nlen=length(n);
    remcoeff=mod(nlen,d);
    if remcoeff~=0
        n2=[n,zeros(1,d-remcoeff,'like',n)];
        nq=blockInfo.NumeratorQuantized;
        nq2=[n,zeros(1,d-remcoeff,'like',nq)];
        blockInfo.Numerator=n2;
        blockInfo.NumeratorQuantized=nq2;
    end


    [FilterIn_DT,FilterOut_FPDT]=getFilterOutDT(this,blockInfo);

    dataIn=insignals(1);
    dataRate=dataIn.simulinkRate;
    dataInType=pirgetdatatypeinfo(dataIn.Type);
    DATAIN_VECSIZE=dataInType.dims;
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
        filterInType=hdlcoder.tp_complex(FilterIn_DT);
    else
        filterInType=FilterIn_DT;
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



    hAF=hdlcoder.tpc_arr_factory;
    hAF.addDimension(DATAIN_VECSIZE);
    hAF.addBaseType(filterInType);
    hAF.VectorOrientation='column';
    dType_array=hdlcoder.tp_array(hAF);
    filterInData=FIRDecimImpl.addSignal2('Type',dType_array,'Name','filterIn');
    filterInData.SimulinkRate=dataRate;


    pirelab.getDTCComp(FIRDecimImpl,dataIn,filterInData);

...
...
...
...
...
...
...
...
...
...

    filterInDataReg=filterInData;
    validInReg=validIn;
    syncResetReg=syncReset;


    numsubfilters=blockInfo.DecimationFactor;
    subfilter_vecsize=DATAIN_VECSIZE/numsubfilters;

    filterInData_signals=filterInDataReg.split.PirOutputSignals;


    hAF=hdlcoder.tpc_arr_factory;
    hAF.addDimension(subfilter_vecsize);
    hAF.addBaseType(filterInType);
    hAF.VectorOrientation='column';
    subfilterin_dType_array=hdlcoder.tp_array(hAF);
    hAF=hdlcoder.tpc_arr_factory;
    hAF.addDimension(subfilter_vecsize);
    hAF.addBaseType(filterOutType);
    hAF.VectorOrientation='column';
    subfilterout_dType_array=hdlcoder.tp_array(hAF);





    [subfilteroutData,subfilteroutVld]=deal(repmat(validInReg,numsubfilters,1));
    subfilteroutDataSignals=[];
    nonzerocoeffIdx=0;


    nonzerosubfilter=false(numsubfilters,1);
    for ii=1:numsubfilters
        subfilterinData=FIRDecimImpl.addSignal2('Type',subfilterin_dType_array,...
        'Name',['subfilterIn_',num2str(ii)],'SimulinkRate',dataRate);
        pirelab.getMuxComp(FIRDecimImpl,filterInData_signals(ii:numsubfilters:end),...
        subfilterinData);

        subfilterInSignals=[subfilterinData,validInReg,syncResetReg];
        subfilter_inportNames={'dataIn','validIn','syncreset'};
        subfilter_inportRates=repmat(dataRate,3,1);
        subfilter_inportTypes=[subfilterinData.Type,validInReg.Type,syncResetReg.Type];


        subfilteroutData(ii)=FIRDecimImpl.addSignal2('Type',subfilterout_dType_array,...
        'Name',['subfilterOut_',num2str(ii)],'SimulinkRate',dataRate);
        subfilteroutVld(ii)=FIRDecimImpl.addSignal2('Type',pir_boolean_t,...
        'Name',['subfilterOut_vld',num2str(ii)],'SimulinkRate',dataRate);


        firblockInfo=this.getFIRFilterblockInfo(blockInfo,ii,subfilterInSignals(1));

        if isempty(firblockInfo.Numerator)||all(firblockInfo.Numerator==0)||...
            all(firblockInfo.NumeratorQuantized==0)


            c=pirelab.getConstComp(FIRDecimImpl,subfilteroutData(ii),0);
            c.addComment(['All zero coefficient for phase ',num2str(ii)]);
        else

            nonzerocoeffIdx=ii;






            subfilterOutSignals=[subfilteroutData(ii),subfilteroutVld(ii)];
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...


            frameFilter=dsphdlsupport.internal.FIRFilter;
            subfilterBankImpl=frameFilter.elabHDLFIRFilter(FIRDecimImpl,firblockInfo,...
            subfilterInSignals,subfilterOutSignals);
            subfilterBankImpl.Name=['FIRFilter_',num2str(ii)];

            pirelab.instantiateNetwork(FIRDecimImpl,subfilterBankImpl,...
            subfilterInSignals,subfilterOutSignals,...
            ['FIRDecim_phase_',num2str(ii)]);
            nonzerosubfilter(ii)=true;
        end
        subfilteroutDataSignals=[subfilteroutDataSignals(:);...
        subfilteroutData(ii).split.PirOutputSignals];
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


    assert(nonzerocoeffIdx~=0);
    accInVld=subfilteroutVld(nonzerocoeffIdx);





    accOut=FIRDecimImpl.addSignal2('Type',accOutType,'Name','accOut');
    accOut.SimulinkRate=dataRate;
    accOutVld=FIRDecimImpl.addSignal2('Type',pir_boolean_t,'Name','accOutVld');
    accOutVld.SimulinkRate=dataRate;
    accumImpl=dsphdlshared.internal.elabSumTree(FIRDecimImpl,...
    [accIn,accInVld,syncResetReg],[accOut,accOutVld],...
    blockInfo.RoundingMethod,blockInfo.OverflowAction,blockInfo.inMode(2),...
    'sumTree_firdecim');


    accumOut=repmat(accOut,DATAOUT_VECSIZE,1);
    accumOutVld=repmat(accOutVld,DATAOUT_VECSIZE,1);
    for ii=1:DATAOUT_VECSIZE


        accIn_signals=subfilteroutDataSignals(ii:subfilter_vecsize:end);

        accIn_nonzero_signals=accIn_signals(nonzerosubfilter);
        accIn=FIRDecimImpl.addSignal2('Type',accIn_array,...
        'Name',['accIn_',num2str(ii)],'SimulinkRate',dataRate);

        pirelab.getMuxComp(FIRDecimImpl,accIn_nonzero_signals,accIn);
        accumOut(ii)=FIRDecimImpl.addSignal2('Type',accOutType,...
        'Name',['accumOut_',num2str(ii)],'SimulinkRate',dataRate);
        accumOutVld(ii)=FIRDecimImpl.addSignal2('Type',pir_boolean_t,...
        'Name',['accumOutVld_',num2str(ii)],'SimulinkRate',dataRate);
        pirelab.instantiateNetwork(FIRDecimImpl,accumImpl,...
        [accIn,accInVld,syncResetReg],[accumOut(ii),accumOutVld(ii)],...
        ['FirDecimAccum_',num2str(ii)]);
    end



    accumOutReg=accumOut;
    accumOutVldReg=accumOutVld(1);
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...



    pirelab.getMuxComp(FIRDecimImpl,accumOutReg(:),dataOut);
    pirelab.getWireComp(FIRDecimImpl,accumOutVldReg,validOut);

end
