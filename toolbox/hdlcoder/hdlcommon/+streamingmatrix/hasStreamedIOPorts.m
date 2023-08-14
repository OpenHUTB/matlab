



function doesit=hasStreamedIOPorts(hN)
    doesit=hasTag(hN.PirInputPorts)||hasTag(hN.PirOutputPorts);
end

function doesit=hasTag(ports)
    doesit=false;

    for i=1:numel(ports)
        pt=ports(i);
        if pt.hasStreamingMatrixTag
            tag=pt.getStreamingMatrixTag;
            doesit=tag.getOrigNumRows>0;
            return;
        end
    end
end
