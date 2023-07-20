




classdef RelationshipAccelForCodegen<Simulink.ModelReference.common.RelationshipAccel

    methods
        function obj=RelationshipAccelForCodegen(protectedModelCreator)

            assert(protectedModelCreator.supportsCodeGen());
            obj@Simulink.ModelReference.common.RelationshipAccel(protectedModelCreator);


            obj.RelationshipName=Simulink.ModelReference.common.constructTargetRelationshipName('simCG',...
            protectedModelCreator.Target);

            obj.DirName='codegen';
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


