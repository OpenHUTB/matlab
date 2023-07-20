function[blockPortHandles,blockHandles,isaSource]=getPortConnections(portHandle,deleteLine)

    if nargin<2
        deleteLine=false;
    end

    blockPortHandles=[];
    blockHandles=[];
    isaSource=false;

    LineHandle=get_param(portHandle,'Line');
    if LineHandle~=-1
        if strcmpi(get_param(LineHandle,'Connected'),'on')
            blockPortHandles=get_param(LineHandle,'DstPortHandle');
            blockHandles=get_param(LineHandle,'DstBlockHandle');
            if any(blockPortHandles==portHandle)
                blockPortHandles=get_param(LineHandle,'SrcPortHandle');
                blockHandles=get_param(LineHandle,'SrcBlockHandle');
                isaSource=true;
            end
        end
        if deleteLine
            delete_line(LineHandle);
        end
    end
