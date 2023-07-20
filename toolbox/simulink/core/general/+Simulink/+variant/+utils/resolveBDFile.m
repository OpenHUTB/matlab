function[bdPath,bdUnderML]=resolveBDFile(bdName)






    if bdIsLoaded(bdName)





        bdPath=get_param(bdName,'FileName');
    else
        bdPath=sls_resolvename(bdName);
    end

    if isempty(bdPath)


        mid='Simulink:dialog:ModelNotFound';
        msg=message(mid,bdName);
        throw(MException(msg));
    end

    [~,bdUnderML]=Simulink.loadsave.resolveFile(bdPath);
end
