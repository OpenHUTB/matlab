function setAssertionLabelName(block)




    if slplc.utils.isRunningModelGeneration(block)
        return
    end

    blockName=get_param(block,'Name');
    pat='^_s\d+_\d+_(\w+)_AssertZero$';
    t=regexp(blockName,pat,'tokens');
    labelName=t{1}{1};

    assertionBlock=plc_find_system(block,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','BlockType','Assertion');
    assertionBlock=assertionBlock{1};

    blkName=sprintf('Label_%s_Assertion',labelName);
    set_param(assertionBlock,'Name',blkName);

end