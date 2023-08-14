function removeServer(obj,treeId)




    if obj.hasServer(treeId)
        server=obj.getServer(treeId);


        remove(obj.ServerMap,treeId);


        delete(server);
    end
end
