



classdef HDLSqrt<coder.internal.mathfcngenerator.HDLLookupTable
    methods

        function obj=HDLSqrt(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            obj.CandidateFunction=@(x)sqrt(x);
            if(nargin<1)
                obj.InputExtents=[1e-2,1e3];
                obj.Mode='UniformInterpolation';
                obj.N=1000;
            end
            obj.DefaultRange=[1e-2,1e3];
        end
    end

    methods(Access=public)

        function[LUT,Gain]=GenerateShiftAndAdd_LUT(obj)
            LUT=[];





            m3=prod(sqrt(1-2.^(-2*(1:(obj.Iterations)))));
            i=4;
            while i<=obj.Iterations
                m3=m3*sqrt(1-2^(-2*i));
                i=3*i+1;
            end
            Gain=1/m3;
        end

        function OUTPUT=doShiftAndAdd(obj,INPUT)

            GAIN=obj.Gain;


            x=INPUT+0.25;y=INPUT-0.25;


            count=4;
            for idx=1:obj.Iterations

                xtemp=bitsra(x,idx);
                ytemp=bitsra(y,idx);
                if y<0
                    x=x+ytemp;
                    y=y+xtemp;
                else
                    x=x-ytemp;
                    y=y-xtemp;
                end
                if count==idx

                    count=3*count+1;
                    if y<0
                        x=x+ytemp;
                        y=y+xtemp;
                    else
                        x=x-ytemp;
                        y=y-xtemp;
                    end
                end
            end

            OUTPUT=x*GAIN;
        end
    end

    methods(Access=public)

        function[ValidBool,ErrorStr]=InputRangeValidate(obj)
            [ValidBool,ErrorStr]=InputRangeValidate@coder.internal.mathfcngenerator.HDLLookupTable(obj);
            if(~ValidBool)
                return;
            end
            if(strcmpi(obj.Mode,'ShiftAndAdd'))

                ValidBool=(obj.InputExtents(1)>0)&&(obj.InputExtents(2)<=2);
                if(~ValidBool)
                    ErrorStr=message('float2fixed:MFG:Sqrt_CORDIC_Err').getString();
                end
            else

                ValidBool=(obj.InputExtents(1)>=0);
                if(~ValidBool)
                    ErrorStr=message('float2fixed:MFG:Sqrt_Err').getString();
                    return;
                end
            end

        end
    end

end
