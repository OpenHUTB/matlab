



classdef HDLAtan<coder.internal.mathfcngenerator.HDLLookupTable
    methods

        function obj=HDLAtan(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            obj.CandidateFunction=@(x)atan(x);
            if(nargin<1)
                obj.InputExtents=[-10,10];
                obj.Mode='UniformInterpolation';
                obj.N=1000;
            end
            obj.DefaultRange=[-pi,pi];
        end

        function[LUT,Gain]=GenerateShiftAndAdd_LUT(obj)
            LUTDomain=zeros(1,obj.Iterations+1);
            LUTDomain(obj.Iterations+1)=0;
            LUTDomain(1:obj.Iterations)=1./2.^(0:(obj.Iterations-1));
            LUT=arrayfun(@(x)atan(x),LUTDomain);
            Gain=[];
        end

        function OUTPUT=doShiftAndAdd(obj,INPUT)


            LUT=obj.LUT;



            x=1;y=INPUT;z=0;
            xtemp=x;ytemp=y;


            for idx=1:obj.Iterations


                if y<0

                    x=x-ytemp;
                    y=y+xtemp;
                    z=z-LUT(idx);
                else

                    x=x+ytemp;
                    y=y-xtemp;
                    z=z+LUT(idx);
                end


                xtemp=bitsra(x,idx);
                ytemp=bitsra(y,idx);

            end


            OUTPUT=z;
        end
    end
end
