




classdef RelationshipMexForCodegen<Simulink.ModelReference.common.RelationshipMex

    methods
        function obj=RelationshipMexForCodegen(protectedModelCreator)

            assert(protectedModelCreator.supportsCodeGen());
            obj@Simulink.ModelReference.common.RelationshipMex(protectedModelCreator);


            obj.RelationshipName=Simulink.ModelReference.common.constructTargetRelationshipName('modelReferenceSimTargetCG',...
            protectedModelCreator.Target);

            obj.DirName='codegen';
            obj.NoRelationshipInPath=false;
        end

        function out=getPartProperties(obj,fileName)
            out=obj.PartProperties(fileName);
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

