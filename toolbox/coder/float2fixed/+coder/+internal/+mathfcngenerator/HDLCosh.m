



classdef HDLCosh<coder.internal.mathfcngenerator.HDLLookupTable
    methods

        function obj=HDLCosh(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            obj.CandidateFunction=@(x)cosh(x);
        end

        function[LUT,Gain]=GenerateShiftAndAdd_LUT(obj)
            LUTDomain=zeros(1,obj.Iterations);
            LUTDomain(1:obj.Iterations)=1./2.^(1:obj.Iterations);
            LUT=arrayfun(@(x)atanh(x),LUTDomain);





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

            LUT=obj.LUT;

            x=GAIN;y=0;z=INPUT;
            xtemp=x;ytemp=y;


            count=4;
            for idx=1:obj.Iterations;

                xtemp=bitsra(x,idx);
                ytemp=bitsra(y,idx);


                if(z<0)
                    x=x-ytemp;
                    y=y-xtemp;

                    z=z+LUT(idx);
                else
                    x=x+ytemp;
                    y=y+xtemp;

                    z=z-LUT(idx);
                end

                if(count==idx)
                    count=3*count+1;
                    if(z<0)
                        x=x-ytemp;
                        y=y-xtemp;

                        z=z+LUT(idx);
                    else
                        x=x+ytemp;
                        y=y+xtemp;

                        z=z-LUT(idx);
                    end
                end
            end

            OUTPUT=x;
        end
    end

    methods(Access=protected)
        function candidate_function_name=getCandidateFunctionName(obj)
            candidate_function_name='cosh';
        end
    end

    methods(Access=public)

        function[ValidBool,ErrorStr]=InputRangeValidate(obj)
            [ValidBool,ErrorStr]=InputRangeValidate@coder.internal.mathfcngenerator.HDLLookupTable(obj);
            if(~ValidBool)return;end
            if(strcmpi(obj.Mode,'ShiftAndAdd'))

                ValidBool=(obj.InputExtents(1)>=-1.118)&&(obj.InputExtents(2)<=1.118);
                if(~ValidBool)
                    ErrorStr=message('float2fixed:MFG:COSHShiftAndAdd').getString();
                end
            end
        end
    end
end
