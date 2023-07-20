function ret=isBlockRegistered(target,block)
















    block=convertStringsToChars(block);


    ret=any(strcmp(block,target.registered_blocks));
