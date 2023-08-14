classdef BooleanHandle<handle













    properties(SetAccess=private,GetAccess=public)
        Value(1,1)logical=false;
    end

    methods
        function obj=BooleanHandle()


        end

        function c=set(obj)


            obj.Value=true;
            c=onCleanup(@()obj.reset);
        end

        function reset(obj)

            obj.Value=false;
        end

        function ret=eq(obj,other)


            ret=(obj.Value==other);
        end

        function ret=logical(obj)


            ret=obj.Value;
        end
    end
end