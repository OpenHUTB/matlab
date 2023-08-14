function anchorsAndLabels=getLinkAnchorsAndLabels(editorId)







    anchorsAndLabels={};

    if rmisl.isSidString(editorId)




        [isFromLib,inLibSID]=rmisl.isActiveLibRefSID(editorId);
        if isFromLib
            anchorsAndLabels=slreq.mleditor.getLinkAnchorsAndLabels(inLibSID);
            if~isempty(anchorsAndLabels)
                anchorsAndLabels{4}=addLibPrefix(anchorsAndLabels{4},inLibSID);
            end
            return;
        end
    end

    [canLink,fKey]=rmiml.canLink(editorId);
    if~canLink
        return;
    end


    if rmisl.isSidString(fKey)
        artifactPath=get_param(strtok(fKey,':'),'FileName');
    else
        artifactPath=fKey;
    end
    if~slreq.utils.loadLinkSet(artifactPath,false)
        return;
    end



    rangesAndLabels=slreq.utils.getRangesAndLabels(editorId);


    rangeHelper=slreq.mleditor.ReqPluginHelper.getInstance();
    rangeHelper.reset(editorId);
    rangesAndLabels(:,2)=rangeHelper.charPositionToLineNumber(editorId,rangesAndLabels(:,2));
    rangesAndLabels(:,3)=rangeHelper.charPositionToLineNumber(editorId,rangesAndLabels(:,3));



    if~isempty(rangesAndLabels)
        anchorsAndLabels={rangesAndLabels(:,1),...
        rangesAndLabels(:,2),rangesAndLabels(:,3),...
        rangesAndLabels(:,4),rangesAndLabels(:,5)};
    end
end

function labels=addLibPrefix(labels,libBlockSID)


    libName=strtok(libBlockSID,':');
    for i=1:size(labels,1)
        updated=strrep(labels{i},newline,[newline,libName,': ']);
        labels{i}=[libName,': ',updated];
    end
end
