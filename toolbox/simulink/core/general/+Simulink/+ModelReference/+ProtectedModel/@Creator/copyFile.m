function srcFile=copyFile(~,fileName,category,rootDir)




    assert(strcmp(category,'matlab')||strcmp(category,'build')||strcmp(category,'other'));

    if strcmp(category,'matlab')

        mlroot=[matlabroot,filesep];
        mlrRegexpID=regexptranslate('escape',mlroot);


        relPath=regexprep(fileName,[mlrRegexpID,'(.*)'],'$1');


        srcFile=fullfile(rootDir,'matlab',relPath);
        [fpath,~,~]=fileparts(srcFile);
        if~exist(fpath,'dir')
            mkdir(fpath);
        end
        copyfile(fileName,srcFile,'f');

    elseif strcmp(category,'other')

        copyfile(fileName,rootDir);
        [~,fname,fext]=fileparts(fileName);
        srcFile=fullfile(rootDir,[fname,fext]);
    else
        srcFile=fileName;
    end
