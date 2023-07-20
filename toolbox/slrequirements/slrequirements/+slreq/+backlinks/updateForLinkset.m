function[numChecked,numAdded,numRemoved]=updateForLinkset(dataLinkSet)






    numChecked=0;
    numAdded=0;
    numRemoved=0;

    referencedDocuments=containers.Map('KeyType','char','ValueType','char');

    modifiedDocuments=containers.Map('KeyType','char','ValueType','logical');

    linksData=containers.Map('KeyType','char','ValueType','any');
    linkedItems=dataLinkSet.getLinkedItems();






    itemsWithMissingLinks=containers.Map('KeyType','double','ValueType','any');


    for i=1:numel(linkedItems)
        oneItem=linkedItems(i);
        mwId=oneItem.id;
        linksData(mwId)=cell(0,2);
        myLinks=oneItem.getLinks();
        missingLinks=false(size(myLinks));
        for j=1:numel(myLinks)
            dataLink=myLinks(j);
            try
                if dataLink.isBacklinkSupported()
                    [hasBacklink,targetInfo]=dataLink.checkBacklink();
                    numChecked=numChecked+1;
                    referencedDocuments(targetInfo.doc)=targetInfo.domain;
                    if~hasBacklink
                        missingLinks(j)=true;
                        modifiedDocuments(targetInfo.doc)=true;



                    elseif~isKey(modifiedDocuments,targetInfo.doc)




                        modifiedDocuments(targetInfo.doc)=false;
                    end


                    linksData(mwId)=[linksData(mwId);{targetInfo.doc,targetInfo.id}];
                end
            catch ex
                rmiut.warnNoBacktrace('Slvnv:slreq_backlinks:FailedToCheck',dataLink.destUri,ex.message);
                continue;
            end
        end
        if any(missingLinks)
            itemsWithMissingLinks(i)=find(missingLinks);
        end
    end


    selectedIdx=keys(itemsWithMissingLinks);
    for i=1:length(selectedIdx)
        oneIdx=selectedIdx{i};
        oneItem=linkedItems(oneIdx);
        myLinks=oneItem.getLinks();
        missingLinks=itemsWithMissingLinks(oneIdx);
        for j=missingLinks
            dataLink=myLinks(j);
            isAdded=dataLink.insertBacklink();
            numAdded=numAdded+isAdded;
        end
    end


    allReferencedDocuments=keys(referencedDocuments);
    for i=1:length(allReferencedDocuments)
        oneDoc=allReferencedDocuments{i};
        numRemoved=numRemoved+slreq.backlinks.removeUnmatched(...
        referencedDocuments(oneDoc),oneDoc,...
        dataLinkSet.artifact,linksData,modifiedDocuments(oneDoc));
    end

end
