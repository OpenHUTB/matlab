classdef cleanupFunction<handle






%#codegen

    properties(SetAccess='immutable',GetAccess='public',Transient)
        task(1,1)function_handle=@nop;
    end

    properties(GetAccess=public,SetAccess=private)
        enable=true;
    end

    methods
        function obj=cleanupFunction(functionHandle)





            narginchk(1,1);
            obj.task=functionHandle;
        end
    end

    methods(Hidden=true)
        function delete(obj)





            if obj.enable
                obj.task();
            end
        end
    end

    methods(Access=public)

        function disableCleanup(obj)
            obj.enable=false;
        end
    end

end

function nop
end
