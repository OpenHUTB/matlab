function port=findSegmentOutputPortFromEndpoint(segment,startEndpoint)
    port=[];
    if segment.srcElement~=startEndpoint
        port=SLStudio.internal.actions.findSegmentEndOutputPort(segment.srcElement,segment);
    end
    if~isa(port,'SLM3I.Port')&&segment.dstElement~=startEndpoint
        port=SLStudio.internal.actions.findSegmentEndOutputPort(segment.dstElement,segment);
    end
end