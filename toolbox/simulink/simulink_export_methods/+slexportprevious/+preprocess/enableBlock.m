function enableBlock(obj)






    if isR2011aOrEarlier(obj.ver)
        blks=find_system(obj.modelName,'SearchDepth',1,'BlockType','EnablePort');
        if~isempty(blks)

            assert(length(blks)==1);
            obj.replaceWithEmptySubsystem(blks{1});
        end
    end
