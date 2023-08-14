function count=updateDestUriInIncomingLinks(this,group,updatedUri)






    count=0;

    domainLabel=group.domain;
    regType=rmi.linktype_mgr('resolveByRegName',domainLabel);
    isFile=isempty(regType)||regType.isFile;

    storedGroupUri=group.artifactUri;
    if isFile
        reqSetPath=group.requirementSet.filepath;
        currentArtifactUri=rmiut.absolute_path(updatedUri,fileparts(reqSetPath));
    else
        currentArtifactUri=updatedUri;
    end

    items=group.items.toArray();

    for i=1:numel(items)
        item=items(i);
        refs=item.references.toArray();
        for j=1:numel(refs)
            ref=refs(j);
            if~strcmp(ref.domain,domainLabel)
                continue;
            end
            link=ref.link;
            if isempty(link)
                continue;
            end
            linkSet=link.linkSet;
            refPath=fileparts(linkSet.filepath);
            storedUri=ref.artifactUri;
            if isFile
                preferredPath=slreq.uri.getPreferredPath(currentArtifactUri,refPath);
                if~strcmp(storedUri,preferredPath)
                    ref.artifactUri=preferredPath;
                    linkSet.dirty=true;
                    count=count+1;
                end
            else
                if~strcmp(storedUri,storedGroupUri)
                    ref.artifactUri=updatedUri;
                    linkSet.dirty=true;
                    count=count+1;
                end
            end
        end
    end

end
