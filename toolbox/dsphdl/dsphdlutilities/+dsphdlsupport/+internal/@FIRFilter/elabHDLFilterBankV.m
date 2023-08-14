function elabHDLFilterBankV(this,FilterImpl,blockInfo)









    insignals=FilterImpl.PirInputSignals;

    outsignals=FilterImpl.PirOutputSignals;

    for inputIndex=1:length(outsignals)
        outsignals(inputIndex).SimulinkRate=insignals(1).SimulinkRate;
    end

    dataIn=insignals(1);
    dataRate=dataIn(1).simulinkRate;
    vldIn=insignals(2);
    if strcmpi(blockInfo.FilterCoefficientSource,'Property')
        syncReset=insignals(3);
    else
        coeffInp=insignals(3);
        syncReset=insignals(4);
    end

    dout=outsignals(1);
    vldOut=outsignals(2);

    [~,FilterOut_FPDT]=getFilterOutFPDT(this,blockInfo);
    filterOutFPDT_cmplx=hdlcoder.tp_complex(FilterOut_FPDT);

    VECSIZE=blockInfo.CompiledInputSize;
    doutType=pirgetdatatypeinfo(dout.Type);
    DATAOUT_ISCOMPLEX=doutType.iscomplex;

    hAFI=hdlcoder.tpc_arr_factory;
    hAFI.addDimension(VECSIZE);
    hAFI.addBaseType(dataIn.Type.BaseType);
    hAFI.VectorOrientation='column';
    dinType_array=hdlcoder.tp_array(hAFI);

    hAFO=hdlcoder.tpc_arr_factory;
    hAFO.addDimension(VECSIZE);
    if DATAOUT_ISCOMPLEX
        FPDT=filterOutFPDT_cmplx;
    else
        FPDT=FilterOut_FPDT;
    end
    hAFO.addBaseType(FPDT);
    hAFO.VectorOrientation='column';
    sFdOutType=hdlcoder.tp_array(hAFO);
    dinSplit=dataIn.split.PirOutputSignals;
    for loop1=1:VECSIZE
        din(loop1)=dinSplit(loop1);
        dinReg(loop1)=FilterImpl.addSignal2('Type',dataIn.Type.BaseType,'Name',['dinReg_',num2str(loop1-1)]);%#ok<AGROW>
        dinReg(loop1).SimulinkRate=dataRate;%#ok<*AGROW>
        pirelab.getIntDelayEnabledResettableComp(FilterImpl,din(loop1),dinReg(loop1),vldIn,syncReset,1);
        sFdOut(loop1)=FilterImpl.addSignal2('Type',sFdOutType,'Name','sFdOut');%#ok<AGROW>
        sFdOut(loop1).SimulinkRate=dataRate;
        sFvldOut(loop1)=FilterImpl.addSignal2('Type',pir_boolean_t,'Name','sFvldOut');
        sFvldOut(loop1).SimulinkRate=dataRate;
        dOutCh(loop1)=FilterImpl.addSignal2('Type',dout.Type.BaseType,'Name','dOutCh');%#ok<AGROW>
        dOutCh(loop1).SimulinkRate=dataRate;
        vOutCh(loop1)=FilterImpl.addSignal2('Type',pir_boolean_t,'Name','vOutCh');
        vOutCh(loop1).SimulinkRate=dataRate;
    end



    blockInfo.SymmetryOptimization=false;
    FilterInst=this.elabHDLFilterBank(FilterImpl,blockInfo,insignals,[sFdOut(1),sFvldOut(1)]);
    sumInst=dsphdlshared.internal.elabSumTree(FilterImpl,[sFdOut(1),sFvldOut(1),syncReset],[dOutCh(1),vOutCh(1)],blockInfo.RoundingMethod,blockInfo.OverflowAction,blockInfo.inMode(2));

    for loop1=1:VECSIZE
        if loop1==1
            dIn_tmp=[din(1),dinReg(2:end)];
        else
            dIn_tmp=[din(loop1),dinReg(2+loop1-1:end),din(1:loop1-1)];
        end
        dinV=FilterImpl.addSignal2('Type',dinType_array,'Name','dinV');%#ok<AGROW>
        dinV.SimulinkRate=dataRate;
        pirelab.getMuxComp(FilterImpl,dIn_tmp,dinV);
        if strcmpi(blockInfo.FilterCoefficientSource,'Property')
            pirelab.instantiateNetwork(FilterImpl,FilterInst,[dinV,vldIn,syncReset],[sFdOut(loop1),sFvldOut(loop1)],['FilterBank_',num2str(loop1)]);
        else
            pirelab.instantiateNetwork(FilterImpl,FilterInst,[dinV,vldIn,coeffInp,syncReset],[sFdOut(loop1),sFvldOut(loop1)],['FilterBank_',num2str(loop1)]);
        end
        pirelab.instantiateNetwork(FilterImpl,sumInst,[sFdOut(loop1),sFvldOut(loop1),syncReset],[dOutCh(loop1),vOutCh(loop1)],'sumTree');
    end
    dOut_tmp=FilterImpl.addSignal2('Type',dout.Type,'Name','dOutCh_tmp');%#ok<AGROW>
    dOut_tmp.SimulinkRate=dataRate;
    pirelab.getMuxComp(FilterImpl,dOutCh,dout);
    pirelab.getWireComp(FilterImpl,vOutCh(1),vldOut);








