

classdef HDLFlat<coder.internal.mathfcngenerator.HDLLookupTable
    methods
        function obj=HDLFlat(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            obj.SpecialTemplate='fixpt_hdl_fullyspecified_skeleton.tpl.m';
            if(isempty(obj.N))
                obj.N=128;
            end
            if(isempty(obj.InputExtents))
                obj.InputExtents=[0,1];
            end
            if(isempty(obj.InterpolationDegree))
                obj.InterpolationDegree=0;
            end
            if(isempty(obj.GenFixptCode))
                obj.GenFixptCode=true;
            end
            obj.Mode='UniformInterpolation';
        end
    end

    methods(Access=protected)
        function code_tb=generateTB(obj,function_name)

            if(nargin<1)
                function_name=regexp(class(obj),'HDL\w*','match');
                function_name=function_name{1};
            end

            if obj.GenerateTestBench
                switch(obj.getNumInputs())
                case 1

                    input_points=linspace(obj.InputExtents(1),obj.InputExtents(2),fix(length(obj.InputDomain)*1.5));
                    output=arrayfun(obj.CandidateFunction,input_points);
                    candidate_function_call=obj.getCandidateFunctionCall();
                    code_tb=coder.internal.mathfcngenerator.HDLLookupTable.renderTestBench(class(obj),candidate_function_call,function_name,...
                    input_points,output,obj.Iterations,obj.PipelinedCode,obj.GenFixptCode,obj.TypeProposalSettings);
                otherwise
                    error(message('float2fixed:MFG:DontKnowTBGen'))
                end
                code_tb=obj.prettyPrint(code_tb);
            else

                code_tb='';
            end
        end
    end
    methods(Access=public)
        function[code,function_name,code_tb]=generateMATLAB(obj,function_name)
            if(~obj.GenFixptCode)
                error('Fully Specified Lookup Table works only for fixpt code');
            end
            if(nargin(obj.CandidateFunction)~=1)
                error(message('float2fixed:MFG:FlatModeOnlyOneInput'));
            end
            if(nargout(obj.CandidateFunction)~=1)
                error(message('float2fixed:MFG:FlatModeOnlyOneOutput'));
            end
            [code,function_name,code_tb]=generateMATLAB@coder.internal.mathfcngenerator.HDLLookupTable(obj,function_name);
        end
    end
end
