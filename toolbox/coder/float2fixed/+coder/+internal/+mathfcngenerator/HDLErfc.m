



classdef HDLErfc<coder.internal.mathfcngenerator.HDLLookupTable
    methods

        function obj=HDLErfc(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            obj.CandidateFunction=@(x)erfc(x);
            if(nargin<1)
                obj.InputExtents=[-2.5,2.5];
                obj.Mode='UniformInterpolation';
                obj.N=1000;
            end
            obj.DefaultRange=[-2.5,2.5];
        end
    end
end
