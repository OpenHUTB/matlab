function runMATLABScriptInBase(path,command)




    currentDir=pwd;
    cd(path);

    try
        evalin('base',command);
        if strcmp(path,pwd)
            cd(currentDir)
        end
    catch me
        cd(currentDir)
        rethrow(me);
    end

end
