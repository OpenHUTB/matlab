classdef GcompPSGCS<handle


    properties(SetAccess=protected)
PS
GCS
    end

    methods
        function set.PS(obj,newPS)
            validateattributes(newPS,{'numeric'},{'scalar','real','nonnan'},'','PS')
            obj.PS=newPS;
        end

        function set.GCS(obj,newGCS)
            validateattributes(newGCS,{'numeric'},{'scalar','real','nonnan'},'','GCS')
            obj.GCS=newGCS;
        end
    end
end