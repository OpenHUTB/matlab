



classdef HDLSinc<coder.internal.mathfcngenerator.HDLLookupTable
    methods

        function obj=HDLSinc(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            obj.CandidateFunction=@(x)sinc(x);
            if(nargin<1)
                obj.InputExtents=[-10,10];
                obj.Mode='UniformInterpolation';
                obj.N=1000;
            end
            obj.DefaultRange=[-10,10];
        end
    end
end
