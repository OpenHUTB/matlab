function bd=getBlockDiagram(smc)







    bd=smc.up;
    while~(isempty(bd)||bd.isa('Simulink.BlockDiagram'))
        bd=bd.up;
    end



