function propagationDelay(obj)

    if isR2022aOrEarlier(obj.ver)
        allPropDelayBlocks=slexportprevious.utils.findBlockType(obj.modelName,'PropagationDelay');
        obj.replaceWithEmptySubsystem(allPropDelayBlocks);
    end

end