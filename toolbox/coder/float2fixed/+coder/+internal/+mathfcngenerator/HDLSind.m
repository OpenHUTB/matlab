


classdef HDLSind<coder.internal.mathfcngenerator.HDLLookupTableScaled
    methods(Access=protected)
        function candidate_function_name=getCandidateFunctionName(obj)
            candidate_function_name='sind';
        end
    end

    methods

        function obj=HDLSind(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTableScaled(coder.internal.mathfcngenerator.HDLSin(),'ScaleInputDegree2Radian','Scale','pi/180',varargin{:});
            obj.DefaultRange=[0,360];
        end
    end
end
