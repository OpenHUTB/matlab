classdef(Sealed)MATLABFunctionReport<handle













    properties(SetAccess=immutable)
        Functions coder.Function=coder.Function.empty()
    end

    methods
        function obj=MATLABFunctionReport(fcns)
            if nargin==0
                return
            end
            narginchk(1,1);
            obj.Functions=fcns;
        end
    end
end