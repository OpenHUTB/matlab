




classdef HDLExp<coder.internal.mathfcngenerator.HDLLookupTable

    methods

        function obj=HDLExp(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            obj.CandidateFunction=@(x)exp(x);
            obj.Mode='ShiftAndAdd';
            obj.DefaultRange=[0,10];
        end

        function[LUT,Gain]=GenerateShiftAndAdd_LUT(obj)
            LUTDomain=zeros(1,obj.Iterations);
            LUTDomain(1:obj.Iterations)=ones(1,obj.Iterations)+1./2.^(1:obj.Iterations);
            LUT=arrayfun(@(x)log(x),LUTDomain);
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

                ValidBool=(obj.InputExtents(1)>=0);
                if(~ValidBool)
                    ErrorStr=message('float2fixed:MFG:Exp_Err').getString();
                end
            end
        end
    end

end
