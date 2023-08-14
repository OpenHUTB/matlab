




classdef JobDeserializerConfig<handle
    properties
        DeserializationMethod(1,1)=@MultiSim.internal.deserializeJobFromFile
    end
end