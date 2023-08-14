function val=getStateInfo(this,hC)










    decomposition=this.getDecomposition();

    hCInSignal=hC.PirInputSignals;
    invectsize=pirelab.getInputDimension(hCInSignal);

    decompose_vector=hdlcascadedecompose(invectsize,decomposition);

    val.HasFeedback=~isempty(decompose_vector);
    val.HasState=~isempty(decompose_vector);
