classdef Constraint<handle





    properties

        AutoRefresh=true





        ShouldGetExpandedGraph=false;



        Upstream=false;


        Downstream=false;



        TraceDepth=Inf;


        Layout slreq.internal.tracediagram.data.LayoutType=slreq.internal.tracediagram.data.LayoutType.Vertical


        LinkSourceToStreamTypeMap=setDefaultLinkSourceToStreamTypeMap;
    end

    methods
        function this=Constraint()

        end
    end
end

function out=setDefaultLinkSourceToStreamTypeMap()







    out=containers.Map();
    out('Implement')=...
    slreq.internal.tracediagram.data.StreamType.Downstream;
    out('Derive')=...
    slreq.internal.tracediagram.data.StreamType.Upstream;
    out('Refine')=...
    slreq.internal.tracediagram.data.StreamType.Downstream;
    out('Verify')=...
    slreq.internal.tracediagram.data.StreamType.Downstream;
    out('Relate')=...
    slreq.internal.tracediagram.data.StreamType.Upstream;
    out('Confirm')=...
    slreq.internal.tracediagram.data.StreamType.Upstream;
end
