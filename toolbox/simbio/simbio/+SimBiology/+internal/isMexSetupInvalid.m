function isInvalid=isMexSetupInvalid()















    try
        info=emlcprivate('compilerman',false,true);
    catch exception
        isInvalid=true;
        if~any(strcmp(exception.identifier,...
            {'Coder:reportGen:mexCompilerNotSupported','Coder:reportGen:mexOptsFileNotFound',...
            'MATLAB:CompilerConfiguration:NoSelectedOptionsFile'}))
            warning(message('SimBiology:CodeGeneration:SetupError'));
        end
        return
    end

    if isempty(info)


        isInvalid=true;
        warning(message('SimBiology:CodeGeneration:SetupError'));
    else
        isInvalid=false;
    end
