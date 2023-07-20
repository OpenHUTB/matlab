classdef ElementGraph<slreq.internal.tracediagram.data.Graph

    properties


    end

    methods

        function this=ElementGraph(targetViewID)
            this@slreq.internal.tracediagram.data.Graph(targetViewID);
            this.ColorId='ArtifactUri';
            this.GraphType=slreq.internal.tracediagram.data.GraphType.Element;
        end

        function newNode=createNode(this,itemInfo)
            newNode=slreq.internal.tracediagram.data.ElementNode(itemInfo);
            this.ArtifactList(newNode.ArtifactUri)=true;
            if isKey(this.DomainList,newNode.Domain)
                domainInfo=this.DomainList(newNode.Domain);
            else
                domainInfo=containers.Map('KeyType','char','ValueType','logical');
            end

            domainInfo(newNode.ArtifactUri)=true;
            this.DomainList(newNode.Domain)=domainInfo;
        end

        function newEdge=createEdge(~,dataLink)
            newEdge=slreq.internal.tracediagram.data.ElementEdge(dataLink);
        end

        function src=getLinkSource(~,dataLink)
            src=dataLink.source;
        end

        function dst=getLinkDestination(~,dataLink)
            if isempty(dataLink.dest)
                [adapter,artifact,id]=dataLink.getDestAdapter;
                dst.domain=adapter.domain;
                dst.artifactUri=artifact;
                dst.id=id;
            else
                dst=dataLink.dest;
            end
        end

        function out=getStreamDepthOffset(this,dataLink,isTracedFromSrc)
            isStereotype=slreq.internal.ProfileLinkType.isProfileStereotype(...
            dataLink.getLinkSet,dataLink.type);
            if isStereotype
                baseBehavior=slreq.internal.ProfileLinkType.getMetaAttrValue(...
                dataLink,'BaseBehavior');
                if isempty(baseBehavior)
                    typeName=dataLink.type;
                else
                    typeName=baseBehavior;
                end
            else
                typeName=slreq.app.LinkTypeManager.getBaseTypeName(dataLink.type);
            end
            out=this.getStreamType(typeName,isTracedFromSrc);
        end


        function setStartingPoint(this,dataObj)
            if isa(dataObj,'slreq.data.Link')
                this.setStartingNodes({dataObj.source});
            else
                this.setStartingNodes({dataObj});
            end
        end
    end
end

