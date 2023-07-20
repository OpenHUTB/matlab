function createAlteraSynthesisTable(this,timing,synarea)

    Slack=timing.slack;
    DataDelay=timing.dataDelay;
    Fmax=timing.fmax;
    Latency=timing.latency;


    ALMs=synarea.ALMs;
    LABs=synarea.LABs;

    M9Ks=synarea.M9ks;
    M10Ks=synarea.M10ks;
    M20Ks=synarea.M20ks;
    M144Ks=synarea.M144ks;
    RAMs=[M9Ks,M10Ks,M20Ks,M144Ks];

    if any(~isnan(RAMs))
        RAMs=sum(RAMs(~isnan(RAMs)));
    else
        RAMs=NaN;
    end

    CombALUTs=synarea.combALUT;
    MemoryALUTs=synarea.memALUT;
    LogicRegisters=synarea.logicReg;
    FloatDSPs=synarea.FloatDSPs;
    FixedDSPs=synarea.FixedDSPs;
    DSPs=synarea.DSPs;


    MaxALMs=synarea.MaxALMs;
    MaxLABs=synarea.MaxLABs;

    MaxM9Ks=synarea.MaxM9ks;
    MaxM10Ks=synarea.MaxM10ks;
    MaxM20Ks=synarea.MaxM20ks;
    MaxM144Ks=synarea.MaxM144ks;
    MaxRAMs=[MaxM9Ks,MaxM10Ks,MaxM20Ks,MaxM144Ks];

    if any(~isnan(MaxRAMs))
        MaxRAMs=sum(MaxRAMs(~isnan(MaxRAMs)));
    else
        MaxRAMs=NaN;
    end

    MaxDSPs=synarea.MaxDSPs;
    MaxLogicRegisters=synarea.MaxlogicReg;

    this.summary.Altera=table(Fmax,ALMs,MaxALMs,LABs,MaxLABs,FloatDSPs,FixedDSPs,DSPs,MaxDSPs,M9Ks,MaxM9Ks,M10Ks,MaxM10Ks,M20Ks,MaxM20Ks,M144Ks,MaxM144Ks,RAMs,MaxRAMs,Latency,CombALUTs,MemoryALUTs,LogicRegisters,MaxLogicRegisters,Slack,DataDelay,'RowNames',{this.dutName});
end