function deleteLinks(linkUUIDList)








    dasLinkList=slreq.das.Link.empty();
    dataLinkListWithoutDas=slreq.data.Link.empty();
    linkUUIDList=unique(linkUUIDList);
    if slreq.app.MainManager.exists()
        mgr=slreq.app.MainManager.getInstance;


        mgr.notify('SleepUI');
        cleanup=onCleanup(@()mgr.notify('WakeUI'));
    end

    reqData=slreq.data.ReqData.getInstance();
    srcListStruct=struct('artifactUri',{},'domain',{},'id',{});

    for index=1:length(linkUUIDList)

        uuid=linkUUIDList{index};
        dataLink=reqData.findObject(uuid);

        if~isempty(dataLink)
            src=dataLink.source;
            allLinks=src.getLinks();
            origLinkCount=numel(allLinks);
            srcStruct=struct(...
            'artifactUri',src.artifactUri,...
            'domain',src.domain,...
            'id',src.id);
            if isa(src,'slreq.data.TextRange')
                srcStruct.id=slreq.utils.getLongIdFromShortId(src.getTextNodeId(),src.id);
            end
            srcListStruct(end+1)=srcStruct;%#ok<AGROW>
            dasLink=dataLink.getDasObject();
            if~isempty(dasLink)&&isvalid(dasLink)
                dasLinkList(end+1)=dasLink;%#ok<AGROW>
            else
                dataLinkListWithoutDas(end+1)=dataLink;%#ok<AGROW>
            end
        end
    end

    if~isempty(dasLinkList)
        arrayfun(@(x)x.remove(),dasLinkList);
    end

    if~isempty(dataLinkListWithoutDas)


        arrayfun(@(x)x.remove(),dataLinkListWithoutDas);
    end

    if slreq.app.MainManager.exists()

        mgr.update(false);



    end

    for index=1:length(srcListStruct)
        srcStruct=srcListStruct(index);
        adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(srcStruct.domain);
        adapter.refreshLinkOwner(srcStruct.artifactUri,srcStruct.id,...
        rmi.createEmptyReqs(origLinkCount),rmi.createEmptyReqs(origLinkCount-1));
    end

end
