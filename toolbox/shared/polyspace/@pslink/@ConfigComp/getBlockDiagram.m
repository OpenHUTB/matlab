











function bd=getBlockDiagram(hObj)





    bd=hObj.up;
    while~(isempty(bd)||(isa(bd,'Simulink.BlockDiagram')))
        bd=bd.up;
    end
