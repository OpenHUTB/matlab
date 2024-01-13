function fillFileInfo(self)

    cgDir=self.cgDir;

    try
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
    for ii=1:numel(srcFiles)
        [fpath,fname,fext]=fileparts(srcFiles{ii});
        if numel(fpath)>2&&fpath(1)=='.'&&fpath(2)==filesep
            fpath=[cgDir,fpath(2:end)];
        end
        validExtensions={'.c','.cpp','.cxx','.cc','.c++'};
        if strcmpi(fname,'ert_main')||~any(strcmpi(fext,validExtensions(:)))||...
            strcmpi(srcFiles{ii},fullfile(matlabroot,'rtw','c','src','common','rt_main.c'))
            badIdx=[badIdx,ii];%#ok<AGROW>
            continue
        end
    end
    srcFiles(badIdx)=[];
    self.fileInfo.source=srcFiles;
    incPaths=self.buildInfo.getFullFileList('include');
    for ii=1:numel(incPaths)
        incP=fileparts(incPaths{ii});
        if numel(incP)>2&&incP(1)=='.'&&incP(2)==filesep
            incP=[cgDir,incP(2:end)];
        end
        incPaths{ii}=incP;
    end
    self.fileInfo.include=RTW.unique(incPaths);
    compFlags=self.buildInfo.getDefines('','');
    for ii=1:numel(compFlags)
        compFlags{ii}=regexprep(compFlags{ii},'^-D','');
    end
    self.fileInfo.define=compFlags;


