function loadFromBlock(this)







    this.AutoFreq=strcmpi(this.Block.AutoFreq,'on');
    this.Tones=this.Block.Tones;
    this.Tones_unit=this.Block.Tones_unit;
    this.Harmonics=this.Block.Harmonics;
    this.SolverType=this.Block.SolverType;
    this.SamplesPerFrame=this.Block.SamplesPerFrame;
    this.NormalizeCarrierPower=...
    strcmpi(this.Block.NormalizeCarrierPower,'on');
    this.EnableInterpFilter=...
    strcmpi(this.Block.EnableInterpFilter,'on');
    this.StepSize=this.Block.StepSize;
    this.StepSize_unit=this.Block.StepSize_unit;
    this.AddNoise=strcmpi(this.Block.AddNoise,'on');
    this.DefaultRNG=strcmpi(this.Block.defaultRNG,'on');
    this.Seed=this.Block.Seed;
    this.Temperature=this.Block.Temperature;
    this.Temperature_unit=this.Block.Temperature_unit;
    this.SolverDelFlag=this.Block.SolverDelFlag;
    this.AbsTol=this.Block.AbsTol;
    this.RelTol=this.Block.RelTol;
    this.MaxIter=this.Block.MaxIter;
    this.ErrorEstimationType=this.Block.ErrorEstimationType;
    this.SmallSignalApprox=strcmpi(this.Block.SmallSignalApprox,'on');
    this.AllSimFreqs=strcmpi(this.Block.AllSimFreqs,'on');
    this.SimFreqs=this.Block.SimFreqs;
    this.SimFreqs_unit=this.Block.SimFreqs_unit;


