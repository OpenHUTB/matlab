





classdef ArtifactDependency<handle

    properties

        Id char
        SourceArtifact char
        DestinationArtifact char
        SourceDomain char
        DestinationDomain char


TypeCount




StreamTypeCount



SubTypeCount



        IsTypeUnique;




        IsStreamUnique;


ChangedLinks

        Links;


    end

    methods
        function this=ArtifactDependency(sourceArtifact,destinationArtifact)
            this.Id=this.getArtifactDependencyId(sourceArtifact,destinationArtifact);
            this.ChangedLinks=containers.Map('KeyType','char','ValueType','logical');
            this.Links=containers.Map('KeyType','char','ValueType','double');
            this.TypeCount=containers.Map('KeyType','char','ValueType','double');
            this.SubTypeCount=containers.Map('KeyType','char','ValueType','double');
            this.SourceArtifact=sourceArtifact;
            this.DestinationArtifact=destinationArtifact;
        end

        function out=get.IsTypeUnique(this)
            out=this.TypeCount.Count==1;
        end

        function addLink(this,dataLink)


            linkKey=slreq.internal.tracediagram.data.Edge.getEdgeKey(dataLink);
            if isKey(this.Links,linkKey)
                return;
            end

            this.Links(linkKey)=true;
            if dataLink.destinationChangeStatus.isFail||dataLink.sourceChangeStatus.isFail
                this.addChangedLink(linkKey);
            end

            this.addLinkType(dataLink);
        end

        function addLinkType(this,dataLink)
            [type,subtype]=slreq.internal.tracediagram.utils.getLinkType(dataLink);
            if isKey(this.TypeCount,type)
                this.TypeCount(type)=this.TypeCount(type)+1;
            else
                this.TypeCount(type)=1;
            end

            if isKey(this.SubTypeCount,subtype)
                this.SubTypeCount(subtype)=this.SubTypeCount(subtype)+1;
            else
                this.SubTypeCount(subtype)=1;
            end

        end

        function addChangedLink(this,linkKey)
            this.ChangedLinks(linkKey)=true;
        end

        function out=getDisplayLabel(this)
            allTypes=this.TypeCount.keys;
            out='';
            for index=1:length(allTypes)
                cType=allTypes{index};
                cTypeNum=this.TypeCount(cType);
                out=sprintf('%s %s(%d)',out,slreq.app.LinkTypeManager.getForwardName(cType),cTypeNum);
            end
        end
    end

    methods(Static)
        function out=getArtifactDependencyId(srcArtifact,dstArtifact)


            out=sprintf('%s=>%s',srcArtifact,dstArtifact);
        end
    end
end
