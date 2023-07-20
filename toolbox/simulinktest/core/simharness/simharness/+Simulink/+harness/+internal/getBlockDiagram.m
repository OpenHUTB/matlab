function bdname=getBlockDiagram(blk)




    try
        if ishandle(blk)
            blk=get(blk,'object');
        elseif ischar(blk)
            blk=get_param(blk,'object');
        end

        bd=blk;
        while~bd.isa('Simulink.BlockDiagram')
            bd=bd.up;
        end
        bdname=bd.Name;
    catch ME
        Simulink.harness.internal.error(ME);
    end
end

