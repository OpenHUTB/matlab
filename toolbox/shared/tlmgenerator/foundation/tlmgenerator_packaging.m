function tlmgenerator_packaging



    try

        SystemInfo=tlmgenerator_getcodeinfo();
        cfg=tlmgenerator_getconfigset(SystemInfo.Name);



        load buildInfo;
        packNGoFileName=[SystemInfo.Name,'_pNg','.zip'];
        packNGoTmpDir=[SystemInfo.Name,'_pNg_tmp'];

        buildInfo.addDefines('-DRT');
        buildInfo.addDefines('-DUSE_RTMODEL');

        packNGo(buildInfo,{'packType','flat','fileName',fullfile([SystemInfo.Name,'_build'],packNGoFileName)});
        unzip(packNGoFileName,packNGoTmpDir);
        clear buildInfo;

        fileattrib(fullfile(packNGoTmpDir,'*'),'+w');

        copyfile('*.cpp',packNGoTmpDir,'f');
        [~,~,~]=copyfile('*.c',packNGoTmpDir,'f');
        copyfile('*.h',packNGoTmpDir,'f');
        [~,~,~]=copyfile('*.hpp',packNGoTmpDir,'f');


        tlmg_build=getappdata(0,'tlmg_build');

        for i=1:numel(tlmg_build.IncListNoPath)
            copyfile(fullfile(packNGoTmpDir,tlmg_build.IncListNoPath{i}),'.','f');
        end
        for i=1:numel(tlmg_build.SrcListNoPath)
            copyfile(fullfile(packNGoTmpDir,tlmg_build.SrcListNoPath{i}),'.','f');
        end






        savedWarn=warning('query','MATLAB:MKDIR:DirectoryExists');
        warning('off','MATLAB:MKDIR:DirectoryExists');

        coreDirs=strcat(['..',filesep],...
        {cfg.tlmgOutDir,cfg.tlmgCoreOutDir,...
        cfg.tlmgCoreSrcDir,cfg.tlmgCoreIncDir,...
        cfg.tlmgCoreUtilsDir,cfg.tlmgCoreLibDir,...
        cfg.tlmgCoreObjDir});
        cellfun(@(dname)(mkdir(dname)),coreDirs);

        copyfile('makefile*',coreDirs{2},'f');
        copyfile('*.vcproj',coreDirs{2},'f');
        copyfile('*.cpp',coreDirs{3},'f');
        [~,~,~]=copyfile('*.c',coreDirs{3},'f');
        copyfile('*.h',coreDirs{4},'f');
        [~,~,~]=copyfile('*.hpp',coreDirs{4},'f');

        copyfile(fullfile(packNGoTmpDir,'*.h'),coreDirs{5},'f');

        h_list=dir('*.h');
        for i=1:numel(h_list)
            delete(fullfile(coreDirs{5},h_list(i).name));
        end

        rmdir(packNGoTmpDir,'s');


        compDirs=strcat(['..',filesep],...
        {cfg.tlmgCompOutDir,cfg.tlmgCompSrcDir,...
        cfg.tlmgCompIncDir,cfg.tlmgCompLibDir,...
        cfg.tlmgCompObjDir});
        cellfun(@(dname)(mkdir(dname)),compDirs);

        copyfile(fullfile('tlm','makefile*'),compDirs{1},'f');
        copyfile(fullfile('tlm','*.vcproj'),compDirs{1},'f');
        copyfile(fullfile('tlm','*.xml'),compDirs{1},'f');
        copyfile(fullfile('tlm','*.cpp'),compDirs{2},'f');
        copyfile(fullfile('tlm','*.h'),compDirs{3},'f');


        if(strcmp(cfg.tlmgGenerateTestbenchOnOff,'on'))

            tbDirs=strcat(['..',filesep],...
            {cfg.tlmgTbOutDir,cfg.tlmgTbSrcDir,...
            cfg.tlmgTbIncDir,cfg.tlmgTbUtilsDir,...
            cfg.tlmgTbVecDir,cfg.tlmgTbObjDir});
            cellfun(@(dname)(mkdir(dname)),tbDirs);

            copyfile(fullfile('tlm_tb','makefile*'),tbDirs{1},'f');
            copyfile(fullfile('tlm_tb','*.vcproj'),tbDirs{1},'f');
            copyfile(fullfile('tlm_tb','*.cpp'),tbDirs{2},'f');
            copyfile(fullfile('tlm_tb','*.h'),tbDirs{3},'f');
            copyfile('*.mat',tbDirs{4},'f');

        end

        warning(savedWarn);

    catch ME
        l_me=MException('TLMGenerator:build','TLMG packaging: %s',ME.message);
        throw(l_me);
    end


end