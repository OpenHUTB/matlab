function loadFromBlock(this)







    this.AccIncSrc=this.Block.AccIncSrc;
    this.AccInc=this.Block.AccInc;
    this.PhaseOffsetSrc=this.Block.PhaseOffsetSrc;
    this.PhaseOffset=this.Block.PhaseOffset;
    this.AccumWL=this.Block.AccumWL;
    this.Formula=this.Block.Formula;
    this.HasPhaseQuantizer=strcmpi(this.Block.HasPhaseQuantizer,'on');
    this.HasOutputPhaseError=strcmpi(this.Block.HasOutputPhaseError,'on');
    this.HasDither=strcmpi(this.Block.HasDither,'on');
    this.DitherWL=this.Block.DitherWL;
    this.PNgeneratorLength=this.Block.PNgeneratorLength;
    this.SampleTime=this.Block.SampleTime;
    this.SamplesPerFrame=this.Block.SamplesPerFrame;
    this.DataType=this.Block.DataType;
    this.OutputWL=this.Block.OutputWL;
    this.OutputFL=this.Block.OutputFL;
    this.CompMethod=this.Block.CompMethod;
    this.TableDepth=this.Block.TableDepth;
