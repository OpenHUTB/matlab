

classdef ParameterManagerModelRefCallback<Simulink.ModelReference.NormalModeCallback
    methods(Access='public')
        function obj=ParameterManagerModelRefCallback
            obj=obj@Simulink.ModelReference.NormalModeCallback;
        end

        function setParameterManager(obj,mgr)
            obj.ParameterManager=mgr;
        end

        function runCallback(obj,blockpath,referencedModelName)


            if~any(strcmp(obj.ParameterManager.getUniqueNormalModeModels,referencedModelName))
                prepareLocalModelParameters(obj.ParameterManager,referencedModelName,blockpath);
            end
        end
    end

    properties(SetAccess='private',GetAccess='public')
        ParameterManager=[];
    end
end
