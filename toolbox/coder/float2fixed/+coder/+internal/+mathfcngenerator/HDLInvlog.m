
classdef HDLInvlog<coder.internal.mathfcngenerator.HDLLookupTable
    properties
Base
    end

    methods(Access=protected)
        function candidate_function_call=getCandidateFunctionCall(obj)
            candidate_function_call=[obj.getCandidateFunctionName(),'(',num2str(obj.Base),', %s)'];
        end
    end

    methods

        function obj=HDLInvlog(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            if(nargin>0)
                for k=1:2:nargin
                    obj.(varargin{k})=varargin{k+1};
                end
            end
            obj.CandidateFunction=@(x)power(obj.Base,x);
            obj.DefaultRange=[0,10];
        end

        function[LUT,Gain]=GenerateShiftAndAdd_LUT(obj)
            LUTDomain=zeros(1,obj.Iterations);
            LUTDomain(1:obj.Iterations)=ones(1,obj.Iterations)+1./2.^(1:obj.Iterations);
            LUT=arrayfun(@(x)(log(x)./log(obj.Base)),LUTDomain);
            Gain=[];
        end

        function OUTPUT=doShiftAndAdd(obj,INPUT)

            t=0.0;
            e=1.0;
            k=1;

            for i=1:obj.Iterations

                u=t+obj.LUT(k);


                if(u>INPUT)
                    k=k+1;
                else

                    t=u;
                    e=e+bitsra(e,k);
                end
            end

            OUTPUT=e;
        end
    end

    methods(Access=public)

        function[ValidBool,ErrorStr]=InputRangeValidate(obj)
            [ValidBool,ErrorStr]=InputRangeValidate@coder.internal.mathfcngenerator.HDLLookupTable(obj);
            if(~ValidBool)return;end
            if(strcmpi(obj.Mode,'ShiftAndAdd'))

                ValidBool=(obj.InputExtents(1)>=0)&&(obj.Base>1);
                if(~ValidBool)
                    ErrorStr=message('float2fixed:MFG:InvLogBase_Err').getString();
                end
            end
        end
    end

end
