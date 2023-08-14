classdef PartActor<ssm.sl_agent_metadata.internal.part.Part




    properties
        ModelName(1,:)char=''
        ActorType(1,:)char=''
    end
    methods
        function obj=PartActor()
            obj@ssm.sl_agent_metadata.internal.part.Part('actor')
        end

        function populateFileList(~)
        end

        function populateInformation(obj)

            obj.InformationStruct.Model=string(obj.ModelName);
            obj.InformationStruct.Type=string(obj.ActorType);
            obj.InformationStruct.Platform=string(computer);
        end

    end
end
