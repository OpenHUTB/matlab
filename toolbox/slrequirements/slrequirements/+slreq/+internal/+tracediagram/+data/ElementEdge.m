classdef ElementEdge<slreq.internal.tracediagram.data.Edge


    methods
        function this=ElementEdge(dataLink)
            this.Id=dataLink.getFullID;
            this.Uuid=dataLink.getUuid;
            this.NavigateId=this.Uuid;
            isStereotype=slreq.internal.ProfileLinkType.isProfileStereotype(...
            dataLink.getLinkSet,dataLink.type);
            if isStereotype
                this.Label=slreq.internal.ProfileLinkType.getForwardName(dataLink);
            else
                this.Label=slreq.app.LinkTypeManager.getForwardName(dataLink.type);
            end
            this.Summary=[getString(message('Slvnv:slreq:Link')),' - ',dataLink.getDisplayLabel()];

            linkSet=dataLink.getLinkSet;
            this.LinkSetPath=linkSet.filepath;
            this.ArtifactPath=linkSet.artifact;

            ctvisitor=slreq.analysis.ChangeTrackingRefreshVisitor();
            ctvisitor.visitLink(dataLink);
            this.ChangeInfo.HasChangedDestination=dataLink.destinationChangeStatus.isFail;
            this.ChangeInfo.HasChangedSource=dataLink.sourceChangeStatus.isFail;

            this.HasChanged=this.ChangeInfo.HasChangedDestination||this.ChangeInfo.HasChangedSource;

            [this.LinkType,this.LinkSubType]=slreq.internal.tracediagram.utils.getLinkType(dataLink);


            this.SourceNodeId=slreq.internal.tracediagram.data.Node.getNodeKey(dataLink.source);
            [adapter,artifact,id]=dataLink.getDestAdapter;
            destStruct.domain=adapter.domain;
            destStruct.artifactUri=artifact;
            destStruct.id=id;
            this.DestinationNodeId=slreq.internal.tracediagram.data.Node.getNodeKey(destStruct);
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
end
