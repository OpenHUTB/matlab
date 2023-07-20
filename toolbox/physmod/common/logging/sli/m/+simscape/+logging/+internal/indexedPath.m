function res=indexedPath(treeNode)




    tp=treeNode.getPath();
    res=cell(1,numel(tp));
    for idx=1:numel(tp)
        val=tp(idx).getValue();
        if isempty(val)
            val='';
        elseif isnumeric(val)
            val=val(:)';
        end
        res{idx}=val;
    end

    if numel(res)>1&&isempty(res{1})
        res=res(2:end);
    end

end