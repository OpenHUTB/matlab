function CCallerGlobalIO(obj)



    if isR2020aOrEarlier(obj.ver)
        cCallerBlocks=obj.findBlocksOfType('CCaller');
        for i=1:numel(cCallerBlocks)
            blockHasGlobalIO=slcc('blockHasGlobalIO',get_param(cCallerBlocks{i},'Handle'));

            if blockHasGlobalIO
                obj.replaceWithEmptySubsystem(cCallerBlocks{i});
            end
        end
    end
