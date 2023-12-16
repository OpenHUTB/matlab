function anchorsAndLabels=getLinkAnchorsAndLabels(editorId)

    anchorsAndLabels={};

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

    if~isempty(rangesAndLabels)
        anchorsAndLabels={rangesAndLabels(:,1),...
        rangesAndLabels(:,2),rangesAndLabels(:,3),...
        rangesAndLabels(:,4),rangesAndLabels(:,5)};
    end
end
