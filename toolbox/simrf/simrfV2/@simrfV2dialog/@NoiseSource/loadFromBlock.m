function loadFromBlock(this)




    this.SimulinkInputSignalType=this.Block.SimulinkInputSignalType;
    this.NoisePSD=this.Block.NoisePSD;
    this.NoiseType=this.Block.NoiseType;
    this.CarrierFreq=this.Block.CarrierFreq;
    this.CarrierFreq_unit=this.Block.CarrierFreq_unit;
    this.AutoImpulseLength=strcmpi(this.Block.AutoImpulseLength,'on');
    this.ImpulseLength=this.Block.ImpulseLength;
    this.ImpulseLength_unit=this.Block.ImpulseLength_unit;
    this.InternalGrounding=strcmpi(this.Block.InternalGrounding,'on');

