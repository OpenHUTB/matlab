function createXilinxSynthesisTable(this,timing,synarea)

    Fmax=timing.fmax;
    Latency=timing.latency;
    DataPathDelay=timing.dataPathDelay;
    LogicLevels=timing.levels;
    LogicDelay=timing.logic;
    RouteDelay=timing.route;
    Slack=timing.slack;


    Slices=synarea.slices;
    SliceRegs=synarea.sliceRegs;
    LUTs=synarea.luts;
    DSPs=synarea.DSPs;
    DSP58=synarea.DSP58;
    RAMs=synarea.RAMs;
    URAMs=synarea.URAMs;


    MaxSlices=synarea.maxSlices;
    MaxSliceRegs=synarea.maxSliceRegs;
    MaxLUTs=synarea.maxLuts;
    MaxDSPs=synarea.maxDSPs;
    MaxDSP58=synarea.maxDSP58;
    MaxRAMs=synarea.maxRAMs;
    MaxURAMs=synarea.maxURAMs;

    this.summary.Xilinx=table(Fmax,Slices,MaxSlices,SliceRegs,MaxSliceRegs,LUTs,MaxLUTs,DSPs,MaxDSPs,DSP58,MaxDSP58,RAMs,MaxRAMs,URAMs,MaxURAMs,Latency,DataPathDelay,Slack,LogicLevels,LogicDelay,RouteDelay,'RowNames',{this.dutName});
end