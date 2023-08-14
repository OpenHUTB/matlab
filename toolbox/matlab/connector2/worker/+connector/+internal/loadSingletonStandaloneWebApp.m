function out=loadSingletonStandaloneWebApp(fullFilePath,appClassName)

    persistent currentAppHandle
    if(~isempty(currentAppHandle)&&isvalid(currentAppHandle))



        if(~strcmp(class(currentAppHandle),appClassName))


            delete(currentAppHandle);


            currentAppHandle=runApp(fullFilePath);
        end
    else


        currentAppHandle=runApp(fullFilePath);
    end

    if nargout>0
        out=currentAppHandle;
    end
end


function out=runApp(fullFilePath)
    [fileDir,script,~]=fileparts(fullFilePath);
    oldPath=cd(fileDir);
    finishup=onCleanup(@()cd(oldPath));
    out=eval(script);
    cd(oldPath);
end