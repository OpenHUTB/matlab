




classdef RelationshipReportSummary<Simulink.ModelReference.common.Relationship

    methods
        function obj=RelationshipReportSummary(~)

            obj@Simulink.ModelReference.common.Relationship();
            obj.RelationshipName='htmlsummary';
            obj.DirName='report';
        end


        function populate(obj,protectedModelCreator)
            buildDirs=RTW.getBuildDir(protectedModelCreator.ModelName);

            buildDir=buildDirs.ModelRefRelativeSimDir;
            obj.populateFromBuildDir(protectedModelCreator,buildDir);
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

