function deleteSignals(handleToBlock,signalIds)











    try
        blockHandle=handleToBlock;


        if ischar(handleToBlock)||isstring(handleToBlock)
            blockHandle=get_param(handleToBlock,"Handle");
        end

        Simulink.playback.internal.deleteSignalsInBlock(blockHandle,signalIds);
    catch me
        me.throwAsCaller();
    end
end
