classdef ArtifactGraph<slreq.internal.tracediagram.data.Graph

    properties(Access=private)
ArtifactDependencyDepot
    end

    methods

        function this=ArtifactGraph(targetViewId)
            this@slreq.internal.tracediagram.data.Graph(targetViewId);
            this.ColorId='Domain';
            this.GraphType=slreq.internal.tracediagram.data.GraphType.Artifact;
            this.ArtifactDependencyDepot=slreq.internal.tracediagram.data.ArtifactDependencyDepot.getInstance();
        end

        function preprocess(this)
            this.ArtifactDependencyDepot.refreshLinkData();
        end

        function node=createNode(this,itemInfo)
            node=slreq.internal.tracediagram.data.ArtifactNode(itemInfo);
            this.DomainList(node.Domain)=true;
        end

        function newEdge=createEdge(~,artifactDependency)
            newEdge=slreq.internal.tracediagram.data.ArtifactEdge(artifactDependency);

        end


        function src=getLinkSource(~,artifactDependency)
            src=artifactDependency.SourceArtifact;
        end

        function out=getLinkDestination(~,artifactDependency)
            dst=artifactDependency.DestinationArtifact;

            out.artifactUri=dst;
            out.id='';
            out.domain=artifactDependency.DestinationDomain;
        end


        function out=getStreamDepthOffset(this,artifactDependency,isTracedFromSrc)
            allTypes=artifactDependency.TypeCount.keys;
            currentStreamOffSet=0;
            isStreamTypeUnique=true;
            for index=1:length(allTypes)
                cType=allTypes{index};
                typeName=getBaseTypeName(cType);
                cStreamOffset=this.getStreamType(typeName,isTracedFromSrc);
                if currentStreamOffSet~=0&&cStreamOffset~=currentStreamOffSet
                    isStreamTypeUnique=false;
                    break;
                else
                    currentStreamOffSet=cStreamOffset;
                end
            end
            artifactDependency.IsStreamUnique=isStreamTypeUnique;
            if artifactDependency.IsStreamUnique
                out=currentStreamOffSet;
            elseif isTracedFromSrc

                out=-1;
            else
                out=1;
            end
        end


        function[inLinks,outLinks]=getDataLinks(this,nodeId)
            node=this.Nodes(nodeId);
            [inLinks,outLinks]=node.getLinks;
        end


        function setStartingPoint(this,dataObj)
            if isa(dataObj,'slreq.data.RequirementSet')
                this.setStartingNodes({dataObj});
            elseif isstruct(dataObj)
                this.setStartingNodes({dataObj.artifactUri});
            elseif ischar(dataObj)

                this.setStartingNodes({dataObj});
            else
                this.setStartingNodes({dataObj.artifact});
            end
        end
    end
end


function baseTypeName=getBaseTypeName(typeName)
    [prfName,stereotype,~]=slreq.internal.ProfileTypeBase.getProfileStereotype(...
    typeName);
    if~isempty(prfName)&&~isempty(stereotype)


        if exist([prfName,'.xml'],'file')
            baseBehavior=slreq.internal.ProfileTypeBase.getMetaAttrValue(typeName,'BaseBehavior');
            if~isempty(baseBehavior)
                baseTypeName=baseBehavior;
            else

                baseTypeName=typeName;
            end
            return;
        end
    end

    try
        baseTypeName=slreq.app.LinkTypeManager.getBaseTypeName(typeName);
    catch ME
        baseTypeName=typeName;
    end
end