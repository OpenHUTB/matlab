function dsmBlkH=findMatchingDataStoreMemoryBlock(obj)











    dsmBlkH=[];
    blkH=slreportgen.utils.getSlSfHandle(obj);

    if strcmp(get_param(blkH,'Type'),'block')
        blockType=get_param(blkH,'BlockType');
        if strcmp(blockType,'DataStoreRead')||strcmp(blockType,'DataStoreWrite')
            dsName=get_param(blkH,'DataStoreName');
            parentBlk=get_param(blkH,'Parent');

            while(~isempty(parentBlk)&&isempty(dsmBlkH))
                blockType=get_param(blkH,'BlockType');
                if strcmp(blockType,'SubSystem')
                    dsName=Simulink.mapDataStoreName(blkH,dsName);
                end

                dsmBlkH=find_system(parentBlk,...
                'SearchDepth',1,...
                "MatchFilter",@Simulink.match.allVariants,...
                'BlockType','DataStoreMemory',...
                'DataStoreName',dsName);

                blkH=get_param(parentBlk,'Handle');
                parentBlk=get_param(blkH,'Parent');
            end

            if~isempty(dsmBlkH)
                dsmBlkH=get_param(dsmBlkH{1},'Handle');
            end
        end
    end

end
