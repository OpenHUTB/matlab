function links=getLinksFromUUIDs(linkUuids)
    links=slreq.Link.empty;
    reqData=slreq.data.ReqData.getInstance;
    for index=1:numel(linkUuids)
        linkUuid=linkUuids{index};
        dataLink=reqData.findObject(linkUuid);
        links(end+1)=slreq.utils.dataToApiObject(dataLink);%#ok<AGROW>
    end
end