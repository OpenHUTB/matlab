function[url,label,errMsg]=getMwItemUrlAndLabel(mwLinkableItemInfo)






    if isstruct(mwLinkableItemInfo)
        mwItem=mwLinkableItemInfo;
    else
        [~,mwItem]=rmiut.resolveType(mwLinkableItemInfo);
    end
    if~isfield(mwItem,'artifactUri')


        mwItem.artifactUri=mwItem.artifact;
    end

    if rmipref('UnsecureHttpRequests')



        [url,label,errMsg]=getLegacyUrlAndLabel(mwItem);
    else



        [url,label,errMsg]=getSecureUrlAndLabel(mwItem);
    end
end

function[url,label,errMsg]=getSecureUrlAndLabel(mwItem)
    if~rmisl.isSidString(mwItem.artifactUri)

        mwItem.artifactUri=slreq.uri.getShortNameExt(mwItem.artifactUri);
    end
    [url,errMsg]=slreq.connector.getMwItemUrl(mwItem);
    label=slreq.connector.getMwItemLabel(mwItem);
end

function[url,label,errMsg]=getLegacyUrlAndLabel(mwItem)
    [navCmd,label]=getNavCmdAndLabelFromAdapter(mwItem);
    [url,errMsg]=rmiut.cmdToUrl(navCmd);
end

function[navCmd,label]=getNavCmdAndLabelFromAdapter(mwItem)
    adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(mwItem.domain);
    navCmd=adapter.getExternalNavCmd(mwItem.artifactUri,mwItem.id);
    label=adapter.getLinkLabel(mwItem.artifactUri,mwItem.id);
end


