







































function origVersion=cmConfigureVersion(docType,docId,version,sourceArtifact)

    docType=slreq.cm.validateDomainName(docType);
    docId=convertStringsToChars(docId);
    version=convertStringsToChars(version);

    if nargin<4||isempty(sourceArtifact)
        origVersion=slreq.cm.ResourceVersionManager.setVersion(docType,docId,version);
    else
        sourceArtifact=convertStringsToChars(sourceArtifact);
        origVersion=slreq.cm.ResourceVersionManager.setVersionForSource(sourceArtifact,docType,docId,version);
    end

end

