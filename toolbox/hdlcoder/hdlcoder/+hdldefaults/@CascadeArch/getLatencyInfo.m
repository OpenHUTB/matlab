function latencyInfo=getLatencyInfo(this,hC)










    decomposition=this.getDecomposition();

    hCInSignal=hC.PirInputSignals;
    invectsize=pirelab.getInputDimension(hCInSignal);

    decompose_vector=hdlcascadedecompose(invectsize,decomposition);

    if isempty(decompose_vector)
        Up=0;
    else
        Up=decompose_vector(1);
    end
    Down=1;
    Phase=0;

    if Up>=1
        userData.Latency=1;
    else
        userData.Latency=0;
    end

    latencyInfo.inputDelay=0;
    latencyInfo.outputDelay=userData.Latency;
    latencyInfo.samplingChange=1;

    this.setHDLUserData(hC,userData);
