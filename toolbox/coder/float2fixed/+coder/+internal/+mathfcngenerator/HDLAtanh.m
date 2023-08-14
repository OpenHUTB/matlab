



classdef HDLAtanh<coder.internal.mathfcngenerator.HDLLookupTable
    methods

        function obj=HDLAtanh(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            obj.CandidateFunction=@(x)atanh(x);
            obj.DefaultRange=[-1+1e-2,1-1e-2];
        end
    end

    methods(Access=public)

        function[ValidBool,ErrorStr]=InputRangeValidate(obj)
            [ValidBool,ErrorStr]=InputRangeValidate@coder.internal.mathfcngenerator.HDLLookupTable(obj);
            if(~ValidBool)return;end

            ValidBool=(obj.InputExtents(1)>-1)&&(obj.InputExtents(2)<1);
            if(~ValidBool)
                ErrorStr=message('float2fixed:MFG:GenericDomain_Err','atanh','[-1,1]').getString();
            end
        end
    end

end

