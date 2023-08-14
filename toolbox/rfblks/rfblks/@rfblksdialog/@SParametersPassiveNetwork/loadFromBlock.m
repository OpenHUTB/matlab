function loadFromBlock(this)








    this.NetParamData=this.Block.NetParamData;
    this.NetParamFreq=this.Block.NetParamFreq;
    if strcmp(this.Block.MaskType,'S-Parameters Passive Network')
        this.Z0=this.Block.Z0;
    else
        this.Z0='';
    end
    this.InterpMethod=this.Block.InterpMethod;


    this.SourceFreq=this.Block.SourceFreq;
    this.Freq=this.Block.Freq;
    this.AllPlotType=this.Block.AllPlotType;
    this.YOption=this.Block.YOption;
    this.XOption=this.Block.XOption;
    this.PlotZ0=this.Block.PlotZ0;


