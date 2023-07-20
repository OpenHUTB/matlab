
function dsmBlkH=getDataStoreHandleFromReadWriteBlock(dsmReadWriteBlkH)








    dsmBlkH=[];
    dsName=get_param(dsmReadWriteBlkH,'DataStoreName');
    parentBlk=get_param(dsmReadWriteBlkH,'Parent');

    while(~isempty(parentBlk)&&isempty(dsmBlkH))
        blockType=get_param(dsmReadWriteBlkH,'BlockType');
        if strcmp(blockType,'SubSystem')
            dsName=Simulink.mapDataStoreName(dsmReadWriteBlkH,dsName);
        end

        dsmBlkH=find_system(parentBlk,...
        'SearchDepth',1,...
        'BlockType','DataStoreMemory',...
        'DataStoreName',dsName);

        dsmReadWriteBlkH=get_param(parentBlk,'Handle');
        parentBlk=get_param(dsmReadWriteBlkH,'Parent');
    end

    if~isempty(dsmBlkH)
        dsmBlkH=get_param(dsmBlkH{1},'Handle');
    end
end