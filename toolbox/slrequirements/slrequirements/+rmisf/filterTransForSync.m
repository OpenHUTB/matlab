function ids=filterTransForSync(ids,parentId,doRemove)


    if doRemove
        ids=filter_virtual_trans(ids);
    end
    ids=filter_inner_subwires(ids,parentId,doRemove);
end

function filteredIds=filter_virtual_trans(ids)
    simtrans=sf('find',ids,'transition.type','SIMPLE');
    supertrans=sf('find',ids,'transition.type','SUPER');
    filteredIds=[simtrans,supertrans]';
end

function ids=filter_inner_subwires(ids,parentId,doRemove)




    [transPar,subTrans]=sf('get',ids,'.parent','.firstSubWire');
    if doRemove
        ids(transPar~=parentId)=[];
        subTrans(transPar~=parentId)=[];
    end
    ids(subTrans>0)=subTrans(subTrans>0);
end
