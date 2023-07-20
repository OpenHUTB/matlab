function links=getIncomingLinks(this,requirement)






    slreq.utils.assertValid(requirement);

    if~isa(requirement,'slreq.data.Requirement')
        error('Invalid argument: expected slreq.data.Requirement');
    end

    links=[];
    req=this.getModelObj(requirement);
    if~isempty(req)
        refs=req.references.toArray();
        links=slreq.data.Link.empty();
        for i=1:numel(refs)
            ref=refs(i);
            refLink=ref.link;
            if isempty(refLink)

                srcData=[ref.artifactUri,':',ref.artifactId];
                rmiut.warnNoBacktrace('Slvnv:slreq:StaleLinkAt',srcData);
            else
                links(end+1)=this.wrap(refLink);%#ok<AGROW>

                this.wrap(refLink.source.artifact);
            end
        end
    end
end
