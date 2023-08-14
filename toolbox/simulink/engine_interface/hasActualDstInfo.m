function value=hasActualDstInfo(blk,portIdx)


















    portType=getActualDstPortType(blk,portIdx);
    switch portType
    case 'DataPort'
        value=~isActDstVirtualBlk(blk);
    case 'StatePort'
        value=false;
    otherwise
        error('hasActualDstInfo:unknowntype','Unknown port type %s',...
        portType)
    end

end

function value=isActDstVirtualBlk(blk)







    value=false;

    if strcmp(get_param(blk,'virtual'),'on')
        value=true;
        blkType=get_param(blk,'BlockType');
        if strcmp(blkType,'Ground')
            value=false;
        elseif strcmp(blkType,'Inport')
            parent=get_param(blk,'Parent');
            obj=get_param(parent,'Object');
            if strcmp(class(obj),'Simulink.BlockDiagram')||...
                strcmp(get_param(parent,'TreatAsAtomicUnit'),'on')
                value=false;
            end
        end
    end

end