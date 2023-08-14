function[variants,topRootId]=getRootVariants(rootId)





    try
        while(rootId~=0)&&...
            (cv('get',rootId,'.isa')==cv('get','default','root.isa'))
            topRootId=rootId;
            rootId=cv('get',rootId,'.treeNode.parent');
        end
        variants=cv('get',topRootId,'.variants');
    catch MEx
        rethrow(MEx);
    end
end