

































classdef CallbackInfo<Simulink.ModelReference.ProtectedModel.CallbackInfoImpl
    methods
        function obj=CallbackInfo(modelName,subModels,event,functionality,codeInterface,currentTarget)
            obj@Simulink.ModelReference.ProtectedModel.CallbackInfoImpl(modelName,...
            subModels,...
            event,...
            functionality,...
            codeInterface,...
            currentTarget);
        end
    end
end


