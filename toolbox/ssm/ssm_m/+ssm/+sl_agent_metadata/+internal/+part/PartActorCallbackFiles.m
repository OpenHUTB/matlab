classdef PartActorCallbackFiles<ssm.sl_agent_metadata.internal.part.Part




    properties
        ModelName(1,:)char=''
        SetupFile(1,:)char=''
        CleanupFile(1,:)char=''
    end

    methods
        function obj=PartActorCallbackFiles()
            obj@ssm.sl_agent_metadata.internal.part.Part('callback')
        end

        function set.ModelName(obj,modelname)
            obj.ModelName=modelname;
        end

        function set.SetupFile(obj,setupScript)
            if isempty(setupScript)||(exist(setupScript,'file')~=2)
                return;
            end

            fullpathScript=which(setupScript);
            obj.SetupFile=fullpathScript;
        end

        function set.CleanupFile(obj,cleanupScript)
            if isempty(cleanupScript)||(exist(cleanupScript,'file')~=2)
                return
            end

            fullpathScript=which(cleanupScript);
            obj.CleanupFile=fullpathScript;
        end

        function populateFileList(obj)


            if isempty(obj.ModelName);return;end

            obj.addPartUsingFullFilePath(obj.SetupFile,obj.ModelName);
            obj.addPartUsingFullFilePath(obj.CleanupFile,obj.ModelName);
        end

        function populateInformation(obj)


            if isempty(obj.ModelName);return;end

            if~isempty(obj.SetupFile)
                [~,name,ext]=fileparts(obj.SetupFile);
                obj.InformationStruct.SetupScript.(obj.ModelName)={obj.ModelName,[name,ext]};
            end

            if~isempty(obj.CleanupFile)
                [~,name,ext]=fileparts(obj.CleanupFile);
                obj.InformationStruct.CleanupScript.(obj.ModelName)={obj.ModelName,[name,ext]};
            end
        end

    end
end
