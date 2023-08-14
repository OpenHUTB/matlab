




classdef Relationship<handle
    properties(Hidden)
        FileList={};
        CategoryList={};
        EncryptedFileList={};
        SubDir={};
        RelationshipName='';
PartProperties
        DirName='';
        InitialDir='';
        NoRelationshipInPath=false;
        NoLibs=false;
        PartPropStruct=[];


        isEncrypted=false;
    end

    properties(Transient)
        PartsMap=containers.Map;
BuildInfo
    end

    methods(Abstract)


        populate(obj,creator)
    end

    methods(Static,Abstract)


        out=getRelationshipYear(~)



        out=getEncryptionCategory(~)

    end

    methods


        function out=getPurpose(obj)
            out=obj.RelationshipName;
        end



        function out=getPartProperties(~,~)
            out='';
        end

        function out=getCategoryList(obj)
            out=obj.CategoryList;
        end



        function result=getPartPrefix(~,~)
            result='';
        end



        function obj=Relationship(protectedModelCreator)
            obj.FileList={};
            obj.CategoryList={};
            obj.RelationshipName='';
            obj.PartProperties=containers.Map;
            obj.DirName='';
            obj.NoRelationshipInPath=false;
            if nargin>0

                obj.InitialDir=protectedModelCreator.initialDir;
            end
        end



        function runChecks(obj)

            fileList=obj.getFileList();


            if isempty(fileList)
                DAStudio.error('Simulink:protectedModel:ProtectedModelEmptyFileList');
            elseif isempty(obj.RelationshipName)
                DAStudio.error('Simulink:protectedModel:RelationshipNameNotSpecified');
            elseif isempty(obj.DirName)
                DAStudio.error('Simulink:protectedModel:destinationNotSpecified');
            elseif isempty(obj.SubDir)
                DAStudio.error('Simulink:protectedModel:destinationNotSpecified');
            end
        end



        function addRelationship(obj,creator)

            fileList=obj.getFileList();



            obj.runChecks();


            for i=1:length(fileList)


                srcFileName=fileList{i};

                [~,fileStem,fileExt]=fileparts(fileList{i});
                if isempty(fileExt)
                    fileType=creator.getMiscFileType();
                else
                    fileType=fileExt;
                end


                subdir=obj.SubDir{i};


                aDirList=dir(srcFileName);

                if~isempty(aDirList)&&aDirList(1).isdir
                    continue;
                end

                partPrefix=obj.getPartPrefix(creator);

                if obj.NoRelationshipInPath
                    currentPart=[partPrefix,'/',obj.DirName,'/',fileStem,fileExt];
                else
                    if isempty(subdir)
                        currentPart=[partPrefix,'/',obj.DirName,'/',obj.RelationshipName,'/',fileStem,fileExt];
                    else
                        if ispc
                            subdirFixed=strrep(subdir,'\','/');
                        else
                            subdirFixed=subdir;
                        end
                        currentPart=[partPrefix,'/',obj.DirName,'/',obj.RelationshipName,'/',subdirFixed,'/',fileStem,fileExt];
                    end
                end


                if isKey(obj.PartsMap,currentPart)
                    continue;
                end

                currentPartIdx=length(creator.parts)+1;
                currentRelationshipIdx=length(creator.relationships)+1;


                if isa(creator,'Simulink.ModelReference.ProtectedModel.Creator')
                    creator.relationships(currentRelationshipIdx).isEncrypted=obj.isEncrypted;
                    creator.relationships(currentRelationshipIdx).encryptionCategory=obj.getEncryptionCategory;
                end


                creator.parts(currentPartIdx).source=srcFileName;
                creator.parts(currentPartIdx).dest=currentPart;
                creator.parts(currentPartIdx).type=fileType(2:end);
                creator.parts(currentPartIdx).purpose=obj.getPurpose;
                creator.parts(currentPartIdx).properties=obj.getPartProperties(fileList{i});

                creator.relationships(currentRelationshipIdx).year=obj.getRelationshipYear;
                creator.relationships(currentRelationshipIdx).name=obj.RelationshipName;
                creator.relationships(currentRelationshipIdx).dest=currentPart;


                obj.PartsMap(currentPart)=currentPart;
            end

        end

        function out=getBuildInfo(obj)
            out=obj.BuildInfo;
        end

        function out=getFileList(obj)
            out=obj.FileList;
        end
    end

    methods(Access=protected)





        function addPartsUsingBuildInfo(obj,creator,buildDir,noPartsFromMatlabDir,buildInfo_patternName)
            buildInfo=obj.getBuildInfo();
            if~isempty(buildInfo)

                warnStatus=warning('query','RTW:buildInfo:unableToFindMinimalIncludes');
                warnState=warnStatus.state;

                warning('off','RTW:buildInfo:unableToFindMinimalIncludes');
                oc=onCleanup(@()warning(warnState,'RTW:buildInfo:unableToFindMinimalIncludes'));




                buildInfo.updateFilePathsAndExtensions();


                buildInfo.findIncludeFiles('minimalHeaders',true);


                [fileList,names]=buildInfo.getFullFileList();
                [sDirFiles,mlrFiles,otherFiles,~,pathToTopBuildInfo]=buildInfo.getHierarchicalFileList(fileList,names);
                sDirFiles=[sDirFiles,pathToTopBuildInfo];


                obj.updateBuildInfo(buildInfo);


                save(buildInfo_patternName,'buildInfo','-append');


                if creator.packageAllSourceCode()
                    if noPartsFromMatlabDir


                        obj.addNonSharedFiles(sDirFiles,buildDir,false,false);

                        obj.addNonSharedFiles(mlrFiles,buildDir,true,false);

                        obj.addNonSharedFiles(otherFiles,buildDir,false,true);
                    else


                        obj.addNonSharedFiles(sDirFiles,buildDir,false,false);

                        obj.addNonSharedFiles(otherFiles,buildDir,false,true);
                    end
                else




                    obj.addNonSharedFiles(sDirFiles,buildDir,false,false);
                end

            end
        end


        function addNonSharedFiles(obj,files,buildDirs,bMLRFiles,bOtherFiles)

            assert(~(bMLRFiles==true&&bOtherFiles==true));

            for i=1:length(files)
                [fpath,~,~]=fileparts(files{i});



                if obj.isNotInSharedUtilsDir(buildDirs,fpath)
                    if bMLRFiles
                        obj.FileList{end+1}=fullfile(matlabroot,files{i});
                        obj.CategoryList{end+1}='matlab';
                        obj.SubDir{end+1}=fullfile('matlab',fpath);
                    elseif bOtherFiles




                        obj.FileList{end+1}=files{i};
                        obj.CategoryList{end+1}='other';
                        if~isempty(obj.InitialDir)&&startsWith(fpath,[obj.InitialDir,filesep])
                            obj.SubDir{end+1}=fpath(length(obj.InitialDir)+2:end);
                        else
                            obj.SubDir{end+1}='';
                        end
                    else


                        obj.FileList{end+1}=files{i};
                        obj.CategoryList{end+1}='build';
                        obj.SubDir{end+1}=fpath;
                    end
                end
            end
        end




        function addPartUsingFilePattern(obj,srcDirPattern,subdir,varargin)

            narginchk(3,4);

            excludeList={};
            if nargin==4
                excludeList=varargin{1};
            end



            fileList=dir(srcDirPattern);
            if isempty(obj.FileList)
                fileListMap=containers.Map;
            else
                fileListMap=containers.Map(obj.FileList,obj.FileList);
            end

            [srcDir,~,~]=fileparts(srcDirPattern);

            for i=1:length(fileList)

                if fileList(i).isdir
                    continue;
                end



                if obj.NoLibs
                    [~,~,fext]=fileparts(fileList(i).name);
                    libext=['.',coder.make.internal.getLibExtension()];
                    if strcmp(fext,libext)
                        continue;
                    end
                end



                if~isempty(excludeList)&&iscell(excludeList)
                    if~isempty(intersect(fileList(i).name,excludeList))
                        continue;
                    end
                end


                current=fullfile(srcDir,fileList(i).name);
                if~fileListMap.isKey(current)
                    obj.FileList{end+1}=current;
                    obj.CategoryList{end+1}='build';
                    obj.SubDir{end+1}=subdir;


                    fileListMap(current)=current;
                end
            end
        end


        function addPartUsingFilePatternNoLibs(obj,srcDirPattern,subdir,varargin)
            obj.NoLibs=true;
            obj.addPartUsingFilePattern(srcDirPattern,subdir,varargin{:});
        end


        function res=shouldPackageInstrumentedFolder(~,creator,isPWSEnabled)
            res=isPWSEnabled&&~creator.packageSourceCode;
        end

        function out=getBuildDirTarget(~,tgt,buildDirs)
            switch(tgt)
            case 'SIM'
                rootDirBase=Simulink.ModelReference.ProtectedModel.getSimBuildDir();
                out=fullfile(rootDirBase,buildDirs.ModelRefRelativeSimDir);
            case 'RTW'
                rootDirBase=Simulink.ModelReference.ProtectedModel.getRTWBuildDir();
                out=fullfile(rootDirBase,buildDirs.ModelRefRelativeBuildDir);
            case 'NONE'
                rootDirBase=Simulink.ModelReference.ProtectedModel.getRTWBuildDir();
                out=fullfile(rootDirBase,buildDirs.RelativeBuildDir);
            otherwise
                assert(false,'Unexpected target %s.',tgt);
            end
        end

        function out=getBuildDir(obj,tgt,currentModel)
            buildDirs=RTW.getBuildDir(currentModel);
            out=obj.getBuildDirTarget(tgt,buildDirs);
        end





        function out=isNotInSharedUtilsDir(~,buildDirs,fpath)

            out=isempty(strfind(buildDirs.SharedUtilsSimDir,fpath))&&...
            isempty(strfind(buildDirs.SharedUtilsTgtDir,fpath));






            if strcmp(filesep,'/')
                newfilesep='\';
            else
                newfilesep='/';
            end


            simDirNewFileSep=strrep(buildDirs.SharedUtilsSimDir,filesep,newfilesep);
            tgtDirNewFileSep=strrep(buildDirs.SharedUtilsTgtDir,filesep,newfilesep);


            out=out&&...
            ~contains(simDirNewFileSep,fpath)&&...
            ~contains(tgtDirNewFileSep,fpath);
        end



        function out=tokenizeStartDir(obj,str)



            expression=strrep(['^',obj.InitialDir,'(?=(',filesep,'|$))'],'\','\\');
            out=regexprep(str,expression,'$(START_DIR)');
        end




        function updateBuildInfo(obj,buildInfoOrPath)
            if ischar(buildInfoOrPath)||isstring(buildInfoOrPath)

                load(buildInfoOrPath,'buildInfo');
            else
                buildInfo=buildInfoOrPath;
            end


            for module=[buildInfo.Inc,buildInfo.Src,buildInfo.Other]
                if~isempty(module.Paths)
                    if~isempty(obj.InitialDir)
                        set(module.Paths,{'Value'},obj.tokenizeStartDir(...
                        get(module.Paths,{'Value'})));
                    end

                    module.Paths=module.Paths(startsWith({module.Paths.Value},'$'));
                end
                if~isempty(module.Files)
                    if~isempty(obj.InitialDir)
                        set(module.Files,{'Path'},obj.tokenizeStartDir(...
                        get(module.Files,{'Path'})));
                    end

                    set(module.Files,{'Path'},regexprep(get(module.Files,{'Path'}),...
                    '^[^$].*',''));

                end
            end
            if ischar(buildInfoOrPath)||isstring(buildInfoOrPath)

                save(buildInfoOrPath,'buildInfo','-append');
            end
        end


        function updateBInfo(obj,bInfoPath)
            load(bInfoPath,'infoStruct');
            dirty=false;
            for f=["IncludeDirs","SourceDirs"]
                if isfield(infoStruct,f)
                    if~isempty(obj.InitialDir)

                        infoStruct.(f)=unique(cellfun(@(x)obj.tokenizeStartDir(x),...
                        infoStruct.(f),'UniformOutput',false),'stable');
                    end
                    infoStruct.(f)=infoStruct.(f)(startsWith(...
                    infoStruct.(f),'$'));
                    dirty=true;
                end
            end
            if dirty
                save(bInfoPath,'infoStruct','-append');
            end
        end
    end
end



