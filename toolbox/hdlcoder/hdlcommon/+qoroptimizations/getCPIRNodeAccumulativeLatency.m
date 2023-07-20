


function latency=getCPIRNodeAccumulativeLatency(node,cp)
    l=node.cumulativeDelay;
    offset=cp.getOffset;
    if(cp.getRequirement>0)
        offset=-offset;
    end
    if(abs(offset-(cp.getDataPathDelay+cp.getClockPathDelay+cp.getClockUncertainty)+cp.getRequirement)<1e-5)
        latency=l+cp.getClockPathDelay+cp.getClockUncertainty;
    else
        assert(abs(offset-(cp.getDataPathDelay-cp.getClockPathDelay+cp.getClockUncertainty)+cp.getRequirement)<1e-5);
        latency=l-cp.getClockPathDelay+cp.getClockUncertainty;
    end
end