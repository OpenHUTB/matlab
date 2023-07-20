
classdef HDLLog_base<coder.internal.mathfcngenerator.HDLLog
    properties
Base
    end

    methods(Access=protected)
        function candidate_function_call=getCandidateFunctionCall(obj)
            candidate_function_call=['log( %s )./log(',num2str(obj.Base),')'];
        end
    end

    methods

        function obj=HDLLog_base(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLog();
            if(nargin<1)
                obj.Base=10;
            end
            for k=1:2:nargin
                obj.(varargin{k})=varargin{k+1};
            end
            obj.CandidateFunction=@(x)(log(x)./log(obj.Base));
            obj.DefaultRange=[1e-1,1e2];
        end
    end

    methods(Access=public)

        function[ValidBool,ErrorStr]=InputRangeValidate(obj)
            [ValidBool,ErrorStr]=InputRangeValidate@coder.internal.mathfcngenerator.HDLLookupTable(obj);
            if(~ValidBool)return;end
            if(strcmpi(obj.Mode,'ShiftAndAdd'))

                ValidBool=(obj.InputExtents(1)>=1);
                if(~ValidBool)
                    ErrorStr=message('float2fixed:MFG:GenericDomain_Err','LOG_BASE in ShiftAndAdd mode','[1,inf)').getString();
                end
                return;
            else

                ValidBool=(obj.InputExtents(1)>0);
                ErrorStr=message('float2fixed:MFG:GenericDomain_Err','LOG_base','(0,inf)').getString();
            end
        end
    end

end
