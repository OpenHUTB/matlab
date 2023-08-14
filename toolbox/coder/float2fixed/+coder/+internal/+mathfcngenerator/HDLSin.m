



classdef HDLSin<coder.internal.mathfcngenerator.HDLPeriodic
    methods

        function obj=HDLSin(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLPeriodic(varargin{:});
            obj.Period=2*pi;
            obj.CandidateFunction=@(x)sin(x);
            if(nargin<1)
                obj.InputExtents=[0,2*pi];
                obj.Mode='UniformInterpolation';
                obj.N=1000;
            end
            obj.DefaultRange=[0,2*pi];
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





            negate=1;
            if any(INPUT>pi/2)||any(INPUT<(-pi/2))
                thetaMinusOnePi=INPUT-pi;
                thetaMinusTwoPi=INPUT-2*pi;
                thetaPlusOnePi=INPUT+pi;
                thetaPlusTwoPi=INPUT+2*pi;
                if INPUT>pi/2


                    if(thetaMinusOnePi<=pi/2)

                        INPUT=thetaMinusOnePi;
                        negate=-1;
                    else

                        INPUT=thetaMinusTwoPi;
                    end
                elseif INPUT<-pi/2


                    if(thetaPlusOnePi>=-pi/2)

                        INPUT=thetaPlusOnePi;
                        negate=-1;
                    else

                        INPUT=thetaPlusTwoPi;
                    end
                end
            end



            GAIN=obj.Gain;

            LUT=obj.LUT;

            x=GAIN;y=0;z=INPUT;
            xtemp=x;ytemp=y;


            for idx=1:obj.Iterations;


                if z<0
                    x=x+ytemp;
                    y=y-xtemp;
                    z=z+LUT(idx);
                else
                    x=x-ytemp;
                    y=y+xtemp;
                    z=z-LUT(idx);
                end
                xtemp=bitsra(x,idx);
                ytemp=bitsra(y,idx);
            end

            OUTPUT=y*negate;
        end
    end

    methods(Access=public)

        function[ValidBool,ErrorStr]=InputRangeValidate(obj)
            [ValidBool,ErrorStr]=InputRangeValidate@coder.internal.mathfcngenerator.HDLLookupTable(obj);
            if(~ValidBool)return;end
            if(strcmpi(obj.Mode,'ShiftAndAdd'))

                ValidBool=(obj.InputExtents(1)>=-2*pi)&&(obj.InputExtents(2)<=2*pi);
                if(~ValidBool)
                    ErrorStr=message('float2fixed:MFG:Sine_Err').getString();
                end
            end
        end
    end

end
