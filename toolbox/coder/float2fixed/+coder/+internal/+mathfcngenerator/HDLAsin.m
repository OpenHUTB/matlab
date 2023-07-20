



classdef HDLAsin<coder.internal.mathfcngenerator.HDLLookupTable
    methods

        function obj=HDLAsin(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            obj.CandidateFunction=@(x)asin(x);
            if(nargin<1)
                obj.InputExtents=[-1,1];
                obj.DefaultRange=[-1,1];
                obj.Mode='UniformInterpolation';
                obj.N=1000;
            end

        end
        function[LUT,Gain]=GenerateShiftAndAdd_LUT(obj)
            LUTDomain=zeros(1,obj.Iterations+1);
            LUTDomain(obj.Iterations+1)=0;
            LUTDomain(1:obj.Iterations)=1./2.^(0:(obj.Iterations-1));
            LUT=arrayfun(@(x)atan(x),LUTDomain);





            m=prod(sqrt(1+2.^(-2*(0:(obj.Iterations-1)))));
            Gain=1/m;
        end
        function OUTPUT=doShiftAndAdd(obj,INPUT)





            GAIN=obj.Gain;


            LUT=obj.LUT;


            x=GAIN;y=0;z=0;
            xtemp=x;ytemp=y;


            for idx=1:obj.Iterations;

                if y>INPUT
                    x=x+ytemp;
                    y=y-xtemp;
                    z=z-LUT(idx);
                else
                    x=x-ytemp;
                    y=y+xtemp;
                    z=z+LUT(idx);
                end
                xtemp=bitsra(x,idx);
                ytemp=bitsra(y,idx);
            end

            OUTPUT=z;
        end
    end
    methods(Access=public)

        function[ValidBool,ErrorStr]=InputRangeValidate(obj)
            [ValidBool,ErrorStr]=InputRangeValidate@coder.internal.mathfcngenerator.HDLLookupTable(obj);
            if(~ValidBool)return;end
            if(strcmpi(obj.Mode,'ShiftAndAdd'))

                ValidBool=(obj.InputExtents(1)>=-0.6072)&&(obj.InputExtents(2)<=0.6072);
                if(~ValidBool)
                    ErrorStr=message('float2fixed:MFG:Asin_Err').getString();
                end
                return;
            else

                ValidBool=(obj.InputExtents(1)>=-1)&&(obj.InputExtents(2)<=1);
                ErrorStr=message('float2fixed:MFG:GenericDomain_Err','asin','[-1,1]').getString();
            end
        end
    end
end
