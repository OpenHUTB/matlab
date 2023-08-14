




classdef RelationshipReportSharedUtils<Simulink.ModelReference.common.Relationship





    methods
        function obj=RelationshipReportSharedUtils(protectedModelCreator)

            obj@Simulink.ModelReference.common.Relationship;


            assert(protectedModelCreator.supportsCodeGen());
            obj.RelationshipName=Simulink.ModelReference.common.constructTargetRelationshipName('rtwsharedutilshtml',protectedModelCreator.Target);
            obj.DirName='codegen';

        end


        function populate(obj,protectedModelCreator)
            if protectedModelCreator.ReportV2

                return;
            end

            buildDirs=RTW.getBuildDir(protectedModelCreator.ModelName);
            sharedRptDir=fullfile(buildDirs.SharedUtilsTgtDir,'html');
            if~isfolder(sharedRptDir)



                assert(strcmp(protectedModelCreator.CodeInterface,'Top model'));
                mkdir(sharedRptDir);
                rootDirBase=Simulink.ModelReference.ProtectedModel.getRTWBuildDir;
                fid=fopen(fullfile(rootDirBase,sharedRptDir,'dummyFile'),'w');
                fclose(fid);
            end
            sharedRptDirPattern=fullfile(sharedRptDir,'*');
            obj.addPartUsingFilePattern(sharedRptDirPattern,'html');
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

