function ports=getBlockPorts(blk,type)





    if isstruct(blk)
        ph=blk;
    else
        ph=get_param(blk,'PortHandles');
    end
    switch type
    case 'inport'
        ports=[ph.Inport,ph.Enable,ph.Trigger,ph.Ifaction,ph.Reset];
    case 'outport'

        ports=[ph.Outport,ph.State];
    case 'strict_inport'
        ports=ph.Inport;
    case 'strict_outport'

        ports=ph.Outport;
    end