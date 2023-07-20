function changed=resolveReferenceToMwRequirement(this,ref,srcPath,loadReferencedReqsets)






    if nargin<4

        loadReferencedReqsets=true;
    end

    changed=false;

    if~isempty(srcPath)


        this.unmaskSelfReference(ref,srcPath);
    end

    [referenceUri,refId]=slreq.internal.LinkUtil.getReqSetUri(ref.artifactUri,ref.artifactId);
    if slreq.internal.LinkUtil.isEmbededReqId(ref.artifactId)
        embeddedUri=referenceUri;
    else
        embeddedUri=[];
    end


    reqSet=this.locateRequirementSet(ref.artifactUri,srcPath,loadReferencedReqsets,embeddedUri);

    if isempty(reqSet)
        return;
    end

    if isempty(refId)








        req=getFirstRootItem(reqSet);

    elseif isempty(ref.reqSetUri)




        req=this.searchRequirementByCustomId(reqSet,ref.artifactId);

    else

        sep=find(ref.reqSetUri==':');
        if isempty(sep)
            req=getFirstRootItem(reqSet);
        else
            requirementId=ref.reqSetUri(sep(end)+1:end);
            if slreq.internal.LinkUtil.isEmbededReqId(requirementId)
                req=this.findRequirement(reqSet,refId);
            else
                req=this.findRequirement(reqSet,requirementId);
            end
        end
    end

    [~,reqSetName]=fileparts(referenceUri);
    if~isempty(req)
        if~isequal(ref.requirement,req)
            ref.requirement=req;
            ref.reqSetUri=sprintf('%s:%d',reqSetName,req.sid);
            changed=true;
        end
    else

    end
end

function firstItem=getFirstRootItem(reqSet)
    rootItems=reqSet.rootItems.toArray();
    if numel(rootItems)>0
        firstItem=rootItems(1);
    else
        firstItem=[];
    end
end
