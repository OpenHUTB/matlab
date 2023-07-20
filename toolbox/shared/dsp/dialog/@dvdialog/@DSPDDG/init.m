function init(this,block)



    this.Block=block;


    parent=this.Block.getParent;
    while~isa(parent,'Simulink.BlockDiagram')
        if~isempty(parent)


            parent=parent.getParent;
        else








            if(strcmp(this.Block.IOType,'siggen')||...
                strcmp(this.Block.IOType,'viewer'))
                parent=get_param(this.Block.parent,'object');
            end
        end
    end
    this.Root=parent;

