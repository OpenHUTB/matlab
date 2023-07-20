function openParentPOUBlock(block)



    pouBlock=slplc.utils.getParentPOU(block);
    if isempty(pouBlock)
        return
    end
    upperLevelBlock=get_param(pouBlock,'Parent');
    open_system(upperLevelBlock,'force');
end