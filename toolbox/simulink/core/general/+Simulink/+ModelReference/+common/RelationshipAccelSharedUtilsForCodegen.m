




classdef RelationshipAccelSharedUtilsForCodegen<Simulink.ModelReference.common.RelationshipAccelSharedUtils

    methods
        function obj=RelationshipAccelSharedUtilsForCodegen(protectedModelCreator)

            assert(protectedModelCreator.supportsCodeGen());
            obj@Simulink.ModelReference.common.RelationshipAccelSharedUtils(protectedModelCreator);
            obj.RelationshipName=Simulink.ModelReference.common.constructTargetRelationshipName('simsharedutilsCG',...
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

