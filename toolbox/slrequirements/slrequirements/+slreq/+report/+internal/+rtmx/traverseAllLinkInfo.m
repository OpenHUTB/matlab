function out=traverseAllLinkInfo(allLinkSets)
    if nargin<1
        reqdata=slreq.data.ReqData.getInstance;
        allLinkSets=reqdata.getLoadedLinkSets;
    end

    out.allSrcReqArtifact={};
    out.allSrcArtifact={};
    out.allSrcID2Artifact=containers.Map;
    out.allDstArtifact=slreq.data.RequirementSet.empty;
    out.allDstReqArtifact=slreq.data.RequirementSet.empty;

    out.linkSet2LinkedItems=containers.Map;

    out.srcDstToLinkMap=containers.Map;
    out.linkMap=containers.Map;
    out.realSrcToSrcItemMap=containers.Map;

    mgr=slreq.app.MainManager.getInstance;

    for lsIndex=1:length(allLinkSets)
        cLinkSet=allLinkSets(lsIndex);


        allLinks=cLinkSet.getAllLinks;
        allLinkedItems=cLinkSet.getLinkedItems;
        for liindex=1:length(allLinkedItems)
            cLinkedItem=allLinkedItems(liindex);
            out.allSrcID2Artifact(cLinkedItem.getUuid)=cLinkedItem.artifactUri;
        end
        out.linkSet2LinkedItems(cLinkSet.artifact)=allLinkedItems;
        for lIndex=1:length(allLinks)
            fprintf('.');
            cLink=allLinks(lIndex);
            src=cLink.source;

            srcUuid=src.getUuid;

            if slreq.utils.hasValidDest(cLink)
                dst=cLink.dest;
                dstUuid=dst.getUuid;
            else
                disp('??');
            end

            srcDstKey=[srcUuid,'->',dstUuid];
            srcDstValue=cLink.getUuid;
            out.srcDstToLinkMap(srcDstKey)=srcDstValue;
            out.linkMap(srcDstValue)=cLink;


            if strcmp(src.domain,'linktype_rmi_slreq')

                if~ismember(src.artifactUri,out.allSrcReqArtifact)
                    out.allSrcReqArtifact{end+1}=src.artifactUri;
                end
                realSrc=slreq.utils.getReqObjFromSourceItem(src);
                out.realSrcToSrcItemMap(realSrc.getUuid)=srcUuid;
            else
                if~ismember(src.artifactUri,out.allSrcArtifact)
                    out.allSrcArtifact{end+1}=src.artifactUri;
                end
            end

            if strcmp(cLink.destDomain,'linktype_rmi_slreq')
                if isempty(out.allDstReqArtifact)
                    out.allDstReqArtifact(1)=dst.getReqSet;
                elseif~ismember(dst.getReqSet,out.allDstReqArtifact)
                    out.allDstReqArtifact(end+1)=dst.getReqSet;
                end


            else
                if isempty(out.allDstReqArtifact)
                    out.allDstArtifact(1)=dst.getReqSet;
                elseif~ismember(dst.getReqSet,out.allDstArtifact)
                    out.allDstArtifact(end+1)=dst.getReqSet;
                end
            end
        end

    end
end
