function label=getMwItemLabel(mwItem)










    if isstruct(mwItem)&&~isfield(mwItem,'artifactUri')

        mwItem.artifactUri=mwItem.artifact;
    end

    adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(mwItem.domain);
    if~isempty(adapter)
        if isa(mwItem,'slreq.data.Requirement')
            label=adapter.getLinkLabel(mwItem.getReqSet.name,mwItem.id);
        else
            label=adapter.getLinkLabel(mwItem.artifactUri,mwItem.id);
        end
    else

        shorterName=slreq.uri.getShortNameExt(mwItem.artifactUri);
        label=sprintf('%s:%s',shorterName,mwItem.id);
    end
end

