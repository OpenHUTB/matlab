function init(this,block)


    if isa(block,'double')
        block=get_param(block,'Object');
    end
    this.Block=block;


    parent=this.Block.getParent;
    while~isa(parent,'Simulink.BlockDiagram')
        if~isempty(parent)


            parent=parent.getParent;
        end
    end
    this.Root=parent;