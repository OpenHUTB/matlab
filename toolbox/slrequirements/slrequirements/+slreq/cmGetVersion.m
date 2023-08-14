


























function version=cmGetVersion(docType,docId,source)

    docType=slreq.cm.validateDomainName(docType);
    docId=convertStringsToChars(docId);

    if nargin<3
        source='';
    else
        source=convertStringsToChars(source);
    end

    version=slreq.cm.ResourceVersionManager.getVersion(docType,docId,source);

end

