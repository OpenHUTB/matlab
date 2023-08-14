function uhd_bin_path=setup(varargin)



    pathTo3P=matlab.internal.get3pInstallLocation('uhdbinary.instrset');
    if~exist(pathTo3P,"dir")
        msg=message("wt:rfnoc:host:UHDInstallNotFound");
        error(msg);
    end

    archstr=lower(computer("arch"));
    clibgen_root=fileparts(fileparts(fileparts(fileparts(fileparts(mfilename("fullpath"))))));
    clibgen_lib_path=fullfile(clibgen_root,"lib",archstr,"wt_uhd");
    clibgen_lib_name.win64="wt_uhdInterface.dll";
    clibgen_lib_name.glnxa64="wt_uhdInterface.so";
    clibgen_src=fullfile(clibgen_lib_path,clibgen_lib_name.(archstr));
    spkgRoot=matlabshared.supportpkg.getSupportPackageRoot;
    if contains(pathTo3P,spkgRoot)&&~isempty(spkgRoot)

        uhd_lib_path=fullfile(pathTo3P,archstr,"lib");
        uhd_bin_path=fullfile(pathTo3P,archstr,"bin");
        clibgen_dst_path=fullfile(uhd_lib_path);
    else
        uhd_lib_path=fullfile(pathTo3P,"lib");
        uhd_bin_path=fullfile(pathTo3P,"bin");
        clibgen_dst_path=fullfile(clibgen_lib_path);
    end
    if(~exist(fullfile(clibgen_dst_path,clibgen_lib_name.(archstr)),"file"))


        copyfile(clibgen_src,fullfile(clibgen_dst_path,clibgen_lib_name.(archstr)),"f");
    end

    old_path=path;
    if~contains(old_path,clibgen_dst_path)
        addpath(clibgen_dst_path);
        rehash;
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

end


