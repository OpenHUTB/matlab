function value=hasActualSrcInfo(blk,portIdx)




















    if~strcmp(get_param(bdroot(blk),'SimulationStatus'),'paused')
        error('hasActualSrcInfo:notupdating',...
        'Model must be in a compiled state')
    end

    ports=get_param(blk,'Ports');
    portType=getActualSrcPortType(blk,portIdx);

    switch portType
    case 'DataPort'
        hasPorts=ports(1)+hasInvisibleInput(blk);
    case 'EnablePort'
        hasPorts=ports(3)>0;
    case 'TriggerPort'
        hasPorts=ports(4);
    case 'IfactionPort'
        hasPorts=ports(8)>0;
    case 'ControlPort'
        hasEnablePort=ports(3)>0;
        hasTriggerPort=ports(4)>0;
        hasIfactionPort=ports(8)>0;
        hasPorts=hasEnablePort||hasTriggerPort||hasIfactionPort;
    otherwise
        error('hasActualSrcInfo:unkowntype','Unknown type: %s',portType)
    end

    if isPostCompileVirtual(blk)||~hasPorts
        value=false;
    else
        value=true;
    end

end