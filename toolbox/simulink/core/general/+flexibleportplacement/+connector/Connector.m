classdef Connector<handle&matlab.mixin.Heterogeneous




    properties(Abstract,SetAccess=private)
DisplayName
Identifier
    end

    methods(Sealed)



        function tf=eq(obj,other)
            tf=eq@handle(obj,other);
        end
    end
end

