function addToolchainOptionsToBuildinfo(modelName,buildInfo,stubGenParentFolder)







    if(nargin==2)
        stubGenParentFolder=RTW.getBuildDir(modelName).BuildDirectory;
    end

    toolchain=get_param(modelName,'Toolchain');

    if~strcmp(toolchain,'AUTOSAR Adaptive Linux Executable')&&...
        ~strcmp(toolchain,'AUTOSAR Adaptive | CMake')
        return;
    end

    if strcmp(toolchain,'AUTOSAR Adaptive Linux Executable')




        if isempty(which('linux.RuntimeManager.open'))

            error(message('MATLAB:hwstubs:general:spkgNotInstalled',...
            'Embedded Coder Support Package For Linux Applications',...
            'ECLINUX'));
        end

        autosarSchema=get_param(modelName,'AutosarSchemaVersion');
        if strcmp(autosarSchema,'R18-10')
            araVer='18_10';
        elseif strcmp(autosarSchema,'R19-03')
            araVer='19_03';
        elseif strcmp(autosarSchema,'R19-11')
            araVer='19_11';
        elseif strcmp(autosarSchema,'R20-11')
            araVer='20_11';
        else
            araVer='19_11';
        end

        arch='glnxa64';

        mwAraRoot=['$(SPKG_ROOT)','/toolbox/coder/ara/mw_ara/headers/',arch];

        mwAraHeaderPath={...
        [mwAraRoot,'/',araVer],...
        [mwAraRoot,'/ud_ipc'],...
        [mwAraRoot,'/dds_util'],...
        [mwAraRoot,'/com_factory'],...
        [mwAraRoot,'/log_utils'],...
        [mwAraRoot,'/manifest_utils'],...
        [matlabroot,'/bin/',arch,'/fastrtps/include'],...
        ['$(SPKG_ROOT)','/bin/',arch,'/dlt-daemon/include'],...
        };

        buildInfo.addIncludePaths(mwAraHeaderPath);


        buildInfo.addIncludePaths([stubGenParentFolder,'/stub/aragen']);


        mwAraLibPath={...
        fullfile('$(SPKG_ROOT)','toolbox','coder','ara','mw_ara','libraries',arch),...
        fullfile(matlabroot,'bin',arch),...
        };

        if ispc
            mwAraLibsWithVer={['libmwara_com_',araVer,'.so'];['libmwara_exec_',araVer,'.so'];['libmwara_log_',araVer,'.so'];['libmwara_per_',araVer,'.so']};


            buildInfo.addLinkObjects(mwAraLibsWithVer,mwAraLibPath{1},100,true,true);
        else


            spkgRoot=getLinuxSpkgRoot();
            mwAraLibsRaw=dir(fullfile(spkgRoot,'toolbox','coder','ara','mw_ara','libraries',arch));


            verStartPos=arrayfun(@(x)regexp(x.name,[araVer,'\.(so|dylib|lib)$'],...
            'ONCE'),mwAraLibsRaw,'UniformOutput',false);


            araLibsWithVer=cellfun(@(x)~isempty(x),verStartPos);
            mwAraLibsWithVer=arrayfun(@(x)x.name,mwAraLibsRaw(araLibsWithVer),...
            'UniformOutput',false);


            buildInfo.addLinkObjects(mwAraLibsWithVer,mwAraLibPath{1},100,true,true);
        end


        mwAraUtilityLibs={'libmwara_manifest_utils.so'};
        buildInfo.addLinkObjects(mwAraUtilityLibs,mwAraLibPath{1},100,true,true);








        dependeciesOfAra={'libmwboost_thread.so.1.75.0';'libmwboost_chrono.so.1.75.0';...
        'libmwboost_timer.so.1.75.0';'libmwboost_filesystem.so.1.75.0';...
        'libsqlite3.so.3'};
        buildInfo.addLinkObjects(dependeciesOfAra,mwAraLibPath{2},100,true,true);





        mw3pLibs={'libfastcdr.so','libfastcdr.so.1','libfastrtps.so',...
        'libfastrtps.so.1','libdlt.so','libdlt.so.2'};
        mw3pLibPath={...
        fullfile(matlabroot,'bin',arch,'fastrtps','lib'),...
        fullfile(matlabroot,'bin',arch,'fastrtps','lib'),...
        fullfile(matlabroot,'bin',arch,'fastrtps','lib'),...
        fullfile(matlabroot,'bin',arch,'fastrtps','lib'),...
        fullfile('$(SPKG_ROOT)','bin',arch,'dlt-daemon','lib'),...
        fullfile('$(SPKG_ROOT)','bin',arch,'dlt-daemon','lib'),...
        };


        buildInfo.addLinkObjects(mw3pLibs,mw3pLibPath,100,true,true);


        buildInfo.addSysLibPaths(mwAraLibPath{1});
        buildInfo.addSysLibPaths(mw3pLibPath{1});
        buildInfo.addSysLibPaths(mw3pLibPath{5});


        sysLibs={'dl','rt'};


        buildInfo.addSysLibs(sysLibs);


        addMatlabSysLibsToBuildinfo(buildInfo,arch);
    end




    buildInfo.addSysLibs('Threads::Threads');


    langStandard=get_param(modelName,'TargetLangStandard');
    if isequal(langStandard,'C++11 (ISO)')
        buildInfo.addCompileFlags('-std=c++11');
    elseif isequal(langStandard,'C++03 (ISO)')
        buildInfo.addCompileFlags('-std=c++0x');
    end

    buildConfig=get_param(modelName,'BuildConfiguration');
    if strcmp(buildConfig,'Specify')


        tcSpecify=get_param(modelName,'CustomToolchainOptions');


        buildTypeIndex=find(strcmp(tcSpecify,'Build Type'))+1;
        buildTypeOrig=strip(tcSpecify{buildTypeIndex});
        if~isempty(buildTypeOrig)
            if~any(strcmpi(buildTypeOrig,{'debug','release','relwithdebinfo','minsizerel'}))
                DAStudio.error('MATLAB:validatestring:unrecognizedStringChoice3',...
                '"Build Type" input','''Debug'', ''Release'', ''RelWithDebInfo'', ''MinSizeRel''',...
                buildTypeOrig);
            end
            addBuildTypeOptions(buildInfo,buildTypeOrig);
        else
            addBuildTypeOptions(buildInfo,'Release');
        end


        includePathIndex=find(strcmp(tcSpecify,'Include Directories'))+1;
        includePaths=strrep(strip(tcSpecify{includePathIndex}),'\','/');
        if~isempty(includePaths)
            includePathCells=split(includePaths);
            buildInfo.addIncludePaths(includePathCells);
        end


        definePathIndex=find(strcmp(tcSpecify,'Defines'))+1;
        defines=strip(tcSpecify{definePathIndex});
        if~isempty(defines)
            defineCells=split(defines);
            buildInfo.addDefines(defineCells);
        end


        libPathIndex=find(strcmp(tcSpecify,'Library Paths'))+1;
        libPaths=strrep(strip(tcSpecify{libPathIndex}),'\','/');
        if~isempty(libPaths)
            libPathsCell=split(libPaths);
            buildInfo.addSysLibPaths(libPathsCell);
        end


        libIndex=find(strcmp(tcSpecify,'Link Libraries'))+1;
        libs=strrep(strip(tcSpecify{libIndex}),'\','/');
        if~isempty(libs)
            libsCell=split(libs);
            for ii=1:numel(libsCell)
                curLib=libsCell{ii};

                [filePath,fileName,fileExt]=doubleColonSafeFileParts(curLib);
                fileNameWithExt=strcat(fileName,fileExt);
                if~isempty(filePath)



                    buildInfo.addLinkObjects(fileNameWithExt,filePath,100,true,true);
                else
                    buildInfo.addSysLibs(fileNameWithExt);
                end
            end
        end
    elseif strcmp(buildConfig,'Debug')
        addBuildTypeOptions(buildInfo,'Debug')
    else
        addBuildTypeOptions(buildInfo,'Release');
    end
end

function addMatlabSysLibsToBuildinfo(buildInfo,arch)
    sysLibsPaths=fullfile(matlabroot,'sys','os',arch);
    sysLibsFolderContent=dir(sysLibsPaths);


    sysLibsAll=arrayfun(@(x)regexp(x.name,'\.(so|dylib|lib)(\.|$)','ONCE'),sysLibsFolderContent,'UniformOutput',false);
    nonZeroIndex=cellfun(@(x)~isempty(x),sysLibsAll);


    sysLibsFolderContent=sysLibsFolderContent(nonZeroIndex);
    sysLibsAll=sysLibsAll(nonZeroIndex);




    libNamesWithoutExt=unique(arrayfun(@(x,y)extractBetween(x.name,1,y{1}),...
    sysLibsFolderContent,sysLibsAll));

    jj=1;
    qualSysFoldName=[matlabroot,'/sys/os/',arch,'/'];
    qualSysOrigFoldName=[matlabroot,'/sys/os/',arch,'/orig/'];






    for ii=1:numel(sysLibsFolderContent)
        curName=sysLibsFolderContent(ii).name;
        if contains(curName,libNamesWithoutExt{jj})


            if isfile(fullfile(sysLibsPaths,'orig',curName))
                libFolder=qualSysOrigFoldName;
            else
                libFolder=qualSysFoldName;
            end
            buildInfo.addLinkObjects(curName,libFolder,100,true,true);
            jj=jj+1;
        end
    end
end

function addBuildTypeOptions(buildInfo,buildType)










    buildType=lower(buildType);
    switch buildType
    case 'debug'
        options='-g';
    case 'release'
        options='-O3 -DNDEBUG';
    case 'relwithdebinfo'
        options='-O2 -g -DNDEBUG';
    case 'minsizerel'
        options='-Os -DNDEBUG';
    otherwise
        options='-O3 -DNDEBUG';
    end


    buildInfo.addCompileFlags(['$<$<NOT:$<BOOL:${CMAKE_BUILD_TYPE}>>:',options,'>']);
end

function[filePath,fileName,fileExt]=doubleColonSafeFileParts(libraryName)




    if ispc&&contains(libraryName,'::')
        filePath='';
        fileName=libraryName;
        fileExt='';
    else
        [filePath,fileName,fileExt]=fileparts(libraryName);
    end
end

function spkgRoot=getLinuxSpkgRoot()




    spkgRoot=matlabroot;

    installedSupportPackages=matlabshared.supportpkg.getInstalled;


    if~isempty(installedSupportPackages)&&...
        any(strcmpi("Embedded Coder Support Package for Linux Applications",...
        {installedSupportPackages.Name}))
        spkgRoot=matlabshared.supportpkg.getSupportPackageRoot;
    end
end





