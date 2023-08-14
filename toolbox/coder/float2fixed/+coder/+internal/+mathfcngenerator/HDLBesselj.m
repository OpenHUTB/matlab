


classdef HDLBesselj<coder.internal.mathfcngenerator.HDLLookupTable
    properties
Order
    end

    methods(Access=protected)
        function candidate_function_call=getCandidateFunctionCall(obj)
            candidate_function_call=['besselj(',num2str(obj.Order),', %s )'];
        end
        function candidate_function_name=getCandidateFunctionName(obj)
            candidate_function_name='besselj';
        end
    end

    methods

        function obj=HDLBesselj(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            if(nargin<1)
                obj.InputExtents=[1e-3,10];
                obj.Mode='UniformInterpolation';
                obj.N=1000;
                obj.Order=1;
            end
            obj.CandidateFunction=@(x)besselj(obj.Order,x);
            obj.DefaultRange=[-10,10];
        end
        function obj=set.Order(obj,val)
            assert(~isempty(val)&&val>=0&&isnumeric(val))
            obj.Order=val;
            return
        end
    end
end
