function CCallerInputOutput(obj)



    if isR2018bOrEarlier(obj.ver)
        ccBlocks=obj.findBlocksOfType('CCaller');
        for i=1:numel(ccBlocks)
            blockhasInplace=slcc('blockHasInplace',get_param(ccBlocks{i},'Handle'));


            if blockhasInplace
                obj.replaceWithEmptySubsystem(ccBlocks{i});
            end
        end
    end