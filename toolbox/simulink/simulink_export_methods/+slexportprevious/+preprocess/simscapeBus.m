function simscapeBus(obj)




    if isReleaseOrEarlier(obj.ver,'R2018a')

        allBlksOfAType=slexportprevious.utils.findBlockType(obj.modelName,'SimscapeBus');
        obj.replaceWithEmptySubsystem(allBlksOfAType);

    end

end
