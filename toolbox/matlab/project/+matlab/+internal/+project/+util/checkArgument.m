function checkArgument(argumentVariable,expectedType,argumentName)



    try
        Simulink.ModelManagement.Project.checkArgument(argumentVariable,expectedType,argumentName);
    catch exception
        import matlab.internal.project.util.exceptions.Prefs;
        if(Prefs.ShortenStacks)
            exception.throwAsCaller();
        else
            exception.rethrow();
        end
    end

end