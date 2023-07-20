




classdef RelationshipConfigSet<Simulink.ModelReference.common.Relationship

    methods
        function obj=RelationshipConfigSet(~)

            obj@Simulink.ModelReference.common.Relationship;
            obj.RelationshipName='configset';
            obj.DirName='accel';
        end


        function populate(obj,protectedModelCreator)

            protectedModelConfigSet=protectedModelCreator.adjustedTopModelConfigSet;%#ok<NASGU>
            csFileName='cs.mat';
            save(csFileName,'protectedModelConfigSet');
            obj.addPartUsingFilePattern(csFileName,'');
        end
    end
    methods(Static)
        function out=getEncryptionCategory()
            out='SIM';
        end


        function out=getRelationshipYear()
            out='2014';
        end

    end
end

