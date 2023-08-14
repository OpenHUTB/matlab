classdef Gcomp1DBC<handle


    properties(SetAccess=protected)
OneDBC
    end

    methods
        function set.OneDBC(obj,newOneDBC)
            validateattributes(newOneDBC,{'numeric'},{'scalar','real','nonnan'},'','1DBC')
            obj.OneDBC=newOneDBC;
        end
    end
end