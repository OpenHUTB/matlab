function reciprocalBlock(obj)




    if isR2014aOrEarlier(obj.ver)
        RecipBlks=obj.findBlocksOfType('Reciprocal');
        obj.replaceWithEmptySubsystem(RecipBlks);
    end
end
