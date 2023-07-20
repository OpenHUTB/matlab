function this=ToVcdBlock(block,dummy)






    this=hdllinkddg.ToVcdBlock(block);

    if isa(block,'double')
        block=get_param(block,'Object');
    end
    this.Block=block;
    this.DisableList=false;

    this.FileName=this.Block.FileName;
    this.NumInport=this.Block.NumInport;
    this.TimingScaleFactor=this.Block.TimingScaleFactor;
    this.TimingMode=this.Block.TimingMode;
    this.HdlTickScale=this.Block.HdlTickScale;
    this.HdlTickMode=this.Block.HdlTickMode;



    parent=this.Block.getParent;
    while~isa(parent,'Simulink.BlockDiagram')
        parent=parent.getParent;
    end
    this.Root=parent;

