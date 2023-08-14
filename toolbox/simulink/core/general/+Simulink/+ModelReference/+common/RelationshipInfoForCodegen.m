




classdef RelationshipInfoForCodegen<Simulink.ModelReference.common.Relationship

    methods
        function obj=RelationshipInfoForCodegen(protectedModelCreator)

            assert(protectedModelCreator.supportsCodeGen());
            obj@Simulink.ModelReference.common.Relationship();

            obj.RelationshipName=Simulink.ModelReference.common.constructTargetRelationshipName('infoForCodeGen',...
            protectedModelCreator.Target);
            obj.DirName='codegen';
            obj.NoRelationshipInPath=false;
        end


        function populate(obj,creator)
            modelName=creator.getModelName();
            buildDirs=slprivate('getBuildDir',modelName);


            MF0File=coder.internal.modelRefUtil(modelName,'getModelRefInfoFileName',...
            creator.currentMode,...
            get_param(modelName,'SystemTargetFile'));

            obj.PartProperties(MF0File)=struct('key','platform','value',computer('arch'));
            obj.FileList{end+1}=MF0File;
            obj.SubDir{end+1}=fullfile(buildDirs.ModelRefRelativeBuildDir,'tmwinternal');
        end

        function out=getPartProperties(obj,fileName)
            out=obj.PartProperties(fileName);
        end
    end

    methods(Static)
        function out=getEncryptionCategory()
            out='RTW';
        end


        function out=getRelationshipYear()
            out='2017';
        end

    end
end

