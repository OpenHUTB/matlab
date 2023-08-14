classdef Edge<handle

    properties
        Id char
        Uuid char
        SourceNodeId char
        DestinationNodeId char
        Label char
        Summary char

LinkType
LinkSubType
NavigateId

LinkSetPath
ArtifactPath




        EdgeType='Link';

        Domain='link';

        ChangeInfo;
HasChanged
    end


    methods
        function this=Edge(~)

        end

        function out=exportToStruct(this)
            out.Id=this.Id;
            out.Uuid=this.Uuid;
            out.SourceNode=this.SourceNodeId;
            out.DestinationNode=this.DestinationNodeId;
            out.Label=this.Label;
            out.LinkType=this.LinkType;
            out.LinkSubType=this.LinkSubType;
            out.LinkSetPath=this.LinkSetPath;
            out.ArtifactPath=this.ArtifactPath;
            out.EdgeType=this.EdgeType;
            out.ChangeInfo=this.ChangeInfo;
            out.HasChanged=this.HasChanged;
        end


    end


    methods(Static)

        function out=getEdgeKey(dataLink)
            if isa(dataLink,'slreq.data.Link')
                out=dataLink.getFullID;
            elseif isa(dataLink,'slreq.data.linkSet')
                out=dataLink.filepath;
            elseif isa(dataLink,'slreq.internal.tracediagram.data.ArtifactDependency')
                out=dataLink.Id;
            end
        end
    end
end
