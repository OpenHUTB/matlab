function handleProjectException(exception)





    if isa(exception,'matlab.exception.JavaException')&&...
        isa(exception.ExceptionObject,...
        'com.mathworks.toolbox.slproject.Exceptions.CoreProjectException')

        error(char(exception.ExceptionObject.getMessage()));
    else
        rethrow(exception);
    end
end

