function navigateLinkFrom(domain,srcArtifact,srcId,linkIdx)














    switch domain
    case 'linktype_rmi_matlab'
        rmiml.navigateToReq(linkIdx,srcArtifact,srcId);
    otherwise

        srcStruct=struct('domain',domain,'artifact',srcArtifact,'id',srcId);
        outLinks=slreq.outLinks(srcStruct);
        if numel(outLinks)<linkIdx
            error('%s in %s does not have link #%d',srcId,srcArtifact,linkIdx);
        end
        destination=outLinks(linkIdx).destination();
        slreq.show(destination);
    end
end
