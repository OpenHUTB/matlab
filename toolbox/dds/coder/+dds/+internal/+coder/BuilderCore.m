classdef(Abstract)BuilderCore<handle








    properties(Hidden,SetAccess=protected)
CMakePath
CMakeVersion
Parser
MexInfo
        GenCodeOnly=false;
RootDir
Packages
    end

    properties(Constant,Hidden)
        PKGINFONAME='packageInfo.mat';
    end

    methods(Abstract)
        getCMakePath;
        createVendorArtifacts;
        buildPackage;
    end

    methods

        function set.RootDir(h,value)
            validateattributes(value,{'char','string'},{'nonempty'});

            if exist(value,'dir')~=7
                error(message('dds:util:RootDirDoesNotExist',value));
            end
            h.RootDir=convertStringsToChars(value);
        end

        function createInputParser(h)



            h.Parser=inputParser;
            h.Parser.addRequired('rootDir',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            dds.internal.coder.PackageInfo.addParamsToParser(h.Parser);
            h.Parser.addParameter('GenCodeOnly',false,@(x)islogical(x));
        end

        function idx=findPackage(h,packageName)

            idx=[];
            if~isempty(h.Packages)
                matchingIdxs=cellfun(@(x)isequal(x.PackageName,packageName),h.Packages);
                idx=find(matchingIdxs);
            end
        end

        function pkgInfo=getPackageInfo(h,pkgName)
            validateattributes(pkgName,{'char','string'},{'nonempty'});
            pkgName=convertStringsToChars(pkgName);
            idx=h.findPackage(pkgName);
            if isempty(idx)
                error(message('dds:util:PackageNotFound',pkgName));
            end
            pkgInfo=h.Packages{idx};
        end

        function pkgFolder=getPackageFolder(~,pkgName)

            pkgFolder=[pkgName,'.pkg'];
        end

        function copyFiles(h,srcFiles,destDir)


            if~isempty(srcFiles)
                for i=1:numel(srcFiles)
                    file=srcFiles{i};
                    [filepath,~,~]=fileparts(file);
                    if endsWith(filepath,'sfcn_rtw')

                        folders=strsplit(filepath,{'/','\'});
                        sFcnSourceDir=fullfile(destDir,folders{end});
                        h.chkAndCreateDir(sFcnSourceDir);
                        [status,msg,msgid]=...
                        copyfile(file,sFcnSourceDir,'f');
                    else

                        [status,msg,msgid]=...
                        copyfile(file,destDir,'f');

                    end
                    if~status
                        error(msgid,msg);
                    end
                end
            end
        end

        function chkAndCreateDir(~,pathToCreate)

            if~isfolder(pathToCreate)
                [status,msg,msgid]=mkdir(pathToCreate);
                if~status
                    error(msgid,msg);
                end
            end
        end

        function clnUp=createAndChangeToSrcDir(h)

            rootDir=h.RootDir;
            h.chkAndCreateDir(rootDir);
            curDir=cd(rootDir);
            clnUp=onCleanup(@()cd(curDir));
        end

        function makeDirStructure(h,~,pkgDir,pkgSrc)

            h.chkAndCreateDir(pkgDir);
            h.chkAndCreateDir(pkgSrc);
        end

        function pkgInfoStruct=getAndUpdatePkgInfo(~,pkgInfo)



            lastWarnState=warning('OFF','MATLAB:structOnObject');
            clnup=onCleanup(@()warning(lastWarnState));
            pkgInfoStruct=struct(pkgInfo);
            clnup=[];%#ok<NASGU>
            for i=1:numel(pkgInfoStruct.SourceFiles)
                [~,fname,fext]=fileparts(pkgInfoStruct.SourceFiles{i});
                pkgInfoStruct.SourceFiles{i}=['src/',fname,fext];
            end
            for i=1:numel(pkgInfoStruct.IncludeFiles)
                [~,fname,fext]=fileparts(pkgInfoStruct.IncludeFiles{i});
                pkgInfoStruct.IncludeFiles{i}=['include/',pkgInfoStruct.PackageName,'/',fname,fext];
            end
            for i=1:numel(pkgInfoStruct.LibSourceFiles)
                [~,fname,fext]=fileparts(pkgInfoStruct.LibSourceFiles{i});
                pkgInfoStruct.LibSourceFiles{i}=['src/',fname,fext];
            end
            for i=1:numel(pkgInfoStruct.LibIncludeFiles)
                [~,fname,fext]=fileparts(pkgInfoStruct.LibIncludeFiles{i});
                pkgInfoStruct.LibIncludeFiles{i}=['include/',pkgInfoStruct.PackageName,'/',fname,fext];
            end
            for i=1:numel(pkgInfoStruct.XMLFiles)
                [~,fname,fext]=fileparts(pkgInfoStruct.XMLFiles{i});
                pkgInfoStruct.XMLFiles{i}=[fname,fext];
            end
            for i=1:numel(pkgInfoStruct.IDLFiles)
                [~,fname,fext]=fileparts(pkgInfoStruct.IDLFiles{i});
                pkgInfoStruct.IDLFiles{i}=[fname,fext];
            end
        end

        function createFileFromTemplate(~,pkgInfoStruct,template,tlcFuncName,filePath)


            str=dds.internal.coder.evalTLCWithParam(template,tlcFuncName,pkgInfoStruct);
            fp=fopen(filePath,'wt');
            if fp<0
                error(message('MATLAB:save:cantWriteFile',filePath));
            else
                fwrite(fp,str);
                fclose(fp);
            end
        end

        function result=createGivenPackage(h,pkgName,force)

            clnUp=h.createAndChangeToSrcDir;%#ok<NASGU>

            validateattributes(force,{'logical'},{'nonempty'});
            validateattributes(pkgName,{'char','string'},{'nonempty'});
            pkgName=convertStringsToChars(pkgName);

            pkgInfo=h.getPackageInfo(pkgName);
            pkgDir=fullfile(h.RootDir,h.getPackageFolder(pkgName));
            cmakeFilePath=fullfile(pkgDir,'CMakeLists.txt');



            if force
                if isfolder(pkgDir)
                    [status,msg,msgid]=rmdir(pkgDir,'s');
                    if status~=1
                        error(msgid,strrep(msg,'\','/'));
                    end
                end
            else
                if isfile(cmakeFilePath)
                    result=pkgDir;
                    return;
                end
            end


            sourceDir=fullfile(pkgDir,'src');

            pkgInfo.IncludeDirectories{end+1}=sourceDir;


            h.makeDirStructure(pkgInfo,pkgDir,sourceDir);


            h.copyFiles(pkgInfo.SourceFiles,sourceDir);
            h.copyFiles(pkgInfo.LibSourceFiles,sourceDir);

            h.copyFiles(pkgInfo.IncludeFiles,sourceDir);
            h.copyFiles(pkgInfo.LibIncludeFiles,sourceDir);

            h.copyFiles(pkgInfo.XMLFiles,sourceDir);

            h.copyFiles(pkgInfo.IDLFiles,sourceDir);


            pkgInfoStruct=h.getAndUpdatePkgInfo(pkgInfo);

            h.createVendorArtifacts(pkgInfoStruct,pkgDir);
            packageInfo=fullfile(pkgDir,h.PKGINFONAME);
            save(packageInfo,'pkgInfo');
            result=pkgDir;
        end

    end


    methods
        function h=BuilderCore(varargin)
            h.createInputParser();
            h.Parser.parse(varargin{:});
            h.RootDir=h.Parser.Results.rootDir;
            [h.CMakePath,h.CMakeVersion]=h.getCMakePath();
            h.addPackage(h.Parser);
            h.MexInfo=mex.getCompilerConfigurations('C++');
            if isempty(h.MexInfo)
                error(message('dds:cgen:NeedCPPCompiler'))
            end
        end

        function addPackage(h,varargin)


            pkg=dds.internal.coder.PackageInfo(varargin{:});


            idx=h.findPackage(pkg.PackageName);
            if~isempty(idx)
                error(message('dds:util:DuplicatePackageName',pkg.PackageName));
            end


            if isempty(h.Packages)
                h.Packages{1}=pkg;
            else
                h.Packages{end+1}=pkg;
            end
        end

        function rmPackage(h,pkgName)

            validateattributes(pkgName,{'char','string'},{'nonempty'});
            pkgName=convertStringsToChars(pkgName);
            idx=h.findPackage(pkgName);
            if isempty(idx)
                error(message('dds:util:PackageNotFound',pkgName));
            end
            h.Packages(idx)=[];
        end

        function updatePackage(h,pkgInfo)
            validateattributes(pkgInfo,{'dds.internal.coder.PackageInfo'},{'nonempty'});
            idx=h.findPackage(pkgInfo.PackageName);
            if isempty(idx)
                error(message('dds:util:PackageNotFound',pkgInfo.PackageName));
            end
            h.Packages{idx}=pkgInfo;
        end

        function results=createPackage(h,pkgNames,force)



            if nargin<3
                force=false;
            else
                validateattributes(force,{'logical'},{'nonempty'});
            end
            if nargin<2||isempty(pkgNames)

                pkgNames=cellfun(@(x)x.PackageName,h.Packages,'UniformOutput',false);
            else

                if~iscell(pkgNames)
                    pkgNames={pkgNames};
                end

                cellfun(@(x)validateattributes(x,{'char','string'},{'nonempty'}),pkgNames);
                pkgNames=cellfun(@(x)convertStringsToChars(x),pkgNames,'UniformOutput',false);

                for i=1:numel(pkgNames)
                    idx=h.findPackage(pkgNames{i});
                    if isempty(idx)
                        error(message('dds:util:PackageNotFound',pkgNames{i}));
                    end
                end
            end

            results=cell(1,numel(pkgNames));
            for i=1:numel(pkgNames)
                results{i}=h.createGivenPackage(pkgNames{i},force);
            end
        end
    end
end

