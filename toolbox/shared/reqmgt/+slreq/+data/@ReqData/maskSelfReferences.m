








function maskSelfReferences(~,mfLinkSet)










    [~,artifactUriName,artifactUriExt]=fileparts(mfLinkSet.artifactUri);
    artifactUriNameExt=[artifactUriName,artifactUriExt];
    possibleSelfRefCases={artifactUriName,artifactUriNameExt,mfLinkSet.artifactUri};

    items=mfLinkSet.items.toArray;

    for i=1:length(items)
        links=items(i).outgoingLinks.toArray;
        for j=1:length(links)
            link=links(j);
            ref=link.dest;
            if~strcmp(ref.domain,mfLinkSet.domain)
                continue;
            end

            if any(strcmp(ref.artifactUri,possibleSelfRefCases))
                ref.artifactUri='_SELF';

                link.description=regexprep(link.description,artifactUriName,'_SELF');
            end









            ref.reqSetUri=strrep(ref.reqSetUri,artifactUriName,'_SELF');
        end
    end

end
