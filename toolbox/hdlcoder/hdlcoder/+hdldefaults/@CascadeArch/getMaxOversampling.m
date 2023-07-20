function val=getMaxOversampling(this,hC)










    decomposition=this.getDecomposition();

    hCInSignal=hC.PirInputSignals;
    invectsize=pirelab.getInputDimension(hCInSignal);

    decompose_vector=hdlcascadedecompose(invectsize,decomposition);

    if isempty(decompose_vector)
        val=1;
    else
        val=decompose_vector(1);
    end
