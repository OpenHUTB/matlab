function status=createLink(srcDomain,srcArtifact,srcArtifactID,dstDomain,dstArtifact,dstArtifactID,linktype)

    linkExportData=slreq.report.rtmx.utils.createLinkFromMatrix(srcDomain,srcArtifact,srcArtifactID,dstDomain,dstArtifact,dstArtifactID,linktype);

    status=jsonencode(linkExportData);
end