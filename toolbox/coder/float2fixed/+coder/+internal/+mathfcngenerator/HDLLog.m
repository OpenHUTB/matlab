




classdef HDLLog<coder.internal.mathfcngenerator.HDLLookupTable

    methods

        function obj=HDLLog(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            obj.CandidateFunction=@(x)log(x);
            if(nargin<1)
                obj.Mode='UniformInterpolation';
                obj.InputExtents=[0.1,1000];
                obj.N=1000;
            end
            obj.DefaultRange=[1e-1,1e3];
        end


        function[LUT,Gain]=GenerateShiftAndAdd_LUT(obj)
            LUTDomain=zeros(1,obj.Iterations);
            LUTDomain(1:obj.Iterations)=ones(1,obj.Iterations)+1./2.^(1:obj.Iterations);
            LUT=arrayfun(obj.CandidateFunction,LUTDomain);
            Gain=[];
        end

        function OUTPUT=doShiftAndAdd(obj,INPUT)

            t=0.0;e=1.0;k=1;

            for i=1:obj.Iterations

                u=e+bitsra(e,k);


                if(u>INPUT)
                    k=k+1;
                else

                    t=t+obj.LUT(k);
                    e=u;
                end
            end
            OUTPUT=t;
        end
    end

    methods(Access=public)

        function[ValidBool,ErrorStr]=InputRangeValidate(obj)
            ValidBool=true;
            ErrorStr='';
            [ValidBool,ErrorStr]=InputRangeValidate@coder.internal.mathfcngenerator.HDLLookupTable(obj);
            if(~ValidBool)return;end
            if(strcmpi(obj.Mode,'ShiftAndAdd'))

                ValidBool=(obj.InputExtents(1)>=1);
                if(~ValidBool)
                    ErrorStr=message('float2fixed:MFG:LogDomain_CORDIC_Err').getString();
                end
                return;
            elseif(~(obj.InputExtents(1)>0))

                ValidBool=false;
                ErrorStr=message('float2fixed:MFG:LogDomain_Err').getString();
            end
        end
    end

end
