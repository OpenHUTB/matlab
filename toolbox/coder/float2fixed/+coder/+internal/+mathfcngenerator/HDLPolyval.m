




classdef HDLPolyval<coder.internal.mathfcngenerator.HDLLookupTable

    properties
Coefficients
    end

    properties(Access=private)
Degree
    end

    methods(Access=protected)
        function candidate_function_call=getCandidateFunctionCall(obj)
            candidate_function_call=['polyval(',coder.internal.tools.TML.tostr(obj.Coefficients),', %s )'];
        end
    end

    methods

        function obj=HDLPolyval(varargin)
            if(nargin<=0)
                error(message('float2fixed:MFG:PolyvalArgs'))
            end

            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});

            if(nargin>0)
                for k=1:2:nargin
                    obj.(varargin{k})=varargin{k+1};
                end
            end

            obj.Degree=length(obj.Coefficients);
            obj.CandidateFunction=@(x)polyval(obj.Coefficients,x);
            obj.SpecialTemplate='hdl_lookup_skeleton_polyval.tpl.m';
            obj.DefaultRange=[-10,10];
        end
    end

    methods(Access=public)


        function[code,function_name,code_tb]=generateMATLAB(obj,function_name)
            if(obj.RequireSetup())
                obj.setup_internal(obj.InputExtents(1));
                obj.setup(obj.InputExtents(1));
            end
            if~(numel(obj.LUT)>0)
                error(message('float2fixed:MFG:LUTNonZero'))
            end

            if(nargin<2)
                function_name=regexp(class(obj),'[a-zA-Z]+$','match');
                function_name=function_name{1};
            end
            [pathParent,~,~]=fileparts(mfilename('fullpath'));
            coeffs=obj.Coefficients;
            InputDomain=obj.InputDomain;
            GenFixptCode=obj.GenFixptCode;
            code=coder.internal.tools.TML.render(fullfile(pathParent,obj.SpecialTemplate));
            code=obj.prettyPrint(code);
            code_tb=obj.generateTB(function_name);
        end
    end
end
