function newComp=elaborate(this,hN,hC)

    [bp_data_typed,bpType_ex,kType_ex,fType_ex,idxOnly,powerof2,diagnostics]=...
    this.getBlockInfo(hC);

    slbh=hC.SimulinkHandle;

    newComp=pirelab.getPreLookupComp(hN,hC.SLInputSignals,hC.SLOutputSignals,...
    bp_data_typed,bpType_ex,kType_ex,fType_ex,idxOnly,powerof2,hC.Name,slbh,diagnostics);
end
