function updateLinkedTimeAndVersion(this,mfLinkOrRef,mfReq,isChangeInfoSupported)%#ok<INUSL>









    if isempty(mfReq)

        mfReq=slreq.datamodel.RequirementItem.empty();
    end

    mfLinkOrRef.setLinkedTimeVersion(mfReq,isChangeInfoSupported);

    if isa(mfLinkOrRef,'slreq.datamodel.Link')
        linkSetDomain=mfLinkOrRef.linkSet.domain;



        sourceItem=mfLinkOrRef.source.tag;

        supportedDomains={'linktype_rmi_testmgr',...
        'linktype_rmi_matlab',...
'linktype_rmi_simulink'...
        };

        if any(strcmp(linkSetDomain,supportedDomains))
            sourceAdapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(linkSetDomain);

            [status,info]=sourceAdapter.getRevisionInfo(sourceItem);
            if status~=slreq.analysis.ChangeStatus.UnsupportedArtifact
                mfLinkOrRef.linkedTime=datetime(info.timestamp,'ConvertFrom','posixtime','TimeZone','Local');
                mfLinkOrRef.linkedVersion=info.revision;
            end
        end
    end
end
