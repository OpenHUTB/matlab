


classdef Flat<coder.internal.mathfcngenerator.FlatLookupTable
    methods
        function obj=Flat(varargin)
            obj=obj@coder.internal.mathfcngenerator.FlatLookupTable(varargin{:});
            if(isempty(obj.CandidateFunction))
                obj.CandidateFunction=str2func(obj.Function);
            end
        end
    end
end
