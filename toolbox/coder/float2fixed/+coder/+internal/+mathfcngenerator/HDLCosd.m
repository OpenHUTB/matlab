


classdef HDLCosd<coder.internal.mathfcngenerator.HDLLookupTableScaled
    methods(Access=protected)
        function candidate_function_name=getCandidateFunctionName(obj)
            candidate_function_name='cosd';
        end
    end

    methods

        function obj=HDLCosd(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTableScaled(coder.internal.mathfcngenerator.HDLCos(),'ScaleInputDegree2Radian','Scale','pi/180',varargin{:});
            obj.DefaultRange=[0,360];
        end
    end
end
