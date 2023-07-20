classdef(Abstract)CostEstimate<handle




    properties(Abstract,SetAccess=private)
        Design(1,:)char
        ID(1,1)string
    end

    properties(Hidden,SetAccess=protected)
        Diagnostics struct
    end

end


