function createLiberoSynthesisTable(this,timing,synarea)

    Fmax=timing.fmax;
    CP=timing.cp;
    LogicDelay=timing.logic;
    RouteDelay=timing.route;
    Latency=timing.latency;

    LUT4s=synarea.LUT4s;
    DFFs=synarea.DFFs;
    RAM64x18s=synarea.RAM64x18s;
    RAM1K18s=synarea.RAM1K18s;
    TotalRAMs=synarea.RAMs;
    LogicElements=synarea.LogicElements;
    DSPs=synarea.DSPs;

    this.summary.Libero=table(Fmax,LUT4s,DFFs,LogicElements,DSPs,RAM64x18s,RAM1K18s,TotalRAMs,Latency,CP,LogicDelay,RouteDelay,'RowNames',{this.dutName});
end