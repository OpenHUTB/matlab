function loadFromBlock(this)







    this.SensorType=this.Block.SensorType;
    this.ZL=this.Block.ZL;
    this.OutputFormat=this.Block.OutputFormat;
    this.CarrierFreq=this.Block.CarrierFreq;
    this.CarrierFreq_unit=this.Block.CarrierFreq_unit;
    this.InternalGrounding=strcmpi(this.Block.InternalGrounding,'on');
    this.AutoStep=strcmpi(this.Block.AutoStep,'on');
    this.StepSize=this.Block.StepSize;
    this.StepSize_unit=this.Block.StepSize_unit;


