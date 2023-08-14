function deletePorts(handleToBlock,portIdxs)











    try
        blockHandle=handleToBlock;


        if ischar(handleToBlock)||isstring(handleToBlock)
            blockHandle=get_param(handleToBlock,"Handle");
        end

        Simulink.playback.internal.deletePortsInBlock(blockHandle,portIdxs);
    catch me
        me.throwAsCaller();
    end
end
