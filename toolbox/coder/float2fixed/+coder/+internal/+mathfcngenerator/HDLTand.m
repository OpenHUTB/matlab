


classdef HDLTand<coder.internal.mathfcngenerator.HDLLookupTableScaled
    methods(Access=protected)
        function candidate_function_name=getCandidateFunctionName(obj)
            candidate_function_name='tand';
        end
    end

    methods

        function obj=HDLTand(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTableScaled(coder.internal.mathfcngenerator.HDLTan(),'ScaleInputDegree2Radian','Scale','pi/180',varargin{:});
            obj.DefaultRange=[0,89.99];
        end
    end

    methods(Access=public)

        function[ValidBool,ErrorStr]=InputRangeValidate(obj)
            InputRangeValidate@coder.internal.mathfcngenerator.HDLLookupTable(obj);

            [ValidBool,ErrorStr]=InputRangeValidate@coder.internal.mathfcngenerator.HDLLookupTable(obj);
            if(~ValidBool)
                return;
            end


            ValidBool1=(floor((obj.InputExtents(1)-(90))/180)==floor((obj.InputExtents(2)-(90))/180));

            ValidBool=ValidBool1&&((~(mod(obj.InputExtents(1)*(90),2)==1))&&(~(mod(obj.InputExtents(2)*(90),2)==1)));
            if(~ValidBool)
                ErrorStr='Invalid Input:Not a valid domain for selected function tand domain cannot contain (+/-)Odd*90';
            end
        end
    end
end
