function tf=mlfbHasLinkData(mlfbSid)

    tf=false;
    if~slreq.data.ReqData.exists()
        return;
    end

    [mdlName,textNodeId]=strtok(mlfbSid,':');
    linkSet=slreq.data.ReqData.getInstance.getLinkSet(mdlName,'linktype_rmi_simulink');
    if isempty(linkSet)
        return;
    end

    tf=~isempty(linkSet.getTextItem(textNodeId));

end