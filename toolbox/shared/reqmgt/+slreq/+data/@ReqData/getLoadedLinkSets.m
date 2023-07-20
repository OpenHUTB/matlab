function linkSetObjs=getLoadedLinkSets(this)






    linkSetObjs=slreq.data.LinkSet.empty;

    if isempty(this.repository)
        return;
    end

    linkSets=this.repository.linkSets.toArray();
    for i=1:length(linkSets)
        linkSetObjs(i)=this.wrap(linkSets(i));
    end
end
