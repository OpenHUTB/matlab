



classdef HDLRsqrt<coder.internal.mathfcngenerator.HDLLookupTable
    methods

        function obj=HDLRsqrt(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            obj.CandidateFunction=@(x)1/sqrt(x);
            if(nargin<1)
                obj.InputExtents=[1e-2,1e2];
                obj.Mode='UniformInterpolation';
                obj.N=1000;
            end
            obj.DefaultRange=[1e-2,1e2];
        end
    end

    methods(Access=public)

        function[ValidBool,ErrorStr]=InputRangeValidate(obj)
            [ValidBool,ErrorStr]=InputRangeValidate@coder.internal.mathfcngenerator.HDLLookupTable(obj);
            if(~ValidBool)
                return;
            end

            ValidBool=(obj.InputExtents(1)>0);
            if(~ValidBool)
                ErrorStr=message('float2fixed:MFG:GenericDomain_Err','Reciprocal sqrt','(0,inf)').getString();
                return;
            end
        end
    end
end
