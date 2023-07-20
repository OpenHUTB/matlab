function port=findSegmentEndOutputPort(element,startSegment)
    if isa(element,'SLM3I.Port')&&strcmp(element.type,'Out Port')
        port=element;
    elseif isa(element,'SLM3I.SolderJoint')
        inEdges=element.inEdge;
        for i=1:inEdges.size
            edge=inEdges.at(i);
            if isa(edge,'SLM3I.Segment')&&edge~=startSegment
                port=SLStudio.internal.actions.findSegmentOutputPortFromEndpoint(edge,element);
                if isa(port,'SLM3I.Port')
                    return;
                end
            end
        end

        outEdges=element.outEdge;
        for i=1:outEdges.size
            edge=outEdges.at(i);
            if isa(edge,'SLM3I.Segment')&&edge~=startSegment
                port=SLStudio.internal.actions.findSegmentOutputPortFromEndpoint(edge,element);
                if isa(port,'SLM3I.Port')
                    return;
                end
            end
        end
    else
        port=[];
    end
end