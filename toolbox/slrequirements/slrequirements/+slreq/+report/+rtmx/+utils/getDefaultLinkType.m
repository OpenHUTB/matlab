function out=getDefaultLinkType(srcDomain,srcArtifact,srcArtifactID)


    persistent matrixDomain2LinkTypeDomain

    if isempty(matrixDomain2LinkTypeDomain)
        matrixArtifactDomains={'simulink','sltest','slreq','sldd'...
        ,'matlabcode'};
        linkTypeDomains={'linktype_rmi_simulink',...
        'linktype_rmi_testmgr','linktype_rmi_slreq',...
        'linktype_rmi_data','linktype_rmi_matlab'};
        matrixDomain2LinkTypeDomain=containers.Map(matrixArtifactDomains,linkTypeDomains);
    end

    srcDomainType=matrixDomain2LinkTypeDomain(srcDomain);
    try
        adapter=slreq.adapters.AdapterManager.getInstance().getAdapterByDomain(srcDomainType);
        linktype=adapter.getDefaultLinkType(srcArtifact,srcArtifactID);
        out=char(linktype);
    catch
        out='Relate';
    end
end
