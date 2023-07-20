




classdef RelationshipReportCodegenSummary<Simulink.ModelReference.common.Relationship

    methods
        function obj=RelationshipReportCodegenSummary(protectedModelCreator)

            assert(protectedModelCreator.supportsCodeGen());
            obj@Simulink.ModelReference.common.Relationship;
            obj.RelationshipName=Simulink.ModelReference.common.constructTargetRelationshipName('htmlcodegensummary',...
            protectedModelCreator.Target);

            obj.DirName='codegen';
        end


        function populate(obj,protectedModelCreator)
            rootDirBase=Simulink.ModelReference.ProtectedModel.getRTWBuildDir;
            if strcmp(protectedModelCreator.CodeInterface,'Top model')
                tgt='NONE';
            else
                tgt='RTW';
            end
            buildDir=obj.getBuildDir(tgt,protectedModelCreator.ModelName);
            relativeBuildDir=rtwprivate('rtw_relativize',buildDir,rootDirBase);

            obj.populateFromBuildDir(protectedModelCreator,relativeBuildDir);
        end

        function populateFromBuildDir(obj,protectedModelCreator,buildDir)

            htmlDirPattern=fullfile(buildDir,'html',[protectedModelCreator.ModelName,'_survey.html']);
            obj.addPartUsingFilePattern(htmlDirPattern,'html');


            buildInfoPattern=fullfile(buildDir,'buildInfo.mat');
            obj.addPartUsingFilePattern(buildInfoPattern,'');
        end

    end
    methods(Static)
        function out=getEncryptionCategory()
            out='NONE';
        end


        function out=getRelationshipYear()
            out='2014';
        end

    end
end


