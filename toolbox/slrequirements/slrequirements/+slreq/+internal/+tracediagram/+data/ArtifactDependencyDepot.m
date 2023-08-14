



















classdef ArtifactDependencyDepot<handle

    properties
LinkSets

ArtifactDependencyKeyToObj



SourceToOutLinks



DestinationToInLinks

        IsInitialized=false;
        IsLinkDataStale=true;


        DataChangeListeners={};
    end

    methods(Access=private)


        function this=ArtifactDependencyDepot()
            this.reset();
            reqData=slreq.data.ReqData.getInstance();
            this.DataChangeListeners{1}=reqData.addlistener('LinkDataChange',@this.onLinkDataChange);
        end


        function reset(this)
            this.ArtifactDependencyKeyToObj=containers.Map('KeyType','char','valueType','any');
            this.SourceToOutLinks=containers.Map('KeyType','char','valueType','any');
            this.DestinationToInLinks=containers.Map('KeyType','char','valueType','any');
            this.IsLinkDataStale=true;
        end
    end

    methods


        function onLinkDataChange(this,~,eventDataType)%#ok<INUSD>

            this.reset;
        end

        function delete(this)
            this.reset;
            for n=1:length(this.DataChangeListeners)
                delete(this.DataChangeListeners{n});
            end
            this.DataChangeListeners={};
        end


        function artifactDependencyObj=getOrCreateArtifactDependency(this,sourceArtifact,destinationArtifact)
            artifactDependencyKey=...
            slreq.internal.tracediagram.data.ArtifactDependency.getArtifactDependencyId(sourceArtifact,destinationArtifact);
            if isKey(this.ArtifactDependencyKeyToObj,artifactDependencyKey)
                artifactDependencyObj=this.ArtifactDependencyKeyToObj(artifactDependencyKey);
            else
                artifactDependencyObj=slreq.internal.tracediagram.data.ArtifactDependency(sourceArtifact,destinationArtifact);
                this.ArtifactDependencyKeyToObj(artifactDependencyKey)=artifactDependencyObj;
            end
        end

        function refreshLinkData(this)
            if this.IsInitialized&&~this.IsLinkDataStale
                return;
            end

            reqData=slreq.data.ReqData.getInstance;
            allLinkSets=reqData.getLoadedLinkSets;
            for index=1:length(allLinkSets)
                cLinkSet=allLinkSets(index);
                sourceArtifact=cLinkSet.artifact;

                allLinks=cLinkSet.getAllLinks();

                for lIndex=1:length(allLinks)
                    cLink=allLinks(lIndex);
                    if~isempty(cLink.dest)&&~cLink.isDirectLink
                        destPath=cLink.dest.getReqSetArtifactUri;
                    else
                        destPath=cLink.destUri;
                    end

                    pathHandler=slreq.uri.FilePathHelper(destPath);
                    destinationArtifact=pathHandler.getFullPath;
                    if isempty(destinationArtifact)
                        destinationArtifact=destPath;
                    end
                    artifactDependencyObj=this.getOrCreateArtifactDependency(sourceArtifact,destinationArtifact);
                    artifactDependencyObj.DestinationDomain=cLink.destDomain;
                    artifactDependencyObj.SourceDomain=cLink.source.domain;
                    artifactDependencyObj.addLink(cLink);
                    this.updateLinkInfo(artifactDependencyObj);
                end
            end

            this.IsInitialized=true;
            this.IsLinkDataStale=false;
        end

        function updateLinkInfo(this,artifactDependencyObj)
            sourceArtifact=artifactDependencyObj.SourceArtifact;
            destinationArtifact=artifactDependencyObj.DestinationArtifact;
            artifactDependencyId=artifactDependencyObj.Id;
            addLinkToMap(this.SourceToOutLinks,sourceArtifact,artifactDependencyId);
            addLinkToMap(this.DestinationToInLinks,destinationArtifact,artifactDependencyId);
        end

        function out=getOutLinkIds(this,artifactUri)
            out={};
            if isKey(this.SourceToOutLinks,artifactUri)
                out=this.SourceToOutLinks(artifactUri).keys';
            end
        end

        function out=getInLinkIds(this,artifactUri)
            out={};
            if isKey(this.DestinationToInLinks,artifactUri)
                out=this.DestinationToInLinks(artifactUri).keys';
            end
        end

        function out=getLinkObjFromId(this,id)
            if isKey(this.ArtifactDependencyKeyToObj,id)
                out=this.ArtifactDependencyKeyToObj(id);
            else
                out=slreq.internal.tracediagram.data.ArtifactDependency.empty;
            end
        end

        function out=getLinkObjsFromIds(this,idList)
            out=slreq.internal.tracediagram.data.ArtifactDependency.empty;
            if~iscell(idList)
                idList={idList};
            end
            for index=1:length(idList)
                cId=idList{index};
                out(end+1)=this.getLinkObjFromId(cId);%#ok<AGROW>
            end
        end

        function out=getOutLinks(this,artifactUri)
            out=this.getLinkObjsFromIds(this.getOutLinkIds(artifactUri));
        end

        function out=getInLinks(this,artifactUri)
            out=this.getLinkObjsFromIds(this.getInLinkIds(artifactUri));
        end
    end

    methods(Static)

        function result=exists()
            instance=slreq.internal.tracediagram.data.ArtifactDependencyDepot.getInstance(false);
            result=~isempty(instance)&&isvalid(instance);
        end

        function clearData()

            if slreq.internal.tracediagram.data.ArtifactDependencyDepot.exists()
                depDepot=slreq.internal.tracediagram.data.ArtifactDependencyDepot.getInstance();
                delete(depDepot);
            end
        end

        function out=getInstance(doInit)
            persistent artifactDepot
            if nargin<1
                doInit=true;
            end

            if(isempty(artifactDepot)||~isvalid(artifactDepot))&&doInit
                artifactDepot=slreq.internal.tracediagram.data.ArtifactDependencyDepot();
            end

            out=artifactDepot;
        end
    end
end

function addLinkToMap(linkMap,keyId,valueId)
    if isKey(linkMap,keyId)
        valueMap=linkMap(keyId);
    else
        valueMap=containers.Map('KeyType','char','ValueType','logical');
    end
    valueMap(valueId)=true;
    linkMap(keyId)=valueMap;%#ok<NASGU> map operation. 
end

