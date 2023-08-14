




classdef RelationshipReport<Simulink.ModelReference.common.Relationship

    methods
        function obj=RelationshipReport(~)

            obj@Simulink.ModelReference.common.Relationship();
            obj.RelationshipName='html';
            obj.DirName='report';
        end


        function populate(obj,protectedModelCreator)
            buildDirs=RTW.getBuildDir(protectedModelCreator.ModelName);

            buildDir=buildDirs.ModelRefRelativeSimDir;
            obj.populateFromBuildDir(protectedModelCreator,buildDir);
        end

        function populateFromBuildDir(obj,protectedModelCreator,buildDir)

            htmlDirPattern=fullfile(buildDir,'html','*');
            obj.addPartUsingFilePattern(htmlDirPattern,'html',{[protectedModelCreator.ModelName,'_survey.html']});
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

