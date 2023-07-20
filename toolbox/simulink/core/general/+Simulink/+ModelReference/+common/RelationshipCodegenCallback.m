




classdef RelationshipCodegenCallback<Simulink.ModelReference.common.Relationship

    methods
        function obj=RelationshipCodegenCallback(~)


            obj@Simulink.ModelReference.common.Relationship;
            obj.RelationshipName='codegenCallback';
            obj.DirName='callbacks';
        end


        function populate(obj,creator)
            files=creator.CallbackMgr.getCallbackFileListForFunctionality('CODEGEN');
            for i=1:length(files)
                obj.addPartUsingFilePattern(files{i},'');
            end
        end
    end
    methods(Static)
        function out=getEncryptionCategory()
            out='NONE';
        end


        function out=getRelationshipYear()
            out='2015';
        end

    end
end

