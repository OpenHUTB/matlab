function updateLinksToReferenceRequirements(modelName,linkDomain,documentPathOrID)






    load_system(modelName);
    if isstring(linkDomain)
        linkDomain=linkDomain.char;
    end
    if isstring(documentPathOrID)
        assert(numel(documentPathOrID)==1,'Multiple document IDs found');
        documentPathOrID=documentPathOrID.char;
    end


    switch linkDomain
    case 'linktype_rmi_doors'
        idx=strfind(documentPathOrID,'/');
        reqSetName=['CapturedFrom',documentPathOrID];
        if~isempty(idx)
            if strcmpi(documentPathOrID(end),')')
                reqSetName=documentPathOrID(idx(end)+1:end-1);
            else
                reqSetName=documentPathOrID(idx(end)+1:end);
            end
        end
        [~,~,reqSet]=slreq.import(linkDomain,'DocID',documentPathOrID,'ReqSet',reqSetName);
    otherwise
        [~,~,reqSet]=slreq.import(documentPathOrID);
    end
    lnkSet=slreq.find('Type','LinkSet','Artifact',get_param(modelName,'FileName'));
    if~isempty(lnkSet)
        lnkSet.redirectLinksToImportedReqs(reqSet);
    end

end
