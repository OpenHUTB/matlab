function loadFromBlock(this)







    this.num_targets=this.Block.num_targets;
    this.sourceEnable=this.Block.sourceEnable;
    this.isReset=strcmpi(this.Block.isReset,'on');
    this.sourceMeasure=this.Block.sourceMeasure;


    this.A=this.Block.A;
    this.H=this.Block.H;
    this.Q=this.Block.Q;
    this.R=this.Block.R;
    this.X=this.Block.X;
    this.P=this.Block.P;


    this.isOutputEstState=strcmpi(this.Block.isOutputEstState,'on');
    this.isOutputEstMeasure=strcmpi(this.Block.isOutputEstMeasure,'on');
    this.isOutputEstError=strcmpi(this.Block.isOutputEstError,'on');
    this.isOutputPrdState=strcmpi(this.Block.isOutputPrdState,'on');
    this.isOutputPrdMeasure=strcmpi(this.Block.isOutputPrdMeasure,'on');
    this.isOutputPrdError=strcmpi(this.Block.isOutputPrdError,'on');


