function modified=resolveLinkTypesForLinkSet(this,mfLinkSet)




    if reqmgt('rmiFeature','CppReqData')
        modified=this.repository.resolveLinkTypes(mfLinkSet);
        return;
    end

    modified=false;

    mfLinks=mfLinkSet.links.toArray;

    cached_stereotype={};
    function resolveType(mfLink)
        typeName=mfLink.typeName;
        if any(strcmp(typeName,cached_stereotype))

            return;
        end
        [prfName,sType,~]=slreq.internal.ProfileTypeBase.getProfileStereotype(typeName);
        if~isempty(prfName)&&~isempty(sType)

            cached_stereotype{end+1}=typeName;
            return;
        end
        this.resolveLinkType(mfLink)
    end


    if mfLinkSet.linktypes.Size==0

        for n=length(mfLinks):-1:1
            mfLink=mfLinks(n);
            if isempty(mfLink.typeName)
                slreq.internal.removeLinkOfUnknownType(mfLinkSet,mfLink);
                modified=true;
            else
                resolveType(mfLink);
            end
        end
    else

        for n=length(mfLinks):-1:1
            mfLink=mfLinks(n);
            if isempty(mfLink.typeName)

                mfLink.typeName=mfLink.linktype.typeName;
            else

            end
            if isempty(mfLink.typeName)
                slreq.internal.removeLinkOfUnknownType(mfLinkSet,mfLink);
                modified=true;
            else

                this.resolveLinkType(mfLink);

            end
        end
    end
end
