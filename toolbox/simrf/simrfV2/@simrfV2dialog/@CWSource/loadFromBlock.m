function loadFromBlock(this)







    this.CWSourceType=this.Block.CWSourceType;
    this.Z0=this.Block.Z0;
    this.IVoltage=this.Block.IVoltage;
    this.ICurrent=this.Block.ICurrent;
    this.MagPower=this.Block.MagPower;
    this.IVoltage_unit=this.Block.IVoltage_unit;
    this.ICurrent_unit=this.Block.ICurrent_unit;
    this.MagPower_unit=this.Block.MagPower_unit;
    this.QVoltage=this.Block.QVoltage;
    this.QCurrent=this.Block.QCurrent;
    this.AnglePower=this.Block.AnglePower;
    this.QVoltage_unit=this.Block.QVoltage_unit;
    this.QCurrent_unit=this.Block.QCurrent_unit;
    this.CarrierFreq=this.Block.CarrierFreq;
    this.CarrierFreq_unit=this.Block.CarrierFreq_unit;
    this.AddPhaseNoise=strcmpi(this.Block.AddPhaseNoise,'on');
    this.PhaseNoiseOffset=this.Block.PhaseNoiseOffset;
    this.PhaseNoiseLevel=this.Block.PhaseNoiseLevel;
    this.AutoImpulseLength=strcmpi(this.Block.AutoImpulseLength,'on');
    this.ImpulseLength=this.Block.ImpulseLength;
    this.ImpulseLength_unit=this.Block.ImpulseLength_unit;

    this.InternalGrounding=strcmpi(this.Block.InternalGrounding,'on');


