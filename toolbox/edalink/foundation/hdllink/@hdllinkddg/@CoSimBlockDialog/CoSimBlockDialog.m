function this=CoSimBlockDialog(block,dummy)





    this=hdllinkddg.CoSimBlockDialog(block);
    if isa(block,'double')
        block=get_param(block,'object');
    end



    this.Block=block;
    this.CurrentTab=0;
    this.DisableList=false;

    parent=this.Block.getParent;
    while~isa(parent,'Simulink.BlockDiagram')
        parent=parent.getParent;
    end
    this.Root=parent;

    this.ProductName=this.Block.ProductName;





    this.MaskParamsToSources;





    uddUtil=hdllinkddg.UddUtil;
    this.AllowDirectFeedthrough=uddUtil.MaskEnum2Bool(this.Block.AllowDirectFeedthrough);

    if(strcmp(this.Block.RunAutoTimescale,'on'))
        this.RunAutoTimescale=true;
    else
        this.RunAutoTimescale=false;
    end




    this.PreRunTime=this.Block.PreRunTime;
    this.PreRunTimeUnit=this.Block.PreRunTimeUnit;




    this.TclPreSimCommand=this.Block.TclPreSimCommand;
    this.TclPostSimCommand=this.Block.TclPostSimCommand;




    this.TimingMode=this.Block.TimingMode;
    this.TimingScaleFactor=this.Block.TimingScaleFactor;




