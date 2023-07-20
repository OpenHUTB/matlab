function rootObj=findParentRoot(obj)

    rootObj=obj;
    while~isempty(getParent(rootObj))
        rootObj=findParentRoot(getParent(rootObj));
    end
