function loadFromBlock(this)






    this.winmode=this.Block.winmode;
    this.wintype=this.Block.wintype;
    this.sampmode=this.Block.sampmode;
    this.samptime=this.Block.samptime;
    this.N=this.Block.N;
    this.Rs=this.Block.Rs;
    this.beta=this.Block.beta;
    this.numSidelobes=this.Block.numSidelobes;
    this.sidelobeLevel=this.Block.sidelobeLevel;
    this.winsamp=this.Block.winsamp;
    this.UserWindow=this.Block.UserWindow;
    this.OptParams=strcmpi(this.Block.OptParams,'on');
    this.UserParams=this.Block.UserParams;


    this.dataType=this.Block.dataType;
    this.isSigned=strcmpi(this.Block.isSigned,'on');
    this.wordLen=this.Block.wordLen;
    this.udDataType=this.Block.udDataType;
    this.fracBitsMode=this.Block.fracBitsMode;
    this.numFracBits=this.Block.numFracBits;

    this.FixptDialog.loadFromBlock;
