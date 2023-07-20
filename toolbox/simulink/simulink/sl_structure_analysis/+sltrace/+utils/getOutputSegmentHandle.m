

function outSegHandle=getOutputSegmentHandle(block)
    if ischar(block)
        block=get_param(block,'Handle');
    end
    portHandles=get_param(block,'PortHandles');
    outport=portHandles.Outport;
    if length(outport)==1
        outSegHandle=get_param(outport,'Line');
    else
        outSegHandle=cell2mat(get_param(outport(:),'Line'));
    end
end