
classdef HDLPow<coder.internal.mathfcngenerator.HDLLookupTable
    properties
Power
    end

    methods(Access=protected)
        function candidate_function_call=getCandidateFunctionCall(obj)
            candidate_function_call=['power( %s ,',num2str(obj.Power),')'];
        end
    end

    methods

        function obj=HDLPow(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            if(nargin>0)
                for k=1:2:nargin
                    obj.(varargin{k})=varargin{k+1};
                end
            end
            obj.CandidateFunction=@(x)power(x,obj.Power);
            obj.DefaultRange=[0,1e2];
        end
    end
end
