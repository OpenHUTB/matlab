function isInsideMask=dfs_inside_mask(allObjH,allObjPidx,allIsSf,isAnnotation)





    cnt=length(allObjH);
    allIsMasked=false(cnt,1);
    allIsSf(1)=true;
    allIsSfOrAnnotation=allIsSf|isAnnotation;
    allIsMasked(~allIsSfOrAnnotation)=strcmp(rmisl.cellGetParam(allObjH(~allIsSfOrAnnotation),'Mask'),'on');


    allIsMasked(allObjPidx(allIsSf(2:end)))=false;

    isInsideMask=true(cnt,1);
    isInsideMask=rmisync.dfs_propagate(allObjH,allObjPidx,allIsMasked,...
    @dfs_pre_inside_mask,[],isInsideMask);
    isInsideMask(1)=false;
end


function[values,ind,cont]=dfs_pre_inside_mask(itemIdx,~,~,allIsMasked,~)
    ind=itemIdx;
    if allIsMasked(itemIdx)
        values=false;
        cont=false;
    else
        values=false;
        cont=true;
    end
end
