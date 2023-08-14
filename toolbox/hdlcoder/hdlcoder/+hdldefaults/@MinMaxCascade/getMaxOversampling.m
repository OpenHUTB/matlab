function val=getMaxOversampling(this,hC)


    decomposition=this.getDecomposition();

    hCInSignal=hC.getInputSignals('data');
    invectsize=pirelab.getInputDimension(hCInSignal);


    slbh=hC.SimulinkHandle;
    [~,~,blockType]=this.getBlockInfo(slbh);
    isDspVectorOut=this.isDspMinmaxVectorOut(slbh,hCInSignal,blockType);
    if isDspVectorOut
        inputsize=1;
    else
        inputsize=invectsize;
    end

    decompose_vector=hdlcascadedecompose(inputsize,decomposition);

    if isempty(decompose_vector)
        val=1;
    else
        val=decompose_vector(1);
    end
