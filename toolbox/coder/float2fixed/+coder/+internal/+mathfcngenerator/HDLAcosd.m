



classdef HDLAcosd<coder.internal.mathfcngenerator.HDLLookupTableScaled
    methods(Access=protected)
        function candidate_function_name=getCandidateFunctionName(obj)
            candidate_function_name='acosd';
        end
    end

    methods

        function obj=HDLAcosd(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTableScaled(coder.internal.mathfcngenerator.HDLAcos(),varargin{:});
            obj.DefaultRange=[-1,1];
        end
    end

    methods(Access=public)

        function[ValidBool,ErrorStr]=InputRangeValidate(obj)
            [ValidBool,ErrorStr]=InputRangeValidate@coder.internal.mathfcngenerator.HDLLookupTable(obj);
            if(~ValidBool)return;end

            ValidBool=(obj.InputExtents(1)>=-1)&&(obj.InputExtents(2)<=1);
            if(~ValidBool)
                ErrorStr=message('float2fixed:MFG:Acosd_Err').getString();
            end

        end
    end
end

