




classdef HDLVectormagnitude<coder.internal.mathfcngenerator.HDLDivide

    methods
        function obj=HDLVectormagnitude(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLDivide(varargin{:});


            obj.InputExtents=[0.1,1e2];
            obj.Mode='ShiftAndAdd';
            obj.Iterations=10;
            obj.DefaultRange=[0.1,1e2];



            obj.CandidateFunction=@(x)sqrt(1+x.^2);
        end

        function OUTPUT=doVectormagnitude_shiftandadd(obj,x,y)






            K=obj.Gain;

            xtmp=x;
            ytmp=y;

            for idx=1:obj.Iterations
                if y<0

                    x=x-ytmp;
                    y=y+xtmp;
                else

                    x=x+ytmp;
                    y=y-xtmp;
                end


                xtmp=bitsra(x,idx);
                ytmp=bitsra(y,idx);

            end

            OUTPUT=x*K;
        end

        function[LUT,Gain]=GenerateShiftAndAdd_LUT(obj)
            LUT=[];
            m=prod(sqrt(1+2.^(-2*(0:(obj.Iterations-1)))));
            Gain=1/m;
        end
    end

    methods(Access=public)
        function y=setup(obj,u,v)
            if(obj.RequireSetup())
                obj.setup_internal(v);
            end


            y=obj.doVectormagnitude_shiftandadd(u,v);
        end
        function Nin=getNumInputs(obj)%#ok<MANU>

            Nin=2;
        end
    end

    methods(Access=public)

        function[code,function_name,code_tb]=generateMATLAB(obj,function_name)%#ok<INUSD>
            className=regexp(class(obj),'HDL\w*','match');%#ok<NASGU>
            Iterations=obj.Iterations;%#ok<NASGU>
            InputDomain=obj.InputDomain;%#ok<NASGU>
            Gain=obj.Gain;%#ok<NASGU>
            [pathParent,~,~]=fileparts(mfilename('fullpath'));
            if obj.PipelinedCode
                code=coder.internal.tools.TML.render(fullfile(pathParent,'hdl_Circular_Cordic_pipelined.tpl.m'));
            else
                code=coder.internal.tools.TML.render(fullfile(pathParent,'hdl_Circular_Cordic.tpl.m'));
            end

            code_tb=obj.generateTB(function_name);
            code=obj.prettyPrint(code);

        end


        function[ValidBool,ErrorStr]=InputRangeValidate(obj)
            [ValidBool,ErrorStr]=InputRangeValidate@coder.internal.mathfcngenerator.HDLLookupTable(obj);
            if(~ValidBool)
                return;
            end
            if(~strcmpi(obj.Mode,'ShiftAndAdd'))
                ValidBool=0;
                ErrorStr=message('float2fixed:MFG:VecMag_Err').getString();
            end
        end
    end

end

