










classdef BuildInfo<handle

    properties(SetAccess=protected)


        Success(1,1)logical;

        Errors=[];
    end

    methods
        function obj=BuildInfo()
            obj.Success=false;
            obj.Errors=[];
        end
    end

    methods(Hidden)
        function setSuccess(obj,val)
            obj.Success=val;
            if val
                obj.Errors=[];
            end
        end

        function setErrors(obj,val)
            obj.Errors=val;
            obj.Success=false;
        end
    end

end
