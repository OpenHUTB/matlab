function removeUnusedObjects(obj)




    dm=obj.getDependentManager;
    if~isempty(dm)
        for dmIdx=1:numel(dm)
            manager=dm(dmIdx);
            manager.removeUnusedObjects;
        end
    end

    removeUnreferencedInfos(obj);

end


