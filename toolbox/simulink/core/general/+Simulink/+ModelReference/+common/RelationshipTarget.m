




classdef RelationshipTarget<Simulink.ModelReference.common.Relationship

    methods
        function obj=RelationshipTarget(protectedModelCreator)

            assert(protectedModelCreator.supportsCodeGen());
            obj@Simulink.ModelReference.common.Relationship(protectedModelCreator);



            target=protectedModelCreator.Target;
            obj.RelationshipName=target;
            obj.DirName='codegen';
        end


        function populate(obj,protectedModelCreator)
            listOfModelsWithBuildDirInfo=protectedModelCreator.getListOfOrderedSubModels();

            topModelInHierarchy=protectedModelCreator.ModelName;
            lSystemTargetFile=get_param(topModelInHierarchy,'SystemTargetFile');
            for i=1:length(listOfModelsWithBuildDirInfo)
                [~,currentModel]=fileparts(listOfModelsWithBuildDirInfo(i).name);
                if strcmp(topModelInHierarchy,currentModel)&&...
                    strcmp(protectedModelCreator.CodeInterface,'Top model')
                    tgt='NONE';
                else
                    tgt='RTW';
                end
                obj.packageBuildDir(currentModel,tgt,protectedModelCreator,...
                lSystemTargetFile,listOfModelsWithBuildDirInfo(i).buildDir);
            end
        end
    end

    methods(Access='private')
        function packageBuildDir(obj,currentModel,tgt,protectedModelCreator,...
            lSystemTargetFile,buildDir)


            assert(any(strcmp(tgt,{'NONE','RTW'})),...
            'Unexpected target %s.',tgt);


            infoStruct=getInfoFromBinfoFile(protectedModelCreator,currentModel,tgt,lSystemTargetFile,'loadNoConfigSet');

            rootDirBase=Simulink.ModelReference.ProtectedModel.getRTWBuildDir;


            nonInstrBuildDir=obj.getBuildDirTarget(tgt,buildDir);
            buildInfoStruct=load(fullfile(nonInstrBuildDir,'buildInfo.mat'));
            nonInstrRelativeBuildDir=rtwprivate('rtw_relativize',nonInstrBuildDir,rootDirBase);


            lToolchainInfo=protectedModelCreator.ProtectedModelCompInfo.ToolchainInfo;



            templateMakefile=obj.packageCommonArtifacts...
            (currentModel,...
            tgt,...
            buildInfoStruct,...
            nonInstrRelativeBuildDir,...
            protectedModelCreator,...
            lToolchainInfo,...
            infoStruct.targetLanguage,...
            buildDir);


            if~isempty(templateMakefile)
                save(fullfile(nonInstrBuildDir,'buildInfo.mat'),'templateMakefile','-append');
            end


            lSystemTargetFile=get_param(protectedModelCreator.ModelName,...
            'SystemTargetFile');


            obj.packageCodeGenFolder...
            (currentModel,...
            tgt,...
            rootDirBase,...
            nonInstrRelativeBuildDir,...
            protectedModelCreator,...
            lSystemTargetFile,buildDir);




            isPWSEnabled=infoStruct.IsPortableWordSizesEnabled;
            pkgInstFolder=obj.shouldPackageInstrumentedFolder...
            (protectedModelCreator,...
            isPWSEnabled);

            if pkgInstFolder
                lCodeCoverageSpec=[];
                modelsWithProfiling=[];
                isExecutionProfilingEnabledInTop=false;

                modelRefsAll=[];
                protectedModelRefs=[];

                lCodeInstrInfo=coder.internal.slCreateCodeInstrBuildArgs...
                (currentModel,...
                isPWSEnabled,...
                lCodeCoverageSpec,...
                isExecutionProfilingEnabledInTop,...
                modelsWithProfiling,...
                modelRefsAll,...
                protectedModelRefs);



                if isPWSEnabled

                    lToolchainInfo=protectedModelCreator.LatchedDefaultCompInfo.ToolchainInfo;
                else

                    lToolchainInfo=protectedModelCreator.ProtectedModelCompInfo.ToolchainInfo;
                end

                instrBuildDir=fullfile(nonInstrBuildDir,lCodeInstrInfo.getInstrObjFolder);
                buildInfoStruct=load(fullfile(instrBuildDir,'buildInfo.mat'));
                instrRelativeBuildDir=rtwprivate('rtw_relativize',instrBuildDir,rootDirBase);
                templateMakefile=obj.packageCommonArtifacts...
                (currentModel,...
                tgt,...
                buildInfoStruct,...
                instrRelativeBuildDir,...
                protectedModelCreator,...
                lToolchainInfo,...
                infoStruct.targetLanguage,...
                buildDir);


                if~isempty(templateMakefile)
                    save(fullfile(instrBuildDir,'buildInfo.mat'),'templateMakefile','-append');
                end

                obj.packageInstrFolder(instrRelativeBuildDir);
            end
        end

        function out=packageCommonArtifacts(obj,currentModel,tgt,...
            buildInfoStruct,relativeBuildDir,protectedModelCreator,...
            lToolchainInfo,targetLanguage,buildDir)

            out='';
            buildInfo=buildInfoStruct.buildInfo;
            [~,lTMFProperties]=coder.make.internal.resolveToolchainOrTMF...
            (buildInfoStruct.buildOpts.BuildMethod);


            targetLibSuffixFromCs=...
            get_param(protectedModelCreator.ModelName,'TargetLibSuffix');
            libext=coder.make.internal.getStaticLibSuffix...
            (lToolchainInfo,targetLibSuffixFromCs);

            if isempty(lTMFProperties)
                templateMakefile='';
            else
                templateMakefile=lTMFProperties.TemplateMakefile;
            end
            buildInfo_patternName=fullfile(relativeBuildDir,'buildInfo.mat');


            if~protectedModelCreator.packageSourceCode()

                obj.addPartUsingFilePattern(buildInfo_patternName,relativeBuildDir);


                binariesPattern=obj.getBinariesPattern(currentModel,tgt,libext,...
                targetLanguage,lToolchainInfo);
                foundMatchingFile=false;
                for ii=1:length(binariesPattern)




                    fpattern=fullfile(relativeBuildDir,binariesPattern{ii});
                    fileList=dir(fpattern);
                    if~isempty(fileList)
                        foundMatchingFile=true;
                    end

                    obj.addPartUsingFilePattern(fpattern,relativeBuildDir);
                end

                if coder.make.internal.buildMethodIsCMake(lToolchainInfo)&&...
                    strcmp(tgt,'NONE')







                    objExt=Simulink.ModelReference.common.getObjectFileExtension(targetLanguage,lToolchainInfo);
                    cmakeObjPattern=fullfile(relativeBuildDir,'objects-*','**',['*',objExt]);
                    cmakeObjList=dir(cmakeObjPattern);
                    cmakeObjPaths=strrep({cmakeObjList.folder},[pwd,filesep],'');
                    cmakeObjFullNames=fullfile(cmakeObjPaths,{cmakeObjList.name});
                    for jj=1:numel(cmakeObjPaths)
                        foundMatchingFile=true;
                        obj.addPartUsingFilePattern(cmakeObjFullNames{jj},cmakeObjPaths{jj});
                    end
                end

                if~foundMatchingFile
                    protectedModelCreator.throwError('Simulink:protectedModel:NoLibraryFilesPresent');
                end


                obj.addCustomHeaders(buildDir,buildInfo,buildInfo_patternName);



                if coder.make.internal.buildMethodIsCMake(lToolchainInfo)
                    cmakePattern=fullfile(relativeBuildDir,'export','*.cmake');
                    obj.addPartUsingFilePattern(cmakePattern,fullfile(relativeBuildDir,'export'));
                end
            else

                obj.BuildInfo=buildInfo;
                obj.addPartsUsingBuildInfo(protectedModelCreator,buildDir,false,buildInfo_patternName);

                if~isempty(templateMakefile)


                    [~,fname,fext]=fileparts(templateMakefile);
                    dest=fullfile(relativeBuildDir,[fname,fext]);
                    if~contains(templateMakefile,matlabroot)
                        fullTMFName=which(templateMakefile);

                        assert(isfile(fullTMFName),['Cannot find ',fullTMFName,': template makefile must exist']);
                        copyfile(fullTMFName,dest);
                    end


                    obj.addPartUsingFilePattern(dest,relativeBuildDir);







                    out=[fname,fext];
                end
            end


            patternName=fullfile(relativeBuildDir,'rtw_proj.tmw');
            obj.addPartUsingFilePattern(patternName,relativeBuildDir);
        end


        function addCustomHeaders(obj,buildDir,buildInfo,buildInfo_patternName)


            [fileList,names]=obj.findMinIncludes(buildInfo);


            [~,~,otherFiles,~,~]=buildInfo.getHierarchicalFileList(fileList,names);
            obj.addNonSharedFiles(otherFiles,buildDir,false,true);


            obj.updateBuildInfo(buildInfo);
            save(buildInfo_patternName,'buildInfo','-append');
        end

        function[fileList,names]=findMinIncludes(~,buildInfo)

            warningToSuppress='RTW:buildInfo:unableToFindMinimalIncludes';
            oldWarningState=warning('off',warningToSuppress);
            [oldWarning,oldWarningID]=lastwarn;
            cWarn=onCleanup(@()warning(oldWarningState));
            cWarn2=onCleanup(@()lastwarn(oldWarning,oldWarningID));



            buildInfo.updateFilePathsAndExtensions();
            buildInfo.findIncludeFiles('minimalHeaders',true);
            [fileList,names]=buildInfo.getFullFileList('include');


            cWarn.delete;
            cWarn2.delete;
        end

        function packageInstrFolder(obj,relativeBuildDir)


            patternName=fullfile(relativeBuildDir,coder.internal.CodeInstrChecksums.getInfoFileName);
            obj.addPartUsingFilePattern(patternName,relativeBuildDir);


            patternName=fullfile(relativeBuildDir,coder.make.internal.CompileInfoFile.getInfoFileName);
            obj.addPartUsingFilePattern(patternName,relativeBuildDir);
        end

        function packageCodeGenFolder(obj,currentModel,tgt,rootDirBase,relativeBuildDir,...
            protectedModelCreator,lSystemTargetFile,buildDirs)
            if~protectedModelCreator.packageSourceCode()

                patternName=fullfile(relativeBuildDir,'*.h');
                obj.addPartUsingFilePattern(patternName,relativeBuildDir,{[currentModel,'_private.h']});
            end


            if strcmp(tgt,'RTW')
                codeInfoFileName=[currentModel,'_mr_codeInfo.mat'];
            else
                codeInfoFileName='codeInfo.mat';
            end
            patternName=fullfile(relativeBuildDir,codeInfoFileName);
            obj.addPartUsingFilePattern(patternName,relativeBuildDir);


            patternName=fullfile(relativeBuildDir,'codedescriptor.dmr');
            obj.addPartUsingFilePattern(patternName,relativeBuildDir);


            if strcmp(tgt,'NONE')
                bMatFileName='binfo.mat';
                mMatFileName='minfo.mat';
            else
                bMatFileName='binfo_mdlref.mat';
                mMatFileName='minfo_mdlref.mat';

            end
            tmwInternalRelativeDir=fullfile(buildDirs.ModelRefRelativeBuildDir,'tmwinternal');
            patternName=fullfile(tmwInternalRelativeDir,bMatFileName);

            obj.updateBInfo(patternName);
            obj.addPartUsingFilePattern(patternName,tmwInternalRelativeDir);

            patternName=fullfile(tmwInternalRelativeDir,mMatFileName);
            obj.addPartUsingFilePattern(patternName,tmwInternalRelativeDir);


            if strcmp(tgt,'NONE')&&...
                strcmp(get_param(currentModel,'AutosarCompliant'),'on')

                stubSubFolder=fullfile(relativeBuildDir,'stub');
                patternName=fullfile(stubSubFolder,'*');
                obj.addPartUsingFilePattern(patternName,stubSubFolder);


                patternName=fullfile(relativeBuildDir,'*.arxml');
                obj.addPartUsingFilePattern(patternName,relativeBuildDir);
            end
        end




        function binariesPattern=getBinariesPattern(~,...
            currentModel,tgt,libext,targetLanguage,lToolchainInfo)
            if strcmp(tgt,'RTW')



                binariesPattern={[currentModel,'_rtwlib',libext]};
            else
                [objExt,objAssemblerExt]=Simulink.ModelReference.common.getObjectFileExtension(...
                targetLanguage,lToolchainInfo);
                binariesPattern={['*',objExt]};
                if~isempty(objAssemblerExt)
                    binariesPattern{end+1}=['*',objAssemblerExt];
                end
            end
        end
    end

    methods(Static)
        function out=getEncryptionCategory()
            out='RTW';
        end


        function out=getRelationshipYear()
            out='2012';
        end

    end
end



