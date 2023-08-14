function coderDictionaryOutportBlockEmbeddedSignal(obj)




    blkType='Outport';

    if(isR2016aOrEarlier(obj.ver))
        OutportBlocks=slexportprevious.utils.findBlockType(obj.modelName,blkType);
        for i=1:length(OutportBlocks)
            blk=OutportBlocks{i};
            if(~isempty(get_param(blk,'SignalObject')))
                set_param(blk,'SignalObject',[]);
            end
            if(~isempty(get_param(blk,'SignalName')))
                set_param(blk,'SignalName','');
            end
        end
    end


