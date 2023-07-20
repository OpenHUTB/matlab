function publishMessage(handleToBlock,messageId)











    try
        blockHandle=handleToBlock;


        if ischar(handleToBlock)||isstring(handleToBlock)
            blockHandle=get_param(handleToBlock,"Handle");
        end

        Simulink.playback.internal.publishMessageToBlockUi(blockHandle,messageId);
    catch me
        me.throwAsCaller();
    end
end
