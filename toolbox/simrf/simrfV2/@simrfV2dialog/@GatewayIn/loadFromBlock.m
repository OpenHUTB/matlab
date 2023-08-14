function loadFromBlock(this)






    this.SimulinkInputSignalType=this.Block.SimulinkInputSignalType;
    this.ZS=this.Block.ZS;
    this.CarrierFreq=this.Block.CarrierFreq;
    this.CarrierFreq_unit=this.Block.CarrierFreq_unit;
    this.UseSqWave=strcmpi(this.Block.UseSqWave,'on');
    this.NumCoeff=this.Block.NumCoeff;
    this.Bias=this.Block.Bias;
    this.DutyCyc=this.Block.DutyCyc;
    this.InternalGrounding=strcmpi(this.Block.InternalGrounding,'on');

