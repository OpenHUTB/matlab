

function baseGraph=getBaseGraph(block)
    baseGraph=block;
    if isa(block,'Simulink.BlockPath')
        blockParent=block.getParent;
    else
        blockParent=get_param(block,'Parent');
    end
    if isempty(blockParent)
        return;
    end
    baseGraph=sltrace.utils.getBaseGraph(blockParent);
end