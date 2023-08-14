function checkArgument(argumentVariable,expectedType,argumentName)














    if isa(argumentVariable,expectedType)
        return
    end

    try
        error(message('MATLAB:project:api:WrongArgumentType',...
        argumentName,...
        expectedType,...
        class(argumentVariable)));
    catch exception
        import matlab.internal.project.util.exceptions.Prefs;
        if(Prefs.ShortenStacks)
            exception.throwAsCaller();
        else
            exception.rethrow();
        end
    end

end
