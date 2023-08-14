function port=findSegmentOutputPort(segment)
    port=SLStudio.internal.actions.findSegmentEndOutputPort(segment.srcElement,segment);
    if~isa(port,'SLM3I.Port')
        port=SLStudio.internal.actions.findSegmentEndOutputPort(segment.dstElement,segment);
    end
end