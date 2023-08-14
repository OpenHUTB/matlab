


classdef HDLAtand<coder.internal.mathfcngenerator.HDLLookupTableScaled
    methods(Access=protected)
        function candidate_function_name=getCandidateFunctionName(obj)
            candidate_function_name='atand';
        end
    end
    methods

        function obj=HDLAtand(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTableScaled(coder.internal.mathfcngenerator.HDLAtan(),varargin{:});
            obj.DefaultRange=[-pi,pi];
        end
    end
end
