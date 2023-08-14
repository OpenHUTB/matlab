function foundCvIds=findCvIdsInScope(this,scope,invert)





    scopeCvIds=[];
    scopeAncestorCvIds=[];
    for idx=1:numel(scope)
        cb=scope{idx};
        cvId=cvprivate('find_block_cv_id',this.rootID,cb);
        if~ischar(cvId)
            scopeCvIds=[scopeCvIds,cvId,cv('DecendentsOf',cvId)];%#ok<AGROW>
            scopeAncestorCvIds=[scopeAncestorCvIds,getAncestorsOf(cvId)];%#ok<AGROW>
        end
    end
    if invert
        topCvId=cv('get',this.rootID,'.topSlsf');
        allIds=[topCvId,cv('DecendentsOf',topCvId)];
        foundCvIds=setdiff(allIds,[scopeCvIds,scopeAncestorCvIds]);
    else
        foundCvIds=scopeCvIds;
    end
end

function ancestorCvIds=getAncestorsOf(cvId)
    ancestorCvIds=[];
    while(cvId~=0)
        parent=cv('get',cvId,'.tree.parent');
        if(parent~=0)
            ancestorCvIds=[ancestorCvIds,parent];%#ok<AGROW>
        end
        cvId=parent;
    end
end