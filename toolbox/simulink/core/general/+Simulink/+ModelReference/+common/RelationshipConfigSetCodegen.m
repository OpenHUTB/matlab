




classdef RelationshipConfigSetCodegen<Simulink.ModelReference.common.Relationship

    methods
        function obj=RelationshipConfigSetCodegen(protectedModelCreator)

            obj@Simulink.ModelReference.common.Relationship;
            obj.RelationshipName=Simulink.ModelReference.common.constructTargetRelationshipName('configset',...
            protectedModelCreator.Target);
            obj.DirName='codegen';
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
            out='RTW';
        end


        function out=getRelationshipYear()
            out='2014';
        end

    end
end

