function server=getServer(obj,treeId)




    if obj.hasServer(treeId)
        server=obj.ServerMap(treeId);
    else
        server=[];
    end
end
