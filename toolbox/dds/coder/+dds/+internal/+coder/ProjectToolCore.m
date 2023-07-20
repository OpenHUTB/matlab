classdef ProjectToolCore<coder.make.ProjectTool







    properties
ProjectName
Builder
    end

    methods(Abstract)
        getDDSProjectInfoFile();
        getDDSProjectBuilder();
    end

    methods
        function h=ProjectToolCore(projectName)
            h@coder.make.ProjectTool(projectName);
            h.ProjectName=projectName;
        end
    end

    methods(Hidden)
        function ret=getProjectData(obj)
            infoFile=obj.getDDSProjectInfoFile;
            if isfile(infoFile)
                info=load(infoFile);
                ret=info.rosProjectInfo;
            else
                ret='';
            end
        end


        function[res,installDir]=runBuildCommand(~,context)
            if isfield(context,'ProjectData')&&...
                isfield(context.ProjectData,'BuildArguments')&&...
                ~isempty(context.ProjectData.BuildArguments)
                buildArgs=context.ProjectData.BuildArguments;
            else
                buildArgs='';
            end
            [res,installDir]=context.projectBuilder.buildPackage(...
            context.pkgsToBuild,buildArgs);
        end

        function name=getValidApplicationName(~,modelName)



            name=modelName;
        end

        function[sharedSrcFiles,sharedIncFiles]=getSharedUtilsSources(~,buildInfo)


            sharedutilsdir=dds.internal.coder.Util.sharedUtilsDir(buildInfo,true);
            if~isempty(sharedutilsdir)

                sharedSrcInfo=dir(fullfile(sharedutilsdir,'*.c*'));
                sharedSrcFiles=fullfile(sharedutilsdir,{sharedSrcInfo.name});

                sharedHeaderInfo=dir(fullfile(sharedutilsdir,'*.h'));
                sharedHeaders={sharedHeaderInfo.name};
                sharedIncFiles=fullfile(sharedutilsdir,sharedHeaders);
            else
                sharedSrcFiles={};
                sharedIncFiles={};
            end
        end
    end

    methods
        function[ret,context]=initialize(h,buildInfo,context,varargin)
            ret=true;

            if isequal(buildInfo.getBuildName,'rtwshared')


                return;
            end

            mycontext.modelName=buildInfo.getBuildName;
            mycontext.ActiveBuildConfiguration=context.ActiveBuildConfiguration;
            mycontext.isMDL=buildInfo.ModelHandle~=0||...
            ~isempty(find_system(0,'SearchDepth',1,...
            'Type','block_diagram','Name',mycontext.modelName));


            mycontext.anchorDir=buildInfo.Settings.LocalAnchorDir;
            if mycontext.isMDL
                lang=get_param(mycontext.modelName,'TargetLang');
                assert(isequal(lang,'C++'),...
                "dds:cgen:CppLanguageRequired",...
                getString(message("dds:cgen:CppLanguageRequired",lang)));
                genCodeOnly=isequal(get_param(mycontext.modelName,'GenCodeOnly'),'on');
            elseif~isempty(buildInfo.Settings.BuildInfoOutputFolder)

                genCodeOnly=false;
            end



            pjtData=getProjectData(h);
            if~isempty(pjtData)
                mycontext.ProjectData=pjtData;
            end
            appName=h.getValidApplicationName(mycontext.modelName);
            if strcmp(context.ActiveBuildConfiguration,'Debug')
                if ispc||ismac
                    buildType='RelWithDebInfo';
                else
                    buildType='Debug';
                end
            else
                buildType='Release';
            end
            mycontext.projectBuilder=h.getDDSProjectBuilder(...
            mycontext.anchorDir,appName,'GenCodeOnly',genCodeOnly,...
            'BuildType',buildType);
            context=mycontext;
        end

        function[ret,context]=createProject(h,buildInfo,context,varargin)
            if isequal(buildInfo.getBuildName,'rtwshared')

                ret=buildInfo.getBuildName;
                return;
            end
            type=varargin{2};
            comp=varargin{3};
            if type==coder.make.enum.BuildOutput.EXECUTABLE
                context.isLib=false;
                context.isSharedUtil=false;
            elseif type==coder.make.enum.BuildOutput.STATIC_LIBRARY
                context.isLib=true;
                context.isSharedUtil=~isempty(strfind(comp.FinalProduct.TargetInfo.TargetFile,'rtwshared'));
            else
                assert(false);
            end

            context.libs={};
            context.Libraries={};
            context.LibraryDirectories={};
            libSize=length(comp.Libraries);


            if libSize>1
                libs=comp.Libraries;
            elseif libSize==1
                libs={comp.Libraries};
            end

            isPrecompiled=arrayfun(@(x)x.Precompiled,buildInfo.getLinkObjects,'UniformOutput',false);
            precompiledLibNames=arrayfun(@(x)x.Name,buildInfo.getLinkObjects,'UniformOutput',false);

            for i=1:libSize
                libstruct=libs{i};
                if~isempty(libstruct.value)





                    for numLibs=1:numel(libstruct.value)
                        pathToLib=buildInfo.formatPaths(libstruct.value{numLibs},'replaceStartDirWithRelativePath',true);
                        [~,libName,ext]=fileparts(libstruct.value{numLibs});
                        [found,idx]=ismember([libName,ext],precompiledLibNames);
                        if isequal(libName,'rtwshared')


                            continue;
                        end
                        if found&&~isempty(isPrecompiled)&&isPrecompiled{idx}
                            context.Libraries{end+1}=[libName,ext];
                            context.LibraryDirectories{end+1}=fileparts(pathToLib);
                        else

                            tempLibName=fullfile(pathToLib);
                            if isfile(tempLibName)
                                context.libs{end+1}=dds.internal.coder.Util.getAbsolutePath(tempLibName);
                            else
                                [apath,aname,~]=fileparts(tempLibName);
                                anothertempLibName=fullfile(apath,[aname,'.lib']);
                                if isfile(anothertempLibName)
                                    context.libs{end+1}=dds.internal.coder.Util.getAbsolutePath(anothertempLibName);
                                else


                                    context.libs{end+1}=tempLibName;
                                end
                            end
                        end
                    end
                end
            end

            mdlName=buildInfo.getBuildName;


            assert(isequal(context.modelName,mdlName));
            pkgName=h.getValidApplicationName(mdlName);
            pkgInfo=context.projectBuilder.getPackageInfo(pkgName);





            findIncludeFiles(buildInfo,...
            'extensions',{'*.h','*.hpp'},...
            'ignoreParseError',true);

            defines=buildInfo.getDefines();
            [sharedSrcFiles,sharedIncFiles]=h.getSharedUtilsSources(buildInfo);
            srcFiles=unique([buildInfo.getSourceFiles(true,true),sharedSrcFiles]);
            incFiles=unique([buildInfo.getIncludeFiles(true,true),sharedIncFiles]);
            idlFiles=buildInfo.getNonBuildFiles(true,true,'DDS_IDL');
            xmlFiles=buildInfo.getNonBuildFiles(true,true,'DDS_XML');


            incPaths=buildInfo.getIncludePaths(true);
            incPaths=replace(incPaths,context.projectBuilder.RootDir,'');
            buildDirList=buildInfo.getBuildDirList;
            for i=1:numel(buildDirList)
                incPaths=replace(incPaths,buildDirList{i},'');
                [~,buildDir,~]=fileparts(buildDirList{i});
                incPaths=replace(incPaths,['/',buildDir],'');
            end
            installdirWithForwardSlash=replace(matlabroot,'\','/');
            incPathsWithInstallRoot=cellfun(@(x)startsWith(x,installdirWithForwardSlash),incPaths);
            incPaths(incPathsWithInstallRoot)=[];
            incPaths=incPaths(~cellfun(@isempty,incPaths));

            concatDefines=sprintf('%s ',defines{:});
            pkgInfo.CppFlags=[pkgInfo.CppFlags,concatDefines];
            if strcmp(context.ActiveBuildConfiguration,'Specify')
                tcCppFlags=comp.ToolchainFlags.getValue('C++ Compiler').custom.value;
                if context.isLib
                    tcLinkFlags=comp.ToolchainFlags.getValue('Archiver').custom.value;
                else
                    tcLinkFlags=comp.ToolchainFlags.getValue('C++ Linker').custom.value;
                end
                tcCMakeFlags=comp.ToolchainFlags.getValue('IDE Tool').custom.value;
                tcCMakeFlags=strsplit(tcCMakeFlags,'\\n');
                if~isempty(tcCppFlags)
                    pkgInfo.CppFlags=[pkgInfo.CppFlags,' ',tcCppFlags];
                end
                if~isempty(tcLinkFlags)
                    pkgInfo.LinkerFlags=[pkgInfo.LinkerFlags,' ',tcLinkFlags];
                end
                if~isempty(tcCMakeFlags)
                    pkgInfo.CMakeOptions=[pkgInfo.CMakeOptions,tcCMakeFlags];
                end
            end
            if context.isLib
                pkgInfo.LibSourceFiles=srcFiles;
                pkgInfo.LibIncludeFiles=incFiles;
                pkgInfo.LibFormat='STATIC';
            else
                pkgInfo.SourceFiles=srcFiles;
                pkgInfo.IncludeFiles=incFiles;
            end
            pkgInfo.IDLFiles=idlFiles;
            pkgInfo.XMLFiles=xmlFiles;
            if~isempty(incPaths)
                pkgInfo.IncludeDirectories=incPaths;
            end

            libNames=cell(1,numel(context.libs));
            libDirs=cell(1,numel(context.libs));
            if~isempty(context.libs)
                for i=1:numel(context.libs)
                    [libDirs{i},aName,anExt]=fileparts(context.libs{i});
                    libNames{i}=[aName,anExt];
                end
            end
            if~isempty(context.Libraries)||~isempty(libNames)
                pkgInfo.Libraries=unique([context.Libraries,libNames],'stable');
                pkgInfo.LibraryDirectories=unique([context.LibraryDirectories,libDirs],'stable');
            end

            context.projectBuilder.updatePackage(pkgInfo);

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...




...
...
...
...
...
...
...
...
            context.pkgsToBuild=pkgInfo.PackageName;

            context.projectBuilder.createPackage([],true);
            ret=pkgName;
        end

        function[ret,context]=buildProject(h,buildInfo,context,varargin)
            mdlName=buildInfo.getBuildName;
            if isequal(mdlName,'rtwshared')
                sharedutilsdir=dds.internal.coder.Util.sharedUtilsDir(buildInfo,true);

                sharedLibFile=fopen(fullfile(sharedutilsdir,'rtwshared.a'),'w');
                fclose(sharedLibFile);
                ret='Success';
                return;
            end



            assert(isequal(context.modelName,mdlName));
            pkgName=h.getValidApplicationName(mdlName);
            pkgInfo=context.projectBuilder.getPackageInfo(pkgName);
            [res,installDir]=h.runBuildCommand(context);%#ok<ASGLU> %TO Consider: cat res into ret to show
            if context.isLib

                srcFileMap=containers.Map({'win64','maci64','glnxa64'},...
                {fullfile(installDir{1},[mdlName,'.lib']),...
                fullfile(installDir{1},['lib',mdlName,'.a']),...
                fullfile(installDir{1},['lib',mdlName,'.a'])});...
                srcFileName=srcFileMap(computer('arch'));
                [~,~,srcExt]=fileparts(srcFileName);
                if context.isMDL
                    destPath=fullfile(pwd,[mdlName,'_rtwlib',srcExt]);
                else
                    destPath=fullfile(pwd,[mdlName,srcExt]);
                end
                [status,msg,msgId]=copyfile(srcFileMap(computer('arch')),...
                destPath);
                if~status
                    error(msgId,msg);
                end
            else

                srcFileMap=containers.Map({'win64','maci64','glnxa64'},...
                {fullfile(installDir{1},[mdlName,'.exe']),...
                fullfile(installDir{1},mdlName),...
                fullfile(installDir{1},mdlName)});...
                srcFileName=srcFileMap(computer('arch'));
                [~,~,srcExt]=fileparts(srcFileName);
                destPath=fullfile(context.anchorDir,[mdlName,srcExt]);
                [status,msg,msgId]=copyfile(srcFileName,destPath);
                if~status
                    error(msgId,msg);
                end

                if ismember(context.projectBuilder.BuildType,{'Debug','RelWithDebInfo'})

                    if ismac
                        system(sprintf('dsymutil "%s" --flat',fullfile(installDir{1},mdlName)));
                    end

                    if ismac
                        debugFile=sprintf('%s.dwarf',mdlName);
                    elseif ispc
                        debugFile=sprintf('%s.pdb',mdlName);
                    else
                        debugFile='';
                    end
                    if~isempty(debugFile)
                        srcFile=fullfile(installDir{1},debugFile);
                        destPath=fullfile(context.anchorDir,debugFile);
                        [status,msg,msgId]=copyfile(srcFile,destPath);
                        if~status
                            error(msgId,msg);
                        end
                    end
                end


                xmlFiles=pkgInfo.XMLFiles;
                for ii=1:numel(xmlFiles)
                    [~,fname,fext]=fileparts(xmlFiles{ii});
                    xmlFileName=[fname,fext];
                    srcFileName=xmlFiles{ii};
                    destPath=fullfile(context.anchorDir,xmlFileName);
                    [status,msg,msgId]=copyfile(srcFileName,destPath,'f');
                    if~status
                        error(msgId,msg);
                    end
                end




                bdir=RTW.getBuildDir(mdlName);
                destPath=bdir.BuildDirectory;
                pkgSrcFileDir=fullfile(context.anchorDir,[pkgInfo.PackageName,'.pkg'],'src');
                files=dir(pkgSrcFileDir);
                for i=1:numel(files)
                    file=files(i).name;
                    [~,~,ext]=fileparts(file);
                    if~(strcmp(ext,'.h')||strcmp(ext,'.hpp')||strcmp(ext,'.c')...
                        ||strcmp(ext,'.cpp')||strcmp(ext,'.cxx'))
                        continue;
                    end
                    buildInfoHeaderFiles=buildInfo.Inc.Files;
                    needCopy=true;
                    for j=1:numel(buildInfoHeaderFiles)
                        buildInfoHeaderName=buildInfoHeaderFiles(j).FileName;
                        if strcmp(file,buildInfoHeaderName)
                            needCopy=false;
                            break;
                        end
                    end
                    if needCopy
                        [status,msg,msgId]=copyfile(fullfile(pkgSrcFileDir,file),...
                        fullfile(destPath,file),'f');
                        if~status
                            error(msgId,msg);
                        end
                        if strcmp(ext,'.h')||strcmp(ext,'.hpp')
                            buildInfo.addIncludeFiles(file,destPath);
                        elseif strcmp(ext,'.c')||strcmp(ext,'.cpp')||strcmp(ext,'.cxx')
                            buildInfo.addSourceFiles(file,destPath);
                        end
                    end
                end

            end


            ret='Success';
        end

        function[ret,context]=downloadProject(h,buildInfo,context,varargin)%#ok<INUSL>
            ret=true;

        end

        function[ret,context]=runProject(h,buildInfo,context,varargin)%#ok<INUSL>
            ret=true;

        end

        function[ret,context]=onError(h,buildInfo,context,varargin)%#ok<INUSL>
            ret=true;
            try
                if~context.isSharedUtil
                end
            catch
            end
        end

        function[ret,context]=terminate(h,buildInfo,context,varargin)%#ok<INUSD>
            ret=true;
            context=[];
        end
    end


    methods(Static,Hidden)
    end

end
