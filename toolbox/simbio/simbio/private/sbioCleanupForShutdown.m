function dirName=sbioCleanupForShutdown()









    if isdeployed


        return
    end


    root=sbioroot;
    dirName=root.Tempdir;
    desktopDirName=[root.Tempdir,'_desktop'];


    sbioreset;


    if isOnPath(dirName)
        rmpath(dirName);
    end


    if exist(dirName,'dir')
        status=rmdir(dirName,'s');

        if status==0
            warning(message('SimBiology:cleanup:UnableToDeleteTempdir',dirName));
        end
    end


    if exist(desktopDirName,'dir')
        status=rmdir(desktopDirName,'s');

        if status==0
            warning(message('SimBiology:cleanup:UnableToDeleteTempdir',desktopDirName));
        end
    end

end

function tf=isOnPath(dirName)

    ps=pathsep;
    p=[ps,matlabpath,ps];
    tf=contains(p,[ps,dirName,ps]);
end