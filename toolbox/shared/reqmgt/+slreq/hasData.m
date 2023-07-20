





function yesno=hasData(artifact)

    if~slreq.data.ReqData.exists()
        yesno=false;
        return;
    end

    artifact=convertStringsToChars(artifact);

    id='';
    if ischar(artifact)&&any(artifact=='.')
        artifactPath=artifact;
    else

        if ischar(artifact)
            [artifact,id]=strtok(artifact,':');
        end
        artifactPath=get_param(artifact,'FileName');
    end

    linkSet=slreq.data.ReqData.getInstance.getLinkSet(artifactPath);
    yesno=~isempty(linkSet);

    if yesno&&~isempty(id)
        textItemsIDs=linkSet.getTextItemIds();
        yesno=any(strcmp(id,textItemsIDs));
    end

end

