classdef PackageMaker<hwconnectinstaller.internal.PackageInfo






    properties
        Configuration='debug';
        RootDir='';
    end

    properties(Access=private)
        SupportPkg=hwconnectinstaller.SupportPackage();
    end

    properties(Constant,GetAccess=private)
        DIRSTOSKIPFORRELEASE={'^CVS$','^sdl$','\.dSYM$',...
        '^autosave$','^autobuild$','^\.ts$',...
        '^internal$',...
        '^mdl_auto_save_tokens$','^mdl_auto_build_tokens$','^lib$',...
        '^specs$','^sdwriter$'};
        FILESTOSKIPFORRELEASE={'DEPENDS\.pcode$','\.mk$',...
        '\.warn$','\.vsd$','\.~vsd$','\.pdb$','\.manifest$','\.map$','\.exp$',...
        '\.mexglx\.dbg$','\.mexa64\.dbg$','\.cpp$','\.mtf$',...
        'makefile\.gnu$','make_support_packages\.m$',...
        'Makefile$','MAKEFILE_LIST$','Makefile\.xlate$',...
        'OUT_OF_MODEL\.mk$','^WARNING_EXCEPTION_LIST',...
        '\w+_info\.m$','Contents\.m_template$','Contents\.m$',...
        'EXCLUDE_LIST\.all$','make_\w+_support_package\.m','makefile_\w+\.gnu',...
        'MODULE_DEPENDENCIES$','WARNING_EXCEPTION_LIST$'};
        DIRSTOSKIPFORDEBUG={'^CVS$','^sdl$','\.dSYM$'};
        FILESTOSKIPFORDEBUG={'\w+_info\.m','Contents\.m',...
        '\.map','\.exp'};
    end

    methods
        function obj=PackageMaker(configuration)
            if(nargin>1)
                obj.Configuration=configuration;
            end
        end

        function obj=set.SupportPkg(obj,supportPkg)
            if~isa(supportPkg,'hwconnectinstaller.SupportPackage')
                error(message('hwconnectinstaller:setup:WrongClass',...
                'supportpkg','hwconnectinstaller.SupportPackage'));
            end
            obj.SupportPkg=supportPkg;
        end

        function obj=set.Configuration(obj,configuration)
            configuration=lower(strtrim(configuration));
            configs={'debug','release'};
            if ismember(configuration,configs)
                obj.Configuration=configuration;
            else
                error(message('hwconnectinstaller:setup:InvalidConfiguration'));
            end
        end

        function set.RootDir(obj,rootDir)%#ok<MCHV2>
            if~ischar(rootDir)
                error(message('hwconnectinstaller:setup:InvalidArgument',...
                'Input argument'));
            end
            obj.RootDir=rootDir;
        end
    end

    methods(Access=public)
        function[archivefile,xmlfile]=make(obj,folder,configuration,createXmlFile)





            if(nargin>2)
                obj.Configuration=configuration;
            end
            if(nargin<4)
                createXmlFile=false;
            end


            if isempty(obj.RootDir)
                spdir=pwd;
            else
                spdir=fullfile(obj.RootDir,folder);
            end
            hdir=hwconnectinstaller.util.Location(spdir);
            if~hdir.exists
                error(message('hwconnectinstaller:setup:RootdirDoesNotExist',spdir));
            end


            obj.SupportPkg=hwconnectinstaller.SupportPackage;
            obj.SupportPkg=obj.loadSpPkgInfo(spdir,obj.SupportPkg);




            folderNameForPackageCreation=folder;
            folderNameForPackageInstall=obj.SupportPkg.Folder;





            obj.SupportPkg.TpPkg=loadTpPkgInfo(obj,spdir,[],struct('currentPlatformOnly',false));






            destFile=fullfile(spdir,'license.txt');
            if isequal(lower(obj.SupportPkg.CustomLicense),'yes')
                srcFile=fullfile(matlabroot,'toolbox','shared','hwconnectinstaller','resources','usrp_license.txt');
            else
                if~isempty(regexpi(hwconnectinstaller.util.getCurrentRelease,'Prerelease'))

                    srcFile=fullfile(matlabroot,'toolbox','shared','hwconnectinstaller','resources','prerelease_license.txt');
                else
                    srcFile=fullfile(matlabroot,'toolbox','shared','hwconnectinstaller','resources','license.txt');
                end
            end
            copyfile(srcFile,destFile,'f');


            filelist=obj.getSpPkgFiles(spdir,folderNameForPackageCreation);


            if(createXmlFile)
                xmlfile=obj.createXmlFile(folderNameForPackageInstall);
            end


            if isempty(obj.RootDir)
                hwconnectinstaller.util.zip(obj.SupportPkg.ArchiveName,...
                filelist,...
                pwd);
            else
                hwconnectinstaller.util.zip(obj.SupportPkg.ArchiveName,...
                filelist,...
                obj.RootDir);
            end


            archivefile=fullfile(pwd,obj.SupportPkg.ArchiveName);
        end

    end

    methods(Access=private)

        function filelist=getSpPkgFiles(obj,spdir,supportPkgFolder)

            filelist=obj.getFiles(spdir,true);



            filelist=obj.filterFileExtension(filelist,'.m','.p');


            filelist=obj.filterFileExtension(filelist,'.m','.html');


            for i=1:numel(filelist)
                filelist{i}=fullfile(supportPkgFolder,filelist{i});
            end


            for i=1:length(obj.SupportPkg.FilesToPackage)
                fileToAdd=fullfile(supportPkgFolder,...
                obj.SupportPkg.FilesToPackage{i});
                if~ismember(fileToAdd,filelist)
                    filelist{end+1}=fileToAdd;%#ok<AGROW>
                end
            end


            filesToExclude=false(size(filelist));
            for i=1:length(obj.SupportPkg.FilesToExclude)
                fileToRemove=fullfile(supportPkgFolder,...
                obj.SupportPkg.FilesToExclude{i});
                filesToExclude=filesToExclude|...
                ismember(filelist,fileToRemove);
            end
            filelist(filesToExclude)=[];
        end




        function xmlfile=createXmlFile(obj,supportPkgFolder)
            fid=fopen(obj.SupportPkg.XmlFile,'w');
            if(fid<0)
                error(message('hwconnectinstaller:setup:FileOpenError','support_package_info.m'));
            end
            c=onCleanup(@()fclose(fid));


            fprintf(fid,'<?xml version="1.0"?>\n');
            fprintf(fid,'<!--Copyright %s The MathWorks, Inc. -->\n',date);
            fprintf(fid,'<PackageRepository>\n');
            fprintf(fid,'    <MatlabRelease name="%s">\n',obj.SupportPkg.Release);
            fprintf(fid,'        <SupportPackage\n');
            fprintf(fid,'            name="%s"\n',obj.SupportPkg.Name);
            fprintf(fid,'            version="%s"\n',obj.SupportPkg.Version);
            fprintf(fid,'            platform="%s"\n',obj.SupportPkg.PlatformStr);
            fprintf(fid,'            visible="%d"\n',obj.SupportPkg.Visible);
            fprintf(fid,'            enable="%d"\n',obj.SupportPkg.Enable);
            fprintf(fid,'            url="%s"\n',obj.SupportPkg.Url);
            fprintf(fid,'            baseproduct="%s"\n',obj.SupportPkg.BaseProduct);
            if obj.SupportPkg.AllowDownloadWithoutInstall
                fprintf(fid,'            allowdownloadwithoutinstall="yes"\n');
            else
                fprintf(fid,'            allowdownloadwithoutinstall="no"\n');
            end
            fprintf(fid,'            fullname="%s"\n',obj.SupportPkg.FullName);
            fprintf(fid,'            displayname="%s"\n',obj.SupportPkg.DisplayName);
            fprintf(fid,'            supportcategory="%s"\n',obj.SupportPkg.SupportCategory);
            fprintf(fid,'            customlicense="%s"\n',obj.SupportPkg.CustomLicense);
            fprintf(fid,'            customlicensenotes="%s"\n',obj.SupportPkg.CustomLicenseNotes);
            if obj.SupportPkg.ShowSPLicense
                fprintf(fid,'            showsplicense="yes"\n');
            else
                fprintf(fid,'            showsplicense="no"\n');
            end
            fprintf(fid,'            downloadurl="%s"\n',obj.SupportPkg.DownloadUrl);
            fprintf(fid,'            licenseurl="%s"\n',obj.SupportPkg.LicenseUrl);
            fprintf(fid,'            folder="%s">\n',supportPkgFolder);

            for i=1:length(obj.SupportPkg.Children)
                fprintf(fid,'        <DependsOn name="%s" version="%s"></DependsOn>\n',...
                obj.SupportPkg.Children(i).Name,...
                obj.SupportPkg.Children(i).Version);
            end

            for i=1:length(obj.SupportPkg.TpPkg)
                fprintf(fid,'            <ThirdPartyPackage name="%s" platforms="%s" url="%s" licenseurl="%s"></ThirdPartyPackage>\n',...
                obj.SupportPkg.TpPkg(i).Name,...
                obj.SupportPkg.TpPkg(i).PlatformStr,...
                obj.SupportPkg.TpPkg(i).Url,...
                obj.SupportPkg.TpPkg(i).LicenseUrl);
            end
            fprintf(fid,'        </SupportPackage>\n');
            fprintf(fid,'    </MatlabRelease>\n');
            fprintf(fid,'</PackageRepository>\n');


            xmlfile=fullfile(pwd,obj.SupportPkg.XmlFile);
        end


        function ret=skipDir(obj,dirName)
            if(regexp(dirName,'^\.\.*$'))
                ret=true;
                return
            end


            if isequal(obj.Configuration,'debug')
                dirsToSkip=obj.DIRSTOSKIPFORDEBUG;
            else
                dirsToSkip=obj.DIRSTOSKIPFORRELEASE;
            end


            cellNotEmptyFcn=@(x)~isempty(x);
            tmp=regexp(dirName,dirsToSkip);
            if any(cellfun(cellNotEmptyFcn,tmp))
                ret=true;
            else
                ret=false;
            end
        end


        function ret=skipFile(obj,fileName)

            cellNotEmptyFcn=@(x)~isempty(x);


            if isequal(obj.Configuration,'debug')
                filesToSkip=obj.FILESTOSKIPFORDEBUG;
            else
                filesToSkip=obj.FILESTOSKIPFORRELEASE;
            end

            tmp=regexp(fileName,filesToSkip);
            if any(cellfun(cellNotEmptyFcn,tmp))
                ret=true;
            else
                ret=false;
            end
        end


        function fileList=getFiles(obj,rootDir,recurse)
            if(nargin<3)
                recurse=false;
            end


            files=dir(rootDir);
            fileList={};
            for i=1:numel(files)
                if(files(i).isdir)
                    if(~recurse||obj.skipDir(files(i).name))
                        continue;
                    end
                    subDir=fullfile(rootDir,files(i).name);
                    tmpList=obj.getFiles(subDir,recurse);
                    for j=1:numel(tmpList)
                        tmpList{j}=fullfile(files(i).name,tmpList{j});
                    end
                    fileList=[fileList,tmpList];%#ok<AGROW>
                else
                    if~obj.skipFile(files(i).name)
                        fileList{end+1}=files(i).name;%#ok<AGROW>
                    end
                end
            end
        end
    end

    methods(Static,Hidden)

        function dirList=getDirs(rootDir,recurse,filter)
            if(nargin<2)
                recurse=false;
            end
            if(nargin<3)
                filter={};
            end
            if~iscell(filter)
                error(message('hwconnectinstaller:setup:Error',...
                'Input argument, filter, must be a cell array.'))
            end
            cellNotEmptyFcn=@(x)~isempty(x);


            files=dir(rootDir);
            dirList={};
            for i=1:length(files)
                if(~files(i).isdir)
                    continue;
                end

                if(regexp(files(i).name,'^\.\.*$'))
                    continue;
                end
                tmp=regexp(files(i).name,filter);
                if any(cellfun(cellNotEmptyFcn,tmp))
                    continue;
                end
                dirList{end+1}=files(i).name;%#ok
                if(recurse)
                    subDir=fullfile(rootDir,files(i).name);
                    subDirList=hwconnectinstaller.PackageMaker.getDirs(subDir,true,filter);
                    for j=1:numel(subDirList)
                        subDirList{j}=fullfile(files(i).name,subDirList{j});
                    end
                    dirList=[dirList,subDirList];%#ok<AGROW>
                end
            end
        end

        function fileList=filterFileExtension(fileList,ext1,ext2)



            rmIndx=[];
            for i=1:numel(fileList)
                [p,n,ext]=fileparts(fileList{i});
                if strcmp(ext,ext1)
                    pfile=fullfile(p,[n,ext2]);
                    if ismember(pfile,fileList)
                        rmIndx=[rmIndx,i];%#ok<AGROW>
                    end
                end
            end
            fileList(rmIndx)=[];
        end
    end

end

