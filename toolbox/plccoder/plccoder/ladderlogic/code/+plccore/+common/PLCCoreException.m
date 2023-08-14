

classdef PLCCoreException<MException
    properties(Access=protected)
ID
MSG
    end
    methods
        function obj=PLCCoreException(id,msg)
            obj@MException(id,msg);
            obj.ID=id;
            obj.MSG=msg;
        end

        function ret=id(obj)
            ret=obj.ID;
        end

        function ret=msg(obj)
            ret=obj.MSG;
        end
    end
end


