function ex=argumentNotSupportedError(arg)

    stack=dbstack(1);

    unsupportedFile=stack(1).name;
    topfile=stack(end).name;

    if strcmp(unsupportedFile,topfile)
        ex=MException(message('MATLAB:connector:Platform:FunctionArgumentsNotSupported',unsupportedFile,arg));

    else
        ex=MException(message('MATLAB:connector:Platform:DependentFunctionArgumentsNotSupported',topfile,unsupportedFile,arg));
    end

