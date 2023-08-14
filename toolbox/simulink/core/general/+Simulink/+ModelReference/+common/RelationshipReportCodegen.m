




classdef RelationshipReportCodegen<Simulink.ModelReference.common.Relationship

    methods
        function obj=RelationshipReportCodegen(protectedModelCreator)

            assert(protectedModelCreator.supportsCodeGen());
            obj@Simulink.ModelReference.common.Relationship;
            obj.RelationshipName=Simulink.ModelReference.common.constructTargetRelationshipName('htmlcodegen',...
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



            htmlDirPattern=fullfile(relativeBuildDir,'html','*');
            traceabilityDB={'define.js'};
            obj.addPartUsingFilePattern(htmlDirPattern,'html',traceabilityDB);


            buildInfoPattern=fullfile(relativeBuildDir,'buildInfo.mat');
            obj.addPartUsingFilePattern(buildInfoPattern,'');


            subdir=fullfile('html','css');
            cssDirPattern=fullfile(relativeBuildDir,subdir,'*');
            obj.addPartUsingFilePattern(cssDirPattern,subdir);
            subdir=fullfile('html','js');
            jsDirPattern=fullfile(relativeBuildDir,subdir,'*');
            obj.addPartUsingFilePattern(jsDirPattern,subdir);
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

