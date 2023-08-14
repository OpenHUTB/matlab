












function[value,isResolved]=getMtreeValue(mtreeNode,blkCompatObj)

    assert(isa(blkCompatObj,'slci.simulink.Block'),...
    'Invalid input argument');
    assert(isa(mtreeNode,'mtree'),'Invalid input argument');

    if any(strcmpi(mtreeNode.kind,{'DOUBLE','INT'}))
        strToResolve=mtreeNode.string;
    elseif strcmpi(mtreeNode.kind,'ID')
        strToResolve=mtreeNode.string;
    elseif any(strcmpi(mtreeNode.kind,{'CALL','LP'}))
        strToResolve=tree2str(mtreeNode);
    else
        assert(false,['Invalid input node kind ',mtreeNode.kind]);
    end

    [value,isResolved]=resolveValue(strToResolve,...
    blkCompatObj.getSID());
    if isResolved&&(isa(value,'numeric')||isa(value,'logical'))
        isResolved=true;
    else
        isResolved=false;
    end
end

function[value,isResolved]=resolveValue(str,sid)
    try
        value=slResolve(str,sid);
    catch
        value=[];
        isResolved=false;
        return;
    end
    isResolved=true;
end
