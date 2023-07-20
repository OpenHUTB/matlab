function uhd_bin_path=setup()




    pathTo3P=matlab.internal.get3pInstallLocation('uhdbinary.instrset');
    if~exist(pathTo3P,"dir")
        msg=message("wt:rfnoc:host:UHDInstallNotFound");
        error(msg);
    end
    archstr=lower(computer('arch'));

    if contains(pathTo3P,matlabshared.supportpkg.getSupportPackageRoot)
        uhd_lib_path=fullfile(pathTo3P,archstr,"lib");
        uhd_bin_path=fullfile(pathTo3P,archstr,"bin");
    else
        uhd_lib_path=fullfile(pathTo3P,"lib");
        uhd_bin_path=fullfile(pathTo3P,"bin");
    end

    old_PATH=getenv("PATH");
    if~contains(old_PATH,uhd_bin_path)
        setenv("PATH",strcat(uhd_lib_path,pathsep,old_PATH));
        setenv("PATH",strcat(uhd_bin_path,pathsep,getenv("PATH")));
    end

    if strcmp(archstr,"win64"),return,end


    old_LD_LIBRARY_PATH=getenv("LD_LIBRARY_PATH");
    if~contains(old_LD_LIBRARY_PATH,uhd_lib_path)
        setenv("LD_LIBRARY_PATH",strcat(uhd_lib_path,pathsep,old_LD_LIBRARY_PATH));
    end

    origPath=pwd;
    cd(fullfile(uhd_lib_path));
    uhd.internal.Device;
    cd(origPath);

end


