

function segHandle=getInputSegmentHandle(block)
    if ischar(block)
        block=get_param(block,'Handle');
    end
    portHandles=get_param(block,'PortHandles');

    inportHandle=sltrace.utils.getAllInportHandles(portHandles);
    if length(inportHandle)==1
        segHandle=get_param(inportHandle,'Line');
    else
        segHandle=cell2mat(get_param(inportHandle(:),'Line'));
    end
end