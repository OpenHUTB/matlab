function duplicate(sourceArtifact,sourceIds,destArtifact,lineRanges)






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


    rangeHelper=slreq.mleditor.ReqPluginHelper.getInstance();
    rangeHelper.reset(destArtifact);

    for i=1:numel(sourceIds)
        rangeId=sourceIds{i};
        startPos=rangeHelper.lineNumberToCharPosition(destArtifact,lineRanges(i).first,1);
        endPos=rangeHelper.lineNumberToCharPosition(destArtifact,lineRanges(i).last,-1);
        charRange=[startPos,endPos];

        if isMove(i)

            moveBookmark(destArtifact,rangeId,charRange);
        else


            success=rmiml.duplicateLinks(sourceArtifact,rangeId,destArtifact,charRange);
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
                lines=[linkedItem.startLine,linkedItem.endLine];
                rmiml.notifyEditor(artifact,rangeId,lines);
            end
        end
    end
end
