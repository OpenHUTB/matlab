function tf=removeReqSetFromLinkSet(reqSet,linkSet)





    tf=true;


    linksToBeDeleted=slreq.data.Link.empty();
    linkedItems=linkSet.getLinkedItems();
    for n=1:numel(linkedItems)
        thisLinks=linkedItems(n).getLinks();
        for m=1:numel(thisLinks)
            thisLink=thisLinks(m);
            linkedReq=thisLink.dest;
            if isempty(linkedReq)
                continue;
            end
            linkedReqSet=linkedReq.getReqSet();
            if linkedReqSet==reqSet
                linksToBeDeleted(end+1)=thisLink;%#ok<AGROW>
            end
        end
    end


    numDeletingLinks=numel(linksToBeDeleted);
    if numDeletingLinks~=0
        [~,modelName]=fileparts(linkSet.artifact);
        qestMsg=getString(message('Slvnv:slreq:RemoveReqSetQuestion',[reqSet.name,'.slreqx'],modelName,numDeletingLinks,modelName,[reqSet.name,'.slreqx']));
        delOrCancel=questdlg(qestMsg,getString(message('Slvnv:slreq:UnregisterRequirementSet')),getString(message('Slvnv:slreq:Delete'))...
        ,getString(message('Slvnv:slreq:Cancel')),getString(message('Slvnv:slreq:Cancel')));
        if isempty(delOrCancel)||strcmp(delOrCancel,getString(message('Slvnv:slreq:Cancel')))
            tf=false;
            return;
        end

        for n=1:numDeletingLinks

            link=linksToBeDeleted(n);
            dasLink=link.getDasObject();
            dasLink.destroyConnector(true);
            dasLink.destroyConnector(false);

            link.remove;
        end
    end


    reqSetPath=slreq.uri.getPreferredPath(reqSet.filepath,linkSet.filepath);
    linkSet.removeRegisteredRequirementSet(reqSetPath);
end
