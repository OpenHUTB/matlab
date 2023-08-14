function bopts=filbuildoptions()

    filtop=fullfile(matlabroot,'toolbox','shared','eda','fil');



    includeDirs={fullfile(filtop,'include')};


    bopts.rtw.includeDirs=includeDirs;
    bopts.eml.includeDirs=sprintf('%s ',includeDirs{:});


    arch=computer('arch');
    switch(arch)
    case{'glnxa64','glnx86'}
        libExt='.so';
        libLeafDir=['bin',filesep,arch];
        libDirs={fullfile(matlabroot,libLeafDir)};
        libNames={'libmwfilcommon'};
    case{'win32','win64'}
        libExt='.lib';
        libLeafDir=['lib',filesep,arch];
        libDirs={fullfile(filtop,libLeafDir)};
        libNames={'libmwfilcommon'};
    case{'maci64'}
        libExt='.dylib';
        libLeafDir=['bin',filesep,arch];
        libDirs={fullfile(matlabroot,libLeafDir)};
        libNames={'libmwfilcommon'};
    otherwise
        error(message('EDALink:FILSimulation:UnsupportedPlatform'));
    end

    libNames=cellfun(@(x)([x,libExt]),libNames,'UniformOutput',false);

    bopts.rtw.libDirs=libDirs;
    bopts.rtw.libNames=libNames;




    bopts.eml.libFullNames=fullfile(libDirs{1},libNames{1});

