function stateOwnerBlocks=getStateOwnerBlocks(model)





    stateOwnerBlocks=[];
    stateAccessorMap=get_param(model,'StateAccessorInfoMap');

    for i=1:length(stateAccessorMap)
        stateReaderBlockHandles=stateAccessorMap(i).StateReaderBlockSet;
        stateWriterBlockHandles=stateAccessorMap(i).StateWriterBlockSet;
        if~isempty(stateReaderBlockHandles)||...
            ~isempty(stateWriterBlockHandles)
            stateOwnerBlocks=[stateOwnerBlocks,stateAccessorMap(i).StateOwnerBlock];
        end
    end
end
