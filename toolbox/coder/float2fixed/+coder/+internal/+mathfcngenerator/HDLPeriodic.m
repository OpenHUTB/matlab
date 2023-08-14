



classdef HDLPeriodic<coder.internal.mathfcngenerator.HDLLookupTable
    properties
Period
    end
    methods
        function obj=HDLPeriodic(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});
            obj.SpecialTemplate='hdl_lookup_skeleton_1Dinterp_uniform.tpl.m';
        end


        function[code,function_name,code_tb]=generateMATLAB(obj,function_name)





            oldIP=obj.InputExtents;




            if(max(obj.InputExtents)>obj.Period)
                obj.InputExtents=[0,obj.Period];
            end

            obj.setup_internal(obj.InputExtents(1));
            obj.setup(obj.InputExtents(1));
            obj.InputExtents=oldIP;

            if nargin<2
                function_name=strrep(class(obj),'.','_');
            end


            if(strcmpi(obj.Mode,'ShiftAndAdd'))


                str=coder.internal.mathfcngenerator.HDLLookupTable.renderShiftAndAddMatlabCode(class(obj),function_name,obj.Gain,obj.LUT,obj.Iterations,obj.InputDomain,obj.PipelinedCode,obj.GenFixptCode);
            else
                if~(numel(obj.LUT)>0)
                    error(message('float2fixed:MFG:LUTNonZero'))
                end
                [pathParent,~,~]=fileparts(mfilename('fullpath'));
                LUT=obj.LUT;
                N=obj.N;
                InputDomain=obj.InputDomain;
                InputExtents=obj.InputExtents;
                Period=obj.Period;%#ok<PROP>
                InterpolationDegree=obj.InterpolationDegree;

                if(obj.GenFixptCode)
                    fixptprefix='fixpt_';
                    typeProposalSettings=obj.TypeProposalSettings;
                    NT=coder.internal.getBestNumericTypeForVal(min(LUT),max(LUT),false,typeProposalSettings);
                else
                    fixptprefix='';
                end

                if(strcmpi(obj.Mode,'CustomInterpolation'))
                    str=coder.internal.tools.TML.render(fullfile(pathParent,[fixptprefix,'hdl_lookup_skeleton_1Dinterp_binsearch.tpl.m']));
                else
                    str=coder.internal.tools.TML.render(fullfile(pathParent,[fixptprefix,obj.SpecialTemplate]));
                end
            end

            code_tb=obj.generateTB(function_name);
            code=obj.prettyPrint(str);

        end
    end
end
