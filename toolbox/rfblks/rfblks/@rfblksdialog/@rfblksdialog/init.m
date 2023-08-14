function init(this,block)



    this.Block=block;


    parent=this.Block.getParent;
    while~isa(parent,'Simulink.BlockDiagram')
        if~isempty(parent)


            parent=parent.getParent;
        end
    end
    this.Root=parent;