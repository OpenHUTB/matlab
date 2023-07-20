function loadFromBlock(this)







    this.TreatSimulinkInputSignalAs=this.Block.TreatSimulinkInputSignalAs;
    this.MaxLength=this.Block.MaxLength;
    this.FracBW=this.Block.FracBW;
    this.ModelDelay=this.Block.ModelDelay;
    this.Fc=this.Block.Fc;
    this.Ts=this.Block.Ts;
    this.Zs=this.Block.Zs;
    this.RFhasDSP=this.Block.RFhasDSP;
    this.NoiseFlag=strcmpi(this.Block.NoiseFlag,'on');
    this.seed=this.Block.seed;

