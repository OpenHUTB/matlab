function duplicate(sourceArtifact,sourceIds,destArtifact,destRanges)






    isMove=false(size(sourceIds));
    isSameArtifact=strcmp(sourceArtifact,destArtifact);
    if isSameArtifact


        for i=1:numel(sourceIds)
            range=rmiml.idToRange(sourceArtifact,sourceIds{1});
            if~isempty(range)&&range(2)<=0
                isMove(i)=true;
            end
        end
    end

    for i=1:numel(sourceIds)
        rangeId=sourceIds{i};
        newRange=[destRanges(i).first,destRanges(i).last];
        if isMove(i)

            moveBookmark(destArtifact,rangeId,newRange);
        else


            success=rmiml.duplicateLinks(sourceArtifact,rangeId,destArtifact,newRange);
            if~success
                rmiut.warnNoBacktrace(sprintf('Failed to duplicate links from %s:%s',sourceKey,rangeId));
            end
        end
    end
end

function moveBookmark(artifact,rangeId,newRange)
    if isfile(artifact)
        dataLinkSet=slreq.data.ReqData.getInstance.getLinkSet(artifact);
        if~isempty(dataLinkSet)
            linkedItem=dataLinkSet.getLinkedItem(rangeId);
            if~isempty(linkedItem)
                linkedItem.startPos=newRange(1);
                linkedItem.endPos=newRange(2);
                rmiml.notifyEditor(artifact,rangeId);
            end
        end
    end
end
