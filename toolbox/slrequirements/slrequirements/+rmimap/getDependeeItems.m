function[rootIDs,nodeIDs,linkCount]=getDependeeItems(rootID)




    rootIDs={};
    nodeIDs={};
    linkCount={};



    if isempty(fileparts(rootID))
        fromWhich=which(rootID);
        if~isempty(fromWhich)
            rootID=fromWhich;
        end
    end

    if rmimap.loadReq(rootID)
        allNodes=rmimap.getNodeIds(rootID);
        for i=1:length(allNodes)
            [rootIDs,nodeIDs,linkCount]=appendDependeeItems(rootID,allNodes{i},rootIDs,nodeIDs,linkCount);
        end
    end
end

function[docs,ids,counts]=appendDependeeItems(rootID,oneNode,docs,ids,counts)

    src.artifact=rootID;
    src.id=oneNode;
    src.domain='';
    srcLinks=slreq.utils.getLinks(src);

    if isempty(srcLinks)
        links=[];
    else
        links=slreq.utils.linkToStruct(srcLinks);
    end

    for i=1:length(links)
        [docs,ids,counts]=insertItem(links(i).doc,links(i).id,docs,ids,counts);
    end
end

function[docs,ids,counts]=insertItem(doc,id,docs,ids,counts)
    sameDoc=find(strcmp(docs,doc));
    if isempty(sameDoc)
        docs{end+1}=doc;
        ids{end+1}={id};
        counts{end+1}=1;
    else
        docIdx=sameDoc(1);
        sameID=find(strcmp(ids{docIdx},id));
        if isempty(sameID)
            ids{docIdx}{end+1}=id;
            counts{docIdx}(end+1)=1;
        else
            idIdx=sameID(1);
            myCounts=counts{docIdx};
            myCounts(idIdx)=myCounts(idIdx)+1;
            counts{docIdx}=myCounts;
        end
    end
end


