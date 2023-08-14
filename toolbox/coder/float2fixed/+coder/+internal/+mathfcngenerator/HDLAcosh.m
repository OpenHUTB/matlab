



classdef HDLAcosh<coder.internal.mathfcngenerator.HDLLookupTable
    methods

        function obj=HDLAcosh(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            obj.DefaultRange=[pi/2,3*pi/2];
            obj.CandidateFunction=@(x)acosh(x);
        end


        function[ValidBool,ErrorStr]=InputRangeValidate(obj)

            [ValidBool,ErrorStr]=InputRangeValidate@coder.internal.mathfcngenerator.HDLLookupTable(obj);
            if(~ValidBool)
                return
            end
            if(obj.InputExtents(1)<1&&obj.InputExtents(1)>=-1)
                ValidBool=false;
                ErrorStr=message('float2fixed:MFG:Acosh_Err',num2str(obj.InputExtents)).getString();
            end
        end

    end
end
