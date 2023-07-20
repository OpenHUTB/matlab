




classdef RelationshipSimCallback<Simulink.ModelReference.common.Relationship

    methods
        function obj=RelationshipSimCallback(~)


            obj@Simulink.ModelReference.common.Relationship;
            obj.RelationshipName='simCallback';
            obj.DirName='callbacks';
        end


        function populate(obj,creator)
            files=creator.CallbackMgr.getCallbackFileListForFunctionality('SIM');
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

