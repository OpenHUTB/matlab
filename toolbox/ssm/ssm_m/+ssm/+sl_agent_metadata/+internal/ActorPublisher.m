classdef ActorPublisher<handle




    properties(Access=public)
        ModelName(1,:)char{ssm.sl_agent_metadata.internal.utils.validateActorModelName}
        PackageType(1,:)char{validateRelationTarget}='ActorNormal'
        SetupScript(1,:)char=''
        CleanupScript(1,:)char=''
        OutputFilePackage(1,:)char=''
        OutputFileBehavior(1,:)char=''
        DataFiles(1,:)string{validateFileExistence}=""
    end

    properties(Hidden=true)
        dependencyList={};
    end

    properties(Access=private)

        ZCMetadataFileName(1,:)char=''
    end

    methods
        function obj=ActorPublisher(ModelName)
            [~,mdlName,~]=fileparts(ModelName);
            obj.ModelName=mdlName;
        end

        function delete(obj)

            if~isempty(obj.ZCMetadataFileName)&&exist(obj.ZCMetadataFileName,'file')==2
                delete(obj.ZCMetadataFileName)
            end
        end

        function genMetadata(obj)
            fprintf('%s\n',DAStudio.message('ssm:actorMetadata:GenerateMetadataStart',obj.ModelName));


            metaGenerator=ssm.sl_agent_metadata.internal.MetadataGenerator(obj.ModelName);
            try
                metaGenerator.genMetadata();
            catch Err
                warnMsg=message('ssm:actorMetadata:UnableToGenerateZCMetadata',Err.identifier);
                warning(warnMsg);
                return;
            end
            fprintf('%s\n',DAStudio.message('ssm:actorMetadata:GenerateMetadataFinish',obj.ModelName));


            obj.ZCMetadataFileName=metaGenerator.MetaFileName;
        end

        function genBehaviorProto(obj)
            fprintf('%s\n',DAStudio.message('ssm:actorMetadata:GenerateBehaviorProtoStart',obj.ModelName));


            behaviorGenerator=ssm.sl_agent_metadata.internal.BehaviorGenerator(obj.ModelName);



            [~,opkgName,opkgExt]=fileparts(obj.OutputFilePackage);
            behaviorGenerator.ExtraInformation.artifact_location=string([opkgName,opkgExt]);




            behaviorGenerator.ExtraInformation.simulation_mode=0;
            if strcmpi(obj.PackageType,'actornormal')
                behaviorGenerator.ExtraInformation.simulation_mode=1;
            elseif strcmpi(obj.PackageType,'actorrapid')
                behaviorGenerator.ExtraInformation.simulation_mode=2;
            end

            if~isempty(obj.OutputFileBehavior)
                behaviorGenerator.ProtoFileName=obj.OutputFileBehavior;
            end

            behaviorGenerator.genBehaviorProto();

            fprintf('%s\n',DAStudio.message('ssm:actorMetadata:GenerateBehaviorProtoFinish',obj.ModelName));
        end

        function getDependencies(obj)
            fprintf('%s\n',DAStudio.message('ssm:actorMetadata:ActorDependencyAnalysisStart',obj.ModelName));

            [obj.dependencyList,missingFiles,~]=dependencies.fileDependencyAnalysis(obj.ModelName);

            if~isempty(missingFiles)
                warnMsg=message('ssm:actorMetadata:DependencyFileMissing',strjoin(missingFiles,', '));
                warning(warnMsg);
            end

            fprintf('%s\n',DAStudio.message('ssm:actorMetadata:ActorDependencyAnalysisFinish',obj.ModelName));
        end

        function generateArtifacts(obj)
            fprintf('%s\n',DAStudio.message('ssm:actorMetadata:ActorCodeGenerationStart',obj.ModelName));

            if strcmpi(obj.PackageType,'actorrapid')
                pathOrig=path;
                cleanupPath=onCleanup(@()path(pathOrig));
                ssm.generateTarget(pwd,pwd,obj.ModelName);
            end
            fprintf('%s\n',DAStudio.message('ssm:actorMetadata:ActorCodeGenerationFinish',obj.ModelName));
        end

        function createPackage(obj)
            fprintf('%s\n',DAStudio.message('ssm:actorMetadata:GenerateActorPackageStart',obj.ModelName));


            model=char(obj.ModelName);
            [~,isresoved]=sls_resolvename(model);
            if isresoved&&(~bdIsLoaded(model))
                load_system(model);
                objCleanupModel=onCleanup(@()close_system(model,0));
            end


            ptActor=ssm.sl_agent_metadata.internal.part.PartActor();
            ptActor.ModelName=model;
            ptActor.ActorType=obj.PackageType;


            ptMetadata=ssm.sl_agent_metadata.internal.part.PartActorMetadata();
            ptMetadata.ModelName=model;
            ptMetadata.MetadataFolder=pwd;
            ptActor.addSubPart(ptMetadata);


            ptDependency=ssm.sl_agent_metadata.internal.part.PartActorDependency();
            ptDependency.ModelName=model;
            ptDependency.DependencyList=obj.dependencyList;
            ptDependency.DataFileList=obj.DataFiles;
            ptActor.addSubPart(ptDependency);


            ptCallback=ssm.sl_agent_metadata.internal.part.PartActorCallbackFiles();
            ptCallback.ModelName=model;
            ptCallback.SetupFile=obj.SetupScript;
            ptCallback.CleanupFile=obj.CleanupScript;
            ptActor.addSubPart(ptCallback);


            ptCodegen=ssm.sl_agent_metadata.internal.part.PartActorCodegen();
            ptCodegen.ModelName=model;
            ptCodegen.BuildFolder=pwd;
            ptActor.addSubPart(ptCodegen);


            ptPackage=ssm.sl_agent_metadata.internal.part.PartPackage();
            ptPackage.addSubPart(ptActor);
            ptPackage.PackageType='actor';


            ptPackage.populateAllFileList();
            ptPackage.populateAllInformation();


            pkgCreator=ssm.sl_agent_metadata.internal.PackageCreator;
            pkgCreator.TargetPart=ptPackage;
            pkgCreator.ProjectFolder=pwd;
            pkgCreator.ExportFilePath=obj.OutputFilePackage;
            pkgCreator.generateProject();

            fprintf('%s\n',DAStudio.message('ssm:actorMetadata:GenerateActorPackageFinish',obj.ModelName));
        end

    end
end

function validateFileExistence(dataFiles)
    if isempty(dataFiles);return;end
    invalidFiles={};
    for idx=numel(dataFiles):-1:1
        if dataFiles(idx)=="";continue;end
        isExist=exist(dataFiles(idx),'file');
        if isExist~=2
            invalidFiles{idx}=dataFiles(idx);
        end
    end


    invalidFiles=invalidFiles(~cellfun('isempty',invalidFiles));

    if numel(invalidFiles)>0
        errMsg=message('ssm:actorMetadata:ActorDataFileNotExist',strjoin(invalidFiles,','));
        error(errMsg);
    end
end

function validateRelationTarget(RelationTarget)
    supportedTargets={'ActorNormal','ActorRapid','SystemObject'};

    if~any(strcmpi(supportedTargets,RelationTarget))
        errMsg=message('ssm:actorMetadata:InvalidPackageType',strjoin(supportedTargets,', '));
        error(errMsg);
    end
end


