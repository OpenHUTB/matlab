function connectionLabel(obj)




    if isReleaseOrEarlier(obj.ver,'R2019a')
        allBlksOfAType=slexportprevious.utils.findBlockType(obj.modelName,'ConnectionLabel');
        obj.replaceWithEmptySubsystem(allBlksOfAType);
    end

end
