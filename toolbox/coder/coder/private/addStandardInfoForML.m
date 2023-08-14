function addStandardInfoForML(buildInfo,isCpp,use_RT_MALLOC,varargin)





    standardGroup='Standard';
    legacyGroup='Legacy';

    srcFiles={};
    srcFilePaths={};
    srcFileGroups=legacyGroup;


    projectName=varargin{1};
    configInfo=varargin{2};


    incPaths={fullfile(matlabroot,'extern','include')};
    incGroups={standardGroup};



    ppdef={['MODEL=',projectName]};


    sysLibPaths={};
    sysLibs={};
    sysLibGroups={};

    sysLibs=[sysLibs,'m'];
    sysLibPaths=[sysLibPaths,{''}];
    sysLibGroups=[sysLibGroups,standardGroup];

    if(isCpp)
        sysLibs=[sysLibs,'stdc++'];
        sysLibPaths=[sysLibPaths,{''}];
        sysLibGroups=[sysLibGroups,standardGroup];
    end



    assert(use_RT_MALLOC==false);


    buildInfo.addDefines(ppdef,standardGroup);
    buildInfo.addIncludePaths(incPaths,incGroups);
    buildInfo.addSourceFiles(srcFiles,srcFilePaths,srcFileGroups);


    buildInfo.addSysLibs(sysLibs,sysLibPaths,sysLibGroups);


    buildInfo.manageTargetInfo('setTargetWordSizesForML',configInfo);


