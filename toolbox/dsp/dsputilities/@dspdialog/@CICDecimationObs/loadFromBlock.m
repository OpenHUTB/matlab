function loadFromBlock(this)






    if strcmpi(this.Block.filtFrom,'dialog')
        this.FilterSource=0;
    else
        this.FilterSource=1;
    end

    this.mfiltObjectName=this.Block.filtobj;
    this.DecimationFactor=this.Block.R;
    this.DifferentialDelay=this.Block.M;
    this.NumberOfSections=this.Block.N;
    this.FilterInternals=this.Block.filterInternals;
    this.SectionWordLengths=this.Block.BPS;
    this.SectionFracLengths=this.Block.FLPS;
    this.OutputWordLength=this.Block.outputWordLength;
    this.OutputFracLength=this.Block.outputFracLength;
    this.RateOptions=this.Block.RateOptions;
