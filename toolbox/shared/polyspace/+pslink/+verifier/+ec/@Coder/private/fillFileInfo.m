function fillFileInfo(self,opt)






    cgDir=self.cgDir;


    try
        if~strcmp(self.buildInfo.Settings.LocalAnchorDir,self.sysDirInfo.CodeGenFolder)
            self.buildInfo.Settings.LocalAnchorDir=RTW.transformPaths(self.sysDirInfo.CodeGenFolder,'pathType','full');
        end
        if~strcmp(self.buildInfo.Settings.Matlabroot,matlabroot)
            self.buildInfo.Settings.Matlabroot=RTW.transformPaths(matlabroot,'pathType','full');
        end
    catch Me %#ok<NASGU>
    end

    try



        evalc('self.buildInfo.updateFilePathsAndExtensions()');
        evalc('self.buildInfo.updateFileSeparator(filesep)');


        evalc('self.buildInfo.findIncludeFiles()');

    catch Me %#ok<NASGU>
    end


    srcFiles=self.buildInfo.getFullFileList('source');
    srcFiles=RTW.unique(srcFiles);
    badIdx=[];
    validExtensions={'.c','.cpp','.cxx','.cc','.c++'};
    filesToIgnore={
    fullfile(matlabroot,'rtw','c','src','common','rt_main.c'),...
    fullfile(matlabroot,'rtw','c','src','common','rt_malloc_main.c'),...
    fullfile(matlabroot,'rtw','c','src','common','rt_main.cpp'),...
    fullfile(matlabroot,'rtw','c','src','common','rt_malloc_main.cpp'),...
    fullfile(matlabroot,'rtw','c','src','common','rt_cppclass_main.cpp'),...
    fullfile(matlabroot,'rtw','c','grt','classic_main.c'),...
    fullfile(matlabroot,'rtw','c','grt','classic_main.cpp')...
    };
    for ii=1:numel(srcFiles)
        [fpath,fname,fext]=fileparts(srcFiles{ii});
        if numel(fpath)>2&&fpath(1)=='.'&&fpath(2)==filesep
            fpath=[cgDir,fpath(2:end)];
        end

        if strcmpi(fname,'ert_main')||~any(strcmpi(fext,validExtensions(:)))||...
            any(strcmpi(filesToIgnore,srcFiles{ii}))
            badIdx=[badIdx,ii];%#ok<AGROW>
            continue
        end


        if~isempty(self.arInfo.fcn)
            if~isempty(regexp(fullfile(fpath,fname),'stub[\\/]Rte_.*','start'))
                badIdx=[badIdx,ii];%#ok<AGROW>
                continue
            end
        end

        if contains(fpath,[filesep,'slprj',filesep])
            if contains(fpath,'_sharedutils')&&~isempty(self.sharedCodeManager)

                for jj=1:numel(self.sharedCodeManager)
                    if strcmpi(fname,self.sharedCodeManager{jj}.Name)

                        if~any(strcmpi(self.sharedCodeManager{jj}.ModelNames,self.slSystemName))
                            badIdx=[badIdx,ii];%#ok<AGROW>
                        end
                        continue
                    end
                end
            end

            if self.isMdlRef&&strcmpi(fpath,cgDir)

                continue
            end

            if opt.includeMdlRefs==false&&~contains(fpath,'_sharedutils')
                badIdx=[badIdx,ii];%#ok<AGROW>
            end
        end
    end
    srcFiles(badIdx)=[];
    self.fileInfo.source=srcFiles;


    if~isempty(self.stubFile)&&pslinkprivate('pslinkattic','getBinMode','autosarFinalAssert')
        self.fileInfo.source=[self.fileInfo.source(:);self.stubFile(:)];
    end

    self.fileInfo.include=self.buildInfo.getIncludePaths(true);


    compFlags=self.buildInfo.getDefines('','');
    for ii=1:numel(compFlags)
        compFlags{ii}=regexprep(compFlags{ii},'^-D','');
    end
    self.fileInfo.define=compFlags;


