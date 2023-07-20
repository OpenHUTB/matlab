function pwidth=getActualSrcPortWidth(hBlk,portIdx)















    hPh=get_param(hBlk,'PortHandles');
    cpType=getActualSrcPortType(hBlk,portIdx);

    if hasInvisibleInput(hBlk)

        oPh=hPh.Outport;
        pwidth=get_param(oPh,'CompiledPortWidth');
    elseif strcmp(cpType,'DataPort')

        iPh=hPh.Inport;
        pwidth=get_param(iPh,'CompiledPortWidth');
        if iscell(pwidth)

            pwidth=pwidth{portIdx};
        end
    else

        cpH=getActualSrcControlPort(hPh,cpType);
        pwidth=get_param(cpH,'CompiledPortWidth');
    end

end