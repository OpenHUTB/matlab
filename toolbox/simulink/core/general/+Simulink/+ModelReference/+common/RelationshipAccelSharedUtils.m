




classdef RelationshipAccelSharedUtils<Simulink.ModelReference.common.Relationship

    methods
        function obj=RelationshipAccelSharedUtils(~)

            obj@Simulink.ModelReference.common.Relationship;
            obj.RelationshipName='simsharedutils';
            obj.DirName='accel';

        end


        function populate(obj,creator)
            buildDirs=RTW.getBuildDir(creator.getModelName());


            buildInfoPattern=fullfile(buildDirs.SharedUtilsSimDir,'buildInfo.mat');
            obj.updateBuildInfo(buildInfoPattern);

            sharedUtilsPattern=fullfile(buildDirs.SharedUtilsSimDir,'*');

            if creator.packageSourceCode()
                obj.addPartUsingFilePatternNoLibs(sharedUtilsPattern,'');
            else
                obj.addPartUsingFilePattern(sharedUtilsPattern,'');
            end

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

