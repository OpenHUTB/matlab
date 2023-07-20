function pwidth=getActualDstPortWidth(hBlk,portIdx)















    hPh=get_param(hBlk,'PortHandles');
    cpType=getActualDstPortType(hBlk,portIdx);

    switch cpType
    case 'DataPort'

        oPh=hPh.Outport;
        pwidth=get_param(oPh,'CompiledPortWidth');
        if iscell(pwidth)

            pwidth=pwidth{portIdx};
        end
    case 'StatePort'
        sPh=hPh.State;
        pwidth=get_param(sPh,'CompiledPortWidth');
    otherwise
        error('Unsupported port type: %s',cpType)
    end

end