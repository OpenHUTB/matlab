function dirName=desktopTempdir()











    persistent DESKTOPTEMPDIR


    if isempty(DESKTOPTEMPDIR)
        root=sbioroot;
        DESKTOPTEMPDIR=[root.Tempdir,'_desktop'];
    end

    dirName=DESKTOPTEMPDIR;


    if~exist(dirName,'dir')
        mkdir(dirName);
    end
end
