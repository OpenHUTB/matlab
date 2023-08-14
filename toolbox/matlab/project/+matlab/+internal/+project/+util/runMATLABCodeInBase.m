function runMATLABCodeInBase(path,command,projectReference)






    toRun=@()iRunMATLABCode(command);

    if iIsDispatchable(command,path)
        toRun();
    else
        iRunCodeInPath(path,toRun);
    end
end

function dispatchable=iIsDispatchable(command,parent)

    try
        dispatchable=strcmp(fileparts(which(command)),parent);
    catch
        dispatchable=false;
    end

end

function iRunMATLABCode(command)

    try
        nargin(command);
    catch exception %#ok<NASGU>
        iHandleScript(command);
        return;
    end

    iHandleNoArgFunction(command);

end


function iRunCodeInPath(path,fcn)

    currentDir=pwd;
    cd(path);
    restore=onCleanup(@()iRestorePath(path,currentDir));

    fcn();

end

function iRestorePath(expectedWorkingDirectory,originalWorkingDirectory)

    if strcmp(expectedWorkingDirectory,pwd())
        cd(originalWorkingDirectory)
    end

end

function iHandleScript(command)
    evalin('base',command);
end

function iHandleNoArgFunction(command)
    feval(command)
end
