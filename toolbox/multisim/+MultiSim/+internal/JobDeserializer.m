





classdef JobDeserializer<handle
    properties(Constant)
        Config(1,1)=MultiSim.internal.JobDeserializerConfig
    end

    methods
        function job=deserialize(obj,fileName)
            job=obj.Config.DeserializationMethod(fileName);
        end
    end
end