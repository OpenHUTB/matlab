function variantStates=getRootVariantStates(rootId)




    variantStates=[];

    variants=cvi.RootVariant.getRootVariants(rootId);
    if isempty(variants)
        return;
    end

    allPaths={};
    for idx=1:numel(variants)
        allPaths{idx}=cv('get',variants(idx),'.path');
    end
    allPaths=unique(allPaths);
    for idx=1:numel(allPaths)
        cp=allPaths{idx};
        vId=cv('find',variants,'.path',cp);
        if numel(vId)>1

            tvId=cv('find',vId,'.path',cp,'.state',1);
            if isempty(tvId)
                vId=vId(1);
            else
                vId=tvId;
            end
        end
        [variantPath,state]=cv('get',vId,'.variantPath','.state');
        ts.path=cp;
        ts.variantPath=variantPath;
        ts.state=state;
        if isempty(variantStates)
            variantStates=ts;
        else
            variantStates(end+1)=ts;
        end


    end

