

function proceedWhenBDisLoaded(bdName)

    if(~bdIsLoaded(bdName))
        load_system(bdName);
    end

    to=tic;
    tf=toc(to);

    while(~bdIsLoaded(bdName)&&tf<30)
        tf=toc(to);
    end

    if(~bdIsLoaded(bdName))
        error(message('Simulink:HiliteTool:ModelLoadFailure'));
    end

end