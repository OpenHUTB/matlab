classdef ArtifactEdge<slreq.internal.tracediagram.data.Edge


    methods
        function this=ArtifactEdge(artifactDependency)
            this.Id=artifactDependency.Id;
            reqData=slreq.data.ReqData.getInstance;
            dataLinkSet=reqData.getLinkSet(artifactDependency.SourceArtifact);
            this.Uuid=dataLinkSet.getUuid;
            this.NavigateId=this.Uuid;
            this.EdgeType='LinkSet';


            this.Domain='linkset';
            this.SourceNodeId=artifactDependency.SourceArtifact;
            this.DestinationNodeId=artifactDependency.DestinationArtifact;
            this.Label=artifactDependency.getDisplayLabel();
            this.Summary=[getString(message('Slvnv:slreq:LinkSet')),' - ',dataLinkSet.name];



            this.LinkType=artifactDependency.TypeCount;
            this.LinkSetPath=dataLinkSet.filepath;

            this.HasChanged=artifactDependency.ChangedLinks.Count>0;
            this.ChangeInfo=artifactDependency.ChangedLinks;
        end
    end
end
