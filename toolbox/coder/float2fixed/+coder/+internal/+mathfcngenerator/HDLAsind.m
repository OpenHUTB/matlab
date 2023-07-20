



classdef HDLAsind<coder.internal.mathfcngenerator.HDLLookupTableScaled
    methods(Access=protected)
        function candidate_function_name=getCandidateFunctionName(obj)
            candidate_function_name='asind';
        end
    end
    methods

        function obj=HDLAsind(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTableScaled(coder.internal.mathfcngenerator.HDLAsin(),varargin{:});
            obj.DefaultRange=[-1,1];
        end
    end

    methods(Access=public)

        function[ValidBool,ErrorStr]=InputRangeValidate(obj)
            [ValidBool,ErrorStr]=InputRangeValidate@coder.internal.mathfcngenerator.HDLLookupTable(obj);
            if(~ValidBool)return;end

            ValidBool=(obj.InputExtents(1)>=-1)&&(obj.InputExtents(2)<=1);
            if(~ValidBool)
                ErrorStr=message('float2fixed:MFG:GenericDomain_Err','asind','[-1,1]').getString();
            end
        end
    end
end
