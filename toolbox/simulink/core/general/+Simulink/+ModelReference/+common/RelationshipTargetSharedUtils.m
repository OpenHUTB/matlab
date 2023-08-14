




classdef RelationshipTargetSharedUtils<Simulink.ModelReference.common.Relationship

    properties
ExistingSharedCode
    end

    methods
        function obj=RelationshipTargetSharedUtils(protectedModelCreator)

            assert(protectedModelCreator.supportsCodeGen());
            obj@Simulink.ModelReference.common.Relationship;
            target=protectedModelCreator.Target;
            obj.ExistingSharedCode=protectedModelCreator.ExistingSharedCode;
            obj.RelationshipName=Simulink.ModelReference.common.constructTargetRelationshipName('rtwsharedutils',target);
            obj.DirName='codegen';
        end


        function populate(obj,protectedModelCreator)
            topOfModelInHierarchy=protectedModelCreator.ModelName;
            buildDirs=RTW.getBuildDir(topOfModelInHierarchy);
            sharedUtilsPattern=fullfile(buildDirs.SharedUtilsTgtDir,'*');


            if~isempty(obj.ExistingSharedCode)
                lExcludeFiles=coder.internal.xrel.getExistingSharedCode(obj.ExistingSharedCode);
            else
                lExcludeFiles={};
            end



            if~isempty(lExcludeFiles)
                lExcludeFiles=[lExcludeFiles,'shared_file.dmr'];
            end




            compilerDependencyFiles=dir(fullfile(buildDirs.SharedUtilsTgtDir,'*.dep'));
            compilerDependencyFiles={compilerDependencyFiles.name};
            lExcludeFiles=[lExcludeFiles,compilerDependencyFiles];


            obj.packageSharedUtilsDir(protectedModelCreator,sharedUtilsPattern,'',lExcludeFiles);






            if strcmp(protectedModelCreator.CodeInterface,'Top model')
                tgt='NONE';
            else
                tgt='RTW';
            end
            lSystemTargetFile=get_param(topOfModelInHierarchy,'SystemTargetFile');
            infoStruct=coder.internal.infoMATPostBuild('loadNoConfigSet','binfo',...
            topOfModelInHierarchy,tgt,lSystemTargetFile);
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
                (protectedModelCreator.ModelName,...
                isPWSEnabled,...
                lCodeCoverageSpec,...
                isExecutionProfilingEnabledInTop,...
                modelsWithProfiling,...
                modelRefsAll,...
                protectedModelRefs);
                instrBuildDir=fullfile(buildDirs.SharedUtilsTgtDir,lCodeInstrInfo.getInstrObjFolder);
                instrSharedUtilsPattern=fullfile(instrBuildDir,'*');
                obj.packageSharedUtilsDir(protectedModelCreator,...
                instrSharedUtilsPattern,lCodeInstrInfo.getInstrObjFolder);
            end
        end
    end

    methods(Access=private)
        function packageSharedUtilsDir(obj,protectedModelCreator,sharedUtilsPattern,subDir,varargin)
            if protectedModelCreator.packageSourceCode()
                obj.addPartUsingFilePatternNoLibs(sharedUtilsPattern,subDir,varargin{:});
            else
                obj.addPartUsingFilePattern(sharedUtilsPattern,subDir,varargin{:});
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

