function result=inLibrary(obj,isSf)

    if nargin<2
        [isSf,objH,errMsg]=rmi.resolveobj(obj);
        if~isempty(errMsg)
            error(message('Simulink:util:ErrorOfExecutingCommand','rmi.resolveobj()',errMsg));
        end
    else
        objH=obj;
    end

    if rmifa.isFaultInfoObj(objH)
        result=false;
        return;
    end

    if isSf
        slH=rmisf.sfinstance(objH);
    else
        slH=objH;
    end

    blockType=get_param(slH,'type');
    if strcmpi(blockType,'block_diagram')
        result=false;
    elseif strcmpi(blockType,'annotation')
        result=checkParent(slH);
    elseif strcmpi(blockType,'port')&&sysarch.isZCPort(slH)
        result=checkParent(slH);
    else
        linkStatus=get_param(slH,'StaticLinkStatus');
        switch linkStatus
        case 'none'
            result=false;
        case 'implicit'
            result=true;
        case{'resolved','inactive'}
            result=checkParent(slH);
        otherwise
            result=checkParent(slH);
        end
    end
end


function out=checkParent(slH)

    parent=get_param(slH,'Parent');
    if strcmpi(get_param(parent,'type'),'block_diagram')
        out=false;
    else
        parentStatus=get_param(parent,'StaticLinkStatus');
        if any(strcmpi(parentStatus,{'implicit','resolved'}))
            out=true;
        else
            out=false;
        end
    end
end
