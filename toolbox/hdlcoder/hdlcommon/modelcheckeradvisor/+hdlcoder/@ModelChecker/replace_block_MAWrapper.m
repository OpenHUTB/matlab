function repBlks=replace_block_MAWrapper(blockToBeReplaced,replacementBlockType)






    blkName=get_param(blockToBeReplaced,'Name');
    repBlks=replace_block(blockToBeReplaced,'Name',blkName,replacementBlockType,'noprompt');
end
