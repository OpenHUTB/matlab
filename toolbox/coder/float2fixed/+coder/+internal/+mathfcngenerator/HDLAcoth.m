



classdef HDLAcoth<coder.internal.mathfcngenerator.HDLLookupTable
    methods

        function obj=HDLAcoth(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            obj.CandidateFunction=@(x)acoth(x);
            obj.DefaultRange=[1.1296,6];
        end


        function[ValidBool,ErrorStr]=InputRangeValidate(obj)

            [ValidBool,ErrorStr]=InputRangeValidate@coder.internal.mathfcngenerator.HDLLookupTable(obj);
            if(~ValidBool)
                return
            end
            if(obj.InputExtents(1)<1.1296&&obj.InputExtents(1)>=-1.1296)
                ValidBool=false;
                ErrorStr=message('float2fixed:MFG:GenericImag_Err','acoth',num2str(obj.InputExtents)).getString();
            end
        end
    end
end
