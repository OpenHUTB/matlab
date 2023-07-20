



classdef HDLReciprocal<coder.internal.mathfcngenerator.HDLLookupTable
    methods(Access=protected)
        function candidate_function_call=getCandidateFunctionCall(obj)
            candidate_function_call='rdivide(1,%s)';
        end
        function candidate_function_name=getCandidateFunctionName(obj)
            candidate_function_name='rdivide';
        end
    end

    methods

        function obj=HDLReciprocal(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            obj.CandidateFunction=@(x)1./x;
            if(nargin<1)
                obj.InputExtents=[0.1,10];
                obj.Mode='UniformInterpolation';
                obj.N=1000;
            end
            obj.DefaultRange=[1e-2,1e2];
        end

        function[LUT,Gain]=GenerateShiftAndAdd_LUT(obj)%#ok<MANU>

            LUT=[];
            Gain=[];
        end

        function OUTPUT=doShiftAndAdd(obj,INPUT)

            A_k=0;
            c=0;
            x_k=INPUT;
            y_k=1;

            for i=1:obj.Iterations
                y_kt=y_k-bitsra(x_k,A_k);
                z_kt=c+bitsra(1,A_k);
                if y_kt<0

                    A_k=A_k+1;


                else

                    y_k=y_kt;
                    c=z_kt;
                end
            end

            OUTPUT=c;
        end
    end

    methods(Access=public)

        function[ValidBool,ErrorStr]=InputRangeValidate(obj)
            [ValidBool,ErrorStr]=InputRangeValidate@coder.internal.mathfcngenerator.HDLLookupTable(obj);
            if(~ValidBool)
                return;
            end


            ValidBool=(sign(obj.InputExtents(1))*sign(obj.InputExtents(2))~=-1&&sign(obj.InputExtents(1))*sign(obj.InputExtents(2))~=0);
            if(~ValidBool)
                ErrorStr=message('float2fixed:MFG:Recip_Err').getString();
            end
        end
    end
end
