

classdef SimulinkFunctionTriggerPortProperty
    properties(Access=private)
        fFcnName;
        fVariant=true;
        fVisibility;
    end
    methods

        function obj=SimulinkFunctionTriggerPortProperty(blkHdl)
            assert(isa(get_param(blkHdl,'Object'),"Simulink.TriggerPort"));
            obj.fFcnName=get_param(blkHdl,'FunctionName');
            obj.fVariant=strcmpi(get_param(blkHdl,'Variant'),'on');
            obj.fVisibility=get_param(blkHdl,'FunctionVisibility');
        end


        function obj=getFcnName(aObj)
            obj=aObj.fFcnName;
        end

        function obj=isVaraintOn(aObj)
            obj=aObj.fVariant;
        end

        function obj=getVisibility(aObj)
            obj=aObj.fVisibility;
        end
    end
end

