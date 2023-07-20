





classdef HDLNormcdf<coder.internal.mathfcngenerator.HDLLookupTable

    properties
        Mean=0
        StandardDeviation=1;
    end
    methods

        function obj=HDLNormcdf(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            if(nargin<1)
                obj.InputExtents=[-4,4];
                obj.Mode='UniformInterpolation';
                obj.N=1000;
                obj.Mean=0;
                obj.StandardDeviation=1;
            end
            obj.CandidateFunction=@(x)normcdf(x,obj.Mean,obj.StandardDeviation);
            obj.DefaultRange=[-2.5,2.5];
        end
    end
end
