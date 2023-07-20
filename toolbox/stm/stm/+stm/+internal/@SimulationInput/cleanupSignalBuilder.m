
function cleanupSignalBuilder(simWatcher)

    cleanupStruct=simWatcher.cleanupIteration;

    if~isempty(simWatcher.signalBuilderBlock)&&...
        ~isempty(simWatcher.signalBuilderBlock.handle)
        simWatcher.signalBuilderBlock.delete();
    elseif(isfield(cleanupStruct,'SignalBuilder')&&isfield(cleanupStruct,'SigBuilderIndex')...
        &&~isempty(cleanupStruct.SignalBuilder)&&~isempty(cleanupStruct.SigBuilderIndex))



        block=stm.internal.blocks.SignalSourceBlock.getBlock(cleanupStruct.SignalBuilder);


        block.delete(cleanupStruct.SigBuilderIndex);
    end

end