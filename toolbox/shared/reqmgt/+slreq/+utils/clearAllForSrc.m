function clearAllForSrc(sid,includeChildIds)




    [modelName,id]=strtok(sid,':');
    try
        modelPath=get_param(modelName,'FileName');
    catch ME
        error('slreq.clearAllForSid(): unsupported use case. Expecting SID for the 1st input argument.');
    end

    data=slreq.data.ReqData.getInstance;
    linkSet=data.getLinkSet(modelPath);

    if~isempty(linkSet)
        if includeChildIds
            removeAllChildren(data,linkSet,id);
        end
        removeItemWithAllLinks(data,linkSet,id);
    end
end

function removeAllChildren(data,linkSet,id)
    children=linkSet.getLinkedItems({'id',[id,'\.\d+']});
    for i=numel(children):-1:1
        removeItemWithAllLinks(data,linkSet,children(i).id);
    end
end

function removeItemWithAllLinks(data,linkSet,id)
    linkedItem=linkSet.getLinkedItems({'id',id});
    if~isempty(linkedItem)
        links=linkedItem.getLinks;
        for i=numel(links):-1:1
            data.removeLink(links(i));
        end


        slreq.data.ReqData.getInstance.forceDirtyFlag(linkSet,true);
    end
end

