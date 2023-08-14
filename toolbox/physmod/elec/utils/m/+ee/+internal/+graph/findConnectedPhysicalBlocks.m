function physicalBlockList=findConnectedPhysicalBlocks(block,portType)








    if~strcmp(get_param(block,'BlockType'),'SimscapeBlock')
        error('function input must be SimscapeBlock');
    end
    if~exist('portType','var')
        blockList=ee.internal.graph.findConnectedBlocksSameLevel(block);
    else
        blockList=ee.internal.graph.findConnectedBlocksSameLevel(block,portType);
    end

    physicalBlockList=ee.internal.graph.tracePhysicalBlocks(block,blockList);

end
