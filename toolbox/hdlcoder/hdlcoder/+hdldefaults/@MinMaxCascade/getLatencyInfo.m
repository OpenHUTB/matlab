function latencyInfo=getLatencyInfo(this,hC)










    decomposition=this.getDecomposition();

    hCInSignal=hC.getInputSignals('data');
    invectsize=pirelab.getInputDimension(hCInSignal);


    slbh=hC.SimulinkHandle;
    [fcnString,compType,blockType]=this.getBlockInfo(slbh);
    isDspVectorOut=this.isDspMinmaxVectorOut(slbh,hCInSignal,blockType);
    if isDspVectorOut
        inputsize=1;
    else
        inputsize=invectsize;
    end

    decompose_vector=hdlcascadedecompose(inputsize,decomposition);

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
