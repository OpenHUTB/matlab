



classdef HDLAsinh<coder.internal.mathfcngenerator.HDLLookupTable
    methods

        function obj=HDLAsinh(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            obj.CandidateFunction=@(x)asinh(x);
            obj.DefaultRange=[-pi,pi];
        end
    end
end
