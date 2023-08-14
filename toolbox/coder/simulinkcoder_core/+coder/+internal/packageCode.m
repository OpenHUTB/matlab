function packageCode(buildFolder,zipName)









    if nargin<2
        zipName='';
    end

    if zipName~=""
        coder.internal.verifyPackageName(zipName);
    end


    cwd=cd(buildFolder);
    cleanup=onCleanup(@()cd(cwd));


    packNGo(pwd,...
    'IncludeReport',true,...
    'packType','hierarchical',...
    'fileName',zipName,...
    'nestedZipFiles',false);
