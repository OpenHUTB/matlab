classdef PartActorMetadata<ssm.sl_agent_metadata.internal.part.Part




    properties
        ModelName(1,:)char=''
        MetadataFolder(1,:)char=''
    end

    methods
        function obj=PartActorMetadata()
            obj@ssm.sl_agent_metadata.internal.part.Part('metadata')
        end

        function populateFileList(obj)
            if isempty(obj.ModelName);return;end


            patternName=fullfile(obj.MetadataFolder,'*.xml');
            obj.addPartUsingFilePattern(patternName,obj.ModelName);
        end

        function populateInformation(~)
        end

    end
end


