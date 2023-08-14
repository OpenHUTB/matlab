function safeRunCommandWithErrorArgs(command,errorArgs,causeArgs)



    [failed,dosOutput]=safely_execute_dos_command(pwd,command);

    networkError='Local NTFS volumes are required to complete the operation.';
    if ispc&&length(dosOutput)>=length(networkError)&&...
        isequal(networkError,dosOutput(1:length(networkError)))


        failed=true;
    end

    if(failed)
        exception=MException(message(errorArgs{:}));

        dosOutput=strrep(dosOutput,'\','\\');
        cause=MException(message(causeArgs{:},dosOutput));
        makeException=addCause(exception,cause);
        throw(makeException);
    end
end