function names=checkSingleDimIndexNames(names,expSize,dimIdx)









    if~(iscellstr(names)||isstring(names))
        throwAsCaller(MException(message('shared_adlib:validateIndexNames:MustBeStringOrEmpty')));
    end


    names=cellstr(names(:)');


    if any(strcmp(names,':'))
        throwAsCaller(MException(message('shared_adlib:validateIndexNames:CannotUseColonAsIndexName')));
    end



    if numel(names)~=expSize
        throwAsCaller(MException(message('shared_adlib:validateIndexNames:IncorrectNumberOfStringsInADimension')));
    end

    if optim.internal.problemdef.numUniqueNames(names)~=expSize
        throwAsCaller(MException(message('shared_adlib:validateIndexNames:DuplicateIndexNamesInSameDim',dimIdx)));
    end

    if any(cellfun('isempty',names))
        throwAsCaller(MException(message('shared_adlib:validateIndexNames:MustBeNonEmptyStringsInADimension')));
    end

