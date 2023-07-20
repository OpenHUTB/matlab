






classdef RelationshipMex<Simulink.ModelReference.common.Relationship

    methods
        function obj=RelationshipMex(~)

            obj@Simulink.ModelReference.common.Relationship;
            obj.RelationshipName='modelReferenceSimTarget';
            obj.SubDir={};
            obj.DirName='binaries';
        end


        function populate(obj,creator)
            modelName=creator.getModelName();

            isProtected=true;


            mexBaseFile=[modelName,...
            coder.internal.modelRefUtil(modelName,'getBinExt',isProtected)];
            clear(mexBaseFile);


            mexFile=coder.internal.modelRefUtil(modelName,'getSimTargetName',isProtected);
            obj.PartProperties(mexFile)=struct('key','platform','value',computer('arch'));
            obj.FileList={mexFile};
            obj.SubDir{end+1}='';


            buildDirs=RTW.getBuildDir(modelName);
            fileName=[modelName,coder.internal.modelreference.MdlInitializeSizesWriter.JacobianDataFileSuffix];
            fullPath=fullfile(buildDirs.ModelRefRelativeSimDir,fileName);
            if~isempty(dir(fullPath))
                obj.PartProperties(fullPath)=struct('key','platform','value',computer('arch'));
                obj.FileList{end+1}=fullPath;
                obj.SubDir{end+1}=buildDirs.ModelRefRelativeSimDir;
            end


            lSystemTargetFile=get_param(modelName,'SystemTargetFile');


            MF0File=coder.internal.modelRefUtil...
            (modelName,'getModelRefInfoFileName','SIM',lSystemTargetFile);
            obj.PartProperties(MF0File)=struct('key','platform','value',computer('arch'));
            obj.FileList{end+1}=MF0File;
            obj.SubDir{end+1}=fullfile(buildDirs.ModelRefRelativeSimDir,'tmwinternal');


            if slfeature('NonInlineSFcnsInProtection')
                parser=mf.zero.io.XmlParser;
                parsedContents=parser.parseFile(MF0File);
                paramInfo=parsedContents.sFcnInfo;
                for i=1:paramInfo.Size
                    if paramInfo(i).willBeDynamicallyLoaded
                        mexFileName=[paramInfo(i).name,'.',mexext];
                        mexFile=which(mexFileName);
                        obj.PartProperties(mexFile)=struct('key','platform','value',computer('arch'));
                        obj.FileList{end+1}=mexFile;
                        obj.SubDir{end+1}='';

                        protectedModelFile=slInternal('getPackageNameForModel',modelName);
                        fprintf('\n');
                        MSLDiagnostic('Simulink:protectedModel:protectedModeIncludesNonInlineSFcMexFile',...
                        protectedModelFile,mexFile).reportAsInfo;

                    end
                end
            end


            tempdir=Simulink.fileGenControl('get','CacheFolder');
            if exist(fullfile(tempdir,'slprj','_fmu'),'dir')
                files=dir(fullfile(tempdir,'slprj','_fmu','**','*.*'));
                files=files(~[files.isdir]);
                for i=1:length(files)
                    fullPath=strrep(fullfile(files(i).folder,files(i).name),[tempdir,filesep],'');
                    obj.FileList{end+1}=fullPath;
                    obj.PartProperties(fullPath)=struct('key','platform','value',computer('arch'));
                    [subDir,~,~]=fileparts(fullPath);
                    obj.SubDir{end+1}=subDir;
                end
            end


        end

        function out=getPartProperties(obj,fileName)
            out=obj.PartProperties(fileName);
        end
    end
    methods(Static)
        function out=getEncryptionCategory()
            out='SIM';
        end


        function out=getRelationshipYear()
            out='2012';
        end



    end
end

