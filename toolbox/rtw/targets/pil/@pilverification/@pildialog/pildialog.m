function obj=pildialog(hBlock,hXILBlock)








    obj=pilverification.pildialog(hBlock);


    obj.Block=get_param(hXILBlock,'object');


    parent=obj.Block.getParent;
    while~isa(parent,'Simulink.BlockDiagram')
        parent=parent.getParent;
    end
    obj.Root=parent;
