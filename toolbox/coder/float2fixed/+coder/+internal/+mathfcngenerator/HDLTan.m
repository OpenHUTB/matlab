



classdef HDLTan<coder.internal.mathfcngenerator.HDLLookupTable
    methods

        function obj=HDLTan(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            obj.CandidateFunction=@(x)tan(x);
            if(nargin<1)
                obj.InputExtents=[-pi/2,pi/2]*0.999;
                obj.Mode='UniformInterpolation';
                obj.N=1000;
            end
            obj.DefaultRange=[0,pi/2-2e-4];
        end
    end

    methods(Access=public)

        function[ValidBool,ErrorStr]=InputRangeValidate(obj)
            [ValidBool,ErrorStr]=InputRangeValidate@coder.internal.mathfcngenerator.HDLLookupTable(obj);
            if(~ValidBool)
                return;
            end



            ValidBool1=(floor((obj.InputExtents(1)-(pi/2))/pi)==floor((obj.InputExtents(2)-(pi/2))/pi));

            ValidBool=ValidBool1&&((~(mod(obj.InputExtents(1)*(2/pi),2)==1))&&(~(mod(obj.InputExtents(2)*(2/pi),2)==1)));
            if(~ValidBool)
                ErrorStr=message('float2fixed:MFG:Tan_Err').getString();
            end
        end
    end


end
