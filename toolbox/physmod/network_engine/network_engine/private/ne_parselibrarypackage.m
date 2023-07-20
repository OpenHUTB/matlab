function libs=ne_parselibrarypackage(pkg)













    [pkgPath,pkgName]=fileparts(pkg);
    if isempty(pkgPath)
        pkgPath=pwd;
    end

    cwd=cd(fullfile(pkgPath,pkgName));


    sentinel=ne_masmodelssentinelname();
    treatMAsModels=exist(fullfile(pwd,sentinel),'file');


    fileExt={'.m','.ssc','.sscp','.sscx'};
    c=onCleanup(@()cd(cwd));
    files=ne_packagefiles('.',fileExt);


    files=ne_uniquifysourcefiles(files);

    c=[];%#ok<NASGU>

    files=sort(files);

    allowedMFiles={'lib','sl_postprocess'};

    idx2=1;
    libHelpers={};
    for idx=1:numel(files)

        [fileDir,fileBase,fileExt]=fileparts(files{idx});%#ok<ASGLU>



        if~treatMAsModels&&strcmp(fileExt,'.m')&&~any(strcmp(fileBase,allowedMFiles))
            continue;
        end



        pkgFunction=ne_filetopackagefunction(files{idx});


        [pkgName,subPkgPath]=strtok(pkgFunction,'.');%#ok<ASGLU>
        subPkgPath=subPkgPath(2:end);
        if strcmp(fileExt,'.sscx')
            pkgFunction='';
        end
        libHelpers{idx2}=NetworkEngine.LibraryHelper(...
        pm_fullpath(files{idx}),...
        pkgFunction,...
        subPkgPath,...
        simscape.isSSCFunction(pkgFunction));
        idx2=idx2+1;
    end

    libs=libHelpers;
    cd(cwd);
end


