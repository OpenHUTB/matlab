function ME=eraseMExceptionStack(origME)

    assert(strcmp(class(origME),'MException'));%#ok<STISA>
    ME=MException(origME.identifier,origME.message);
    for cause=origME.cause'
        ME=addCause(ME,cause{:});
    end
end