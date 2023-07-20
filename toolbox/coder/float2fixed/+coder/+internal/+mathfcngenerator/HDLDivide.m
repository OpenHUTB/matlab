



classdef HDLDivide<coder.internal.mathfcngenerator.HDLReciprocal
    methods
        function obj=HDLDivide(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLReciprocal(varargin{:});
            obj.InputExtents=[1e-3,10];
            obj.DefaultRange=[1e-2,1e2;1e-2,1e2;];
        end

        function y=doDivide(obj,u,v)
            if(v<0)
                y=-u*obj.AutoLookupTable(abs(v));
            else
                y=u*obj.AutoLookupTable(v);
            end
        end

        function y=doDivide_ShiftAndAdd(obj,a,b)

            A_k=0;c=0;
            x_k=b;y_k=a;

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
            y=c;
        end
    end

    methods(Access=protected)
        function candidate_function_call=getCandidateFunctionCall(obj)
            candidate_function_call='rdivide(%s,%s)';
        end
        function candidate_function_name=getCandidateFunctionName(obj)
            candidate_function_name='rdivide';
        end
    end

    methods(Access=public)
        function y=setup(obj,u,v)
            if(obj.RequireSetup())
                obj.setup_internal(v);
            end


            if(strcmpi(obj.Mode,'ShiftAndAdd'))
                y=obj.doDivide_ShiftAndAdd(u,v);
            else
                y=obj.doDivide(u,v);
            end
        end
        function Nin=getNumInputs(obj)%#ok<MANU>

            Nin=2;
        end
    end
    methods(Access=public)
        function[code,function_name,code_tb]=generateMATLAB(obj,function_name)
            if(obj.RequireSetup())
                obj.setup_internal(obj.InputExtents(1));
                obj.setup(obj.InputExtents(1),obj.InputExtents(1));
            end
            if(strcmpi(obj.Mode,'ShiftAndAdd'))
                className=regexp(class(obj),'HDL\w*','match');%#ok<NASGU>
                Iterations=obj.Iterations;%#ok<NASGU>
                InputDomain=obj.InputDomain(1):((obj.InputDomain(end)-obj.InputDomain(1))/100):obj.InputDomain(end);%#ok<NASGU>
                [pathParent,~,~]=fileparts(mfilename('fullpath'));
                if obj.PipelinedCode
                    code=coder.internal.tools.TML.render(fullfile(pathParent,'hdl_linear_Cordic_pipelined.tpl.m'));
                else
                    code=coder.internal.tools.TML.render(fullfile(pathParent,'hdl_linear_Cordic.tpl.m'));
                end
            else
                assert(numel(obj.LUT)>0,'LUT size must be non-zero')
                if(nargin<2)
                    function_name=regexp(class(obj),'[a-zA-Z]+$','match');
                    function_name=function_name{1};
                end
                [pathParent,~,~]=fileparts(mfilename('fullpath'));
                InputDomain=obj.InputDomain;%#ok<NASGU>
                LUT=obj.LUT;%#ok<NASGU>
                N=obj.N;%#ok<NASGU>                
                InterpolationDegree=obj.InterpolationDegree;
                GenFixptCode=obj.GenFixptCode;%#ok<NASGU>
                recip_code=generateMATLAB@coder.internal.mathfcngenerator.HDLReciprocal(obj,[function_name,'_recip']);%#ok<NASGU>                
                code=coder.internal.tools.TML.render(fullfile(pathParent,'hdl_lookup_skeleton_divide.tpl.m'));
            end

            code=obj.prettyPrint(code);




            Iterations=obj.Iterations;%#ok<NASGU>
            InputDomain=linspace(obj.InputExtents(1),obj.InputExtents(2),obj.N);%#ok<NASGU> %50% more than usual points for TB
            Gain=obj.Gain;%#ok<NASGU>
            LUT=InputDomain'*(1./InputDomain);
            if obj.GenFixptCode
                fixptprefix='fixpt_';
                typeProposalSettings=obj.TypeProposalSettings;
                NT=coder.internal.getBestNumericTypeForVal(min(InputDomain),max(InputDomain),false,typeProposalSettings);%#ok<NASGU>
                FimathStr=coder.FixPtConfig.FIMATHSTR;%#ok<NASGU>
            else
                fixptprefix='';
            end
            [pathParent,~,~]=fileparts(mfilename('fullpath'));
            TestBenchName=[function_name,'_tb'];%#ok<NASGU>
            candidate_function_call=obj.getCandidateFunctionCall();

            code_tb=coder.internal.tools.TML.render(fullfile(pathParent,[fixptprefix,'TestBench_TwoInput.tpl.m']));
        end


        function[ValidBool,ErrorStr]=InputRangeValidate(obj)
            [ValidBool,ErrorStr]=InputRangeValidate@coder.internal.mathfcngenerator.HDLLookupTable(obj);
            if(~ValidBool)return;end %#ok<SEPEX>


            ValidBool=(sign(obj.InputExtents(1))*sign(obj.InputExtents(2))~=-1&&sign(obj.InputExtents(1))*sign(obj.InputExtents(2))~=0);
            if(~ValidBool)
                ErrorStr=message('float2fixed:MFG:Divide_Err').getString();
            end
        end
    end
end
