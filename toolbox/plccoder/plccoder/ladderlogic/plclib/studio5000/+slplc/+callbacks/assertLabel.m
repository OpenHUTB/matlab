function assertLabel(block)




    if slplc.utils.isRunningModelGeneration(block)
        return
    end

    parentBlock=get_param(block,'Parent');
    blockName=get_param(parentBlock,'Name');
    pat='^_s\d+_\d+_(\w+)_AssertZero$';
    t=regexp(blockName,pat,'tokens');
    labelName=t{1}{1};

    parentPOUBlock=slplc.utils.getParentPOU(parentBlock);
    fprintf('Tried to jump to an invalid label %s that may be not defined in the ladder diagram: %s',...
    labelName,parentPOUBlock);

end