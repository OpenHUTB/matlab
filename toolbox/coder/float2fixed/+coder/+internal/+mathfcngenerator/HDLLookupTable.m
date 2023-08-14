



classdef HDLLookupTable<handle

    properties(Access=public)
Mode
CandidateFunction
InputExtents
N
LUT
        SpecialTemplate;
        InterpolationDegree;
        ErrorThreshold;
        Iterations;
        GenFixptCode;
        PipelinedCode;
        GenerateTestBench;
        OptimizeIterations=25;
TypeProposalSettings
    end


    properties(Access=private)
MsqError
AbsError
RelError
OldState
    end

    properties(Hidden)
DefaultRange
Gain
CustomInterpolationDomain
InputDomain
    end

    methods(Hidden,Access=public)
        function flag=RequireSetup(obj)
            currState=struct();
            userProps=fields(obj);
            for itr=1:length(userProps)
                currState.(userProps{itr})=obj.(userProps{itr});
            end

            if(isempty(obj.OldState))

                obj.OldState=currState;
                flag=true;
            else
                flag=~isequal(currState,obj.OldState);
                obj.OldState=currState;
            end
        end
    end

    methods(Hidden)
        function[LUT,Gain]=GenerateShiftAndAdd_LUT(obj)%#ok<MANU>
            LUT=[];
            Gain=[];
            error(message('float2fixed:MFG:CoderApproximateUnsupported_Err'));
        end

        function y=AutoLookupTable(obj,x)






            if(~strcmpi(obj.Mode,'CustomInterpolation'))
                constantInputRange=isequal(obj.InputDomain(:,1),obj.InputDomain(:,2));
                if(constantInputRange)
                    y=obj.LUT(1);
                    if(~all(isreal(y)))
                        warning(message('float2fixed:MFG:ImaginaryValuesFound'))
                    end
                    return;
                end
            end

            switch(obj.Mode)
            case 'Exact'
                idx=find(obj.InputDomain>=x);
                if(isempty(idx))
                    error(message('float2fixed:MFG:InputOutOfRange',num2str(x)));
                end
                idx=idx(1);
                y=obj.LUT(idx);
            case 'CustomInterpolation'


                idx_bot=find(obj.InputDomain<=x);
                if(isempty(idx_bot))
                    error(message('float2fixed:MFG:InputOutOfRange',num2str(x)));
                end
                idx_bot=idx_bot(end);

                idx_top=find(obj.InputDomain>=x);
                if(isempty(idx_top))
                    error(message('float2fixed:MFG:InputOutOfRange',num2str(x)));
                end


                if(idx_bot==numel(obj.LUT))
                    idx_bot=idx_bot-1;
                elseif(idx_bot==0)
                    idx_bot=1;
                end

                idx_top=idx_top(1);
                if(idx_top==idx_bot)
                    idx_top=idx_bot+1;
                end
                x_bot=obj.InputDomain(idx_bot);
                x_top=obj.InputDomain(idx_top);
                y_bot=obj.LUT(idx_bot);
                y_top=obj.LUT(idx_top);


                if(obj.InterpolationDegree>1)
                    error(message('float2fixed:MFG:SupportedInterpModes4CustomLUT'));
                end

                y=coder.internal.mathfcngenerator.HDLLookupTable.interp1D(x,x_bot,x_top,y_bot,y_top);

            case 'UniformInterpolation'


                deltaXInv=1/diff(obj.InputDomain(1:2));
                x_idx=(x-obj.InputExtents(1))*deltaXInv;
                idx_bot=ceil(x_idx);

                if(idx_bot>=obj.N)
                    idx_bot=obj.N-1;
                elseif(idx_bot==0)
                    idx_bot=1;
                end

                switch(obj.InterpolationDegree)
                case 0
                    y=obj.LUT(idx_bot);
                case 1
                    idx_top=(idx_bot+1);

                    x_bot=obj.InputDomain(idx_bot);
                    x_top=obj.InputDomain(idx_top);
                    y_bot=obj.LUT(idx_bot);
                    y_top=obj.LUT(idx_top);

                    y=coder.internal.mathfcngenerator.HDLLookupTable.interp1D(x,x_bot,x_top,y_bot,y_top);
                case 2
                    idx_mid=(idx_bot+1);

                    idx_top=(idx_mid+1);


                    if(idx_top>obj.N)
                        idx_top=obj.N;
                    end

                    x_bot=obj.InputDomain(idx_bot);
                    x_mid=obj.InputDomain(idx_mid);
                    x_top=obj.InputDomain(idx_top);

                    y_bot=obj.LUT(idx_bot);
                    y_mid=obj.LUT(idx_mid);
                    y_top=obj.LUT(idx_top);

                    if(x_mid==x_top)
                        y=(y_mid+y_top)/2;
                    else
                        y=coder.internal.mathfcngenerator.HDLLookupTable.interp2D(x,x_bot,x_mid,x_top,y_bot,y_mid,y_top);
                    end
                case 3
                    idx_mid_dn=(idx_bot+1);
                    idx_mid_up=(idx_bot+2);

                    idx_top=(idx_mid_up+1);


                    if(idx_mid_up>obj.N)
                        idx_mid_up=obj.N;
                    end
                    if(idx_top>obj.N)
                        idx_top=obj.N;
                    end

                    x_bot=obj.InputDomain(idx_bot);
                    x_mid_up=obj.InputDomain(idx_mid_up);
                    x_mid_dn=obj.InputDomain(idx_mid_dn);
                    x_top=obj.InputDomain(idx_top);

                    y_bot=obj.LUT(idx_bot);
                    y_mid_dn=obj.LUT(idx_mid_dn);
                    y_mid_up=obj.LUT(idx_mid_up);
                    y_top=obj.LUT(idx_top);

                    if(x_mid_up==x_mid_dn||x_mid_up==x_top)
                        y=(y_bot+y_mid_dn+y_mid_up+y_top)/4;
                    else
                        y=coder.internal.mathfcngenerator.HDLLookupTable.interp3D(x,x_bot,x_mid_dn,x_mid_up,x_top,y_bot,y_mid_dn,y_mid_up,y_top);
                    end
                otherwise
                    error(message('float2fixed:MFG:UnimplementedInterp'));
                end
            case 'ShiftAndAdd'
                y=doShiftAndAdd(obj,x);
            otherwise
                error(message('float2fixed:MFG:UnimplementedMode'));
            end

            if(~all(isreal(y)))
                warning(message('float2fixed:MFG:ImaginaryValuesFound'))
            end
        end


        function y=doShiftAndAdd(obj,x)
            y=x;%#ok<NASGU>
            error(message('float2fixed:MFG:MethodNotImpl',class(obj)));
        end
    end

    methods
        function value=get.Mode(obj)
            value=obj.Mode;
            return;
        end

        function obj=set.InterpolationDegree(obj,value)
            if(~(value>=0&&value<=3))
                error(message('float2fixed:MFG:InterpDegree_Err'));
            end
            obj.InterpolationDegree=value;
            return;
        end

        function obj=set.Mode(obj,value)
            if~coder.internal.mathfcngenerator.HDLLookupTable.isModeAllowed(value)
                AllowedValues=coder.internal.mathfcngenerator.HDLLookupTable.getAllowedModes();
                cellfun(@disp,AllowedValues);
                error(message('float2fixed:MFG:DisallowedMode',value));
            end

            obj.Mode=value;
            return;
        end

        function obj=HDLLookupTable(varargin)
            obj.OldState=[];


            obj.DefaultRange=[0,1e3];


            for itr=1:2:nargin
                obj.(varargin{itr})=varargin{itr+1};
            end
            obj.LUT=[];
            obj.SpecialTemplate=[];
            obj.GenFixptCode=false;
            obj.PipelinedCode=0;
            obj.GenerateTestBench=1;


            obj.MsqError=[];
            obj.AbsError=[];
            obj.RelError=[];


            obj.InterpolationDegree=1;


            obj.ErrorThreshold=1e-2;


            obj.TypeProposalSettings=coder.internal.Float2FixedConverter.getTypeSettingsForApproximation();


            for k=1:2:nargin
                obj.(varargin{k})=varargin{k+1};
            end

        end
        function pretty_code=prettyPrint(obj,code)%#ok<INUSL>
            pretty_code=code;
        end
    end

    methods(Access=private)
        function obj=buildInputDomain(obj)

            switch(obj.Mode)
            case 'UniformInterpolation'
                if(isempty(obj.N))
                    error(message('float2fixed:MFG:MissingParamNpts'));
                end
                obj.InputDomain=linspace(obj.InputExtents(1),obj.InputExtents(2),obj.N);
            case 'Exact'
                obj.InputDomain=obj.InputExtents(1):obj.InputExtents(2);
            case 'CustomInterpolation'
                q=coder.internal.mathfcngenerator.ThresholdInterpolate();
                q.InputExtents=obj.InputExtents;
                q.CandidateFunction=obj.CandidateFunction;
                q.ErrorThreshold=obj.ErrorThreshold;
                q.InterpolationDegree=obj.InterpolationDegree;
                q.MaxTries=obj.OptimizeIterations;
                if(~q.optimize())
                    error(message('float2fixed:MFG:OptimFailed'));
                end

                obj.N=q.N;
                obj.InputDomain=q.InputDomain;
                obj.LUT=q.LUT;


            case{'ShiftAndAdd'}

                obj.InputDomain=linspace(obj.InputExtents(1),obj.InputExtents(2),100);
                return;
            otherwise
                error(message('float2fixed:MFG:InvalidMode'));
            end
            obj.InputDomain=sort(obj.InputDomain,'ascend');
            obj.N=length(obj.InputDomain);
        end
    end

    methods(Access=protected)
        function candidate_function_call=getCandidateFunctionCall(obj)
            nargs=strjoin(repmat({'%s'},1,obj.getNumInputs()),',');
            candidate_function_call=[obj.getCandidateFunctionName(),'( ',nargs,' )'];
        end

        function candidate_function_name=getCandidateFunctionName(obj)
            if isa(obj.CandidateFunction,'char')
                candidate_function_name=obj.CandidateFunction;
            elseif isa(obj.CandidateFunction,'function_handle')
                fcn_tree=mtree(func2str(obj.CandidateFunction));
                fcn_node=fcn_tree.mtfind('Kind','ID');
                candidate_function_name=fcn_node.tree2str();
            else
                candidate_function_name=func2str(obj.CandidateFunction);
            end
            candidate_function_name=strtrim(candidate_function_name);
            if(isempty(candidate_function_name))
                warning('float2fixed:MFG:CandidateFunctionNameEmpty',func2str(obj.CandidateFunction));
                candidate_function_name='unknown';
            end
        end

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
                case 2
                    className=regexp(class(obj),'HDL\w*','match');%#ok<NASGU>
                    candidate_function_call=obj.getCandidateFunctionCall();
                    Iterations=obj.Iterations;%#ok<NASGU>
                    InputDomain=linspace(obj.InputExtents(1),obj.InputExtents(2),fix(obj.N*1.5));%#ok<NASGU> %50% more than usual points for TB
                    Gain=obj.Gain;%#ok<NASGU>
                    LUT=obj.LUT;
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
                    if obj.PipelinedCode

                        code_tb=coder.internal.tools.TML.render(fullfile(pathParent,'TestBench_TwoInput_Pipelined.tpl.m'));
                    else

                        code_tb=coder.internal.tools.TML.render(fullfile(pathParent,[fixptprefix,'TestBench_TwoInput.tpl.m']));
                    end
                otherwise
                    error(message('float2fixed:MFG:DontKnowTBGen'))
                end
                code_tb=obj.prettyPrint(code_tb);
            else

                code_tb='';
            end
        end

        function setup_internal(obj,varargin)


            obj.buildInputDomain();


            switch(obj.Mode)
            case 'ShiftAndAdd'



                [obj.LUT,obj.Gain]=GenerateShiftAndAdd_LUT(obj);%#ok<MCHV3>
            case 'CustomInterpolation'

            otherwise

                try
                    obj.LUT=arrayfun(obj.CandidateFunction,obj.InputDomain);
                catch mEx
                    mEx2=MException('float2fixed:MFG:CannotEvaluateCandidateFunction',func2str(obj.CandidateFunction)).addCause(mEx);
                    mEx2.throw()
                end
            end
        end
    end
    methods(Hidden)
        function y=setup(obj,u)

            if(obj.RequireSetup())
                obj.setup_internal(u);
            end
            y=arrayfun(@obj.AutoLookupTable,u);
        end

        function Nin=getNumInputs(obj)%#ok<MANU>

            Nin=1;
        end

        function Nout=getNumOutputs(obj)%#ok<MANU>

            Nout=1;
        end
    end

    methods(Static,Access=public)
        function Values=getAllowedModes()
            Values={'Exact','UniformInterpolation','CustomInterpolation','ShiftAndAdd'};
        end
        function res=isModeAllowed(value)
            allowedValues=coder.internal.mathfcngenerator.HDLLookupTable.getAllowedModes();
            res=any(strcmpi(allowedValues,value));
        end
    end

    methods(Hidden)

        function forwardProperties(obj,configObj,objUserIn)
            if nargin<3
                objUserIn=struct();
            end
            if~(isa(configObj,'coder.internal.mathfcngenerator.Config')&&...
                isa(obj,'coder.internal.mathfcngenerator.HDLLookupTable'))
                error(message('float2fixed:MFG:UnexpectedInputObject'));
            end

            parameterMap=containers.Map();
            if(isempty(configObj.FunctionNamePrefix))
                configObj.FunctionNamePrefix=configObj.Function;
            end



            parameterMap('GenerateTestBench')='GenerateTestBench';


            parameterMap('GenerateFixptCode')='GenFixptCode';
            parameterMap('InputRange')='InputExtents';
            parameterMap('Mode')='Mode';

            parameterMap('InterpolationDegree')='InterpolationDegree';
            parameterMap('NumberOfPoints')='N';
            parameterMap('NumberOfIterations')='Iterations';
            parameterMap('ErrorThreshold')='ErrorThreshold';
            parameterMap('PipelinedArchitecture')='PipelinedCode';
            parameterMap('OptimizeIterations')='OptimizeIterations';




            for fieldName=parameterMap.keys
                fieldName=fieldName{1};%#ok<FXSET>
                fwdFieldName=parameterMap(fieldName);
                if(isprop(configObj,fieldName))
                    if(~isempty(configObj.(fieldName)))
                        obj.(fwdFieldName)=configObj.(fieldName);
                    end
                elseif(isfield(objUserIn,fieldName))
                    if(~isempty(objUserIn.(fieldName)))
                        obj.(fwdFieldName)=objUserIn.(fieldName);
                    end
                end
            end



            if(isprop(configObj,'CandidateFunction'))
                if(~isempty(configObj.CandidateFunction))
                    obj.CandidateFunction=configObj.CandidateFunction;
                end
            end
        end
    end

    methods(Static,Access=public)

        function y=interp1D(x,x_bot,x_top,y_bot,y_top)

            y=y_top*(x-x_bot)./(x_top-x_bot)+...
            y_bot*(x_top-x)./(x_top-x_bot);
        end

        function y=interp2D(x,x_bot,x_mid,x_top,y_bot,y_mid,y_top)

            y=y_top*(x-x_mid).*(x-x_bot)./((x_top-x_mid).*(x_top-x_bot))+...
            y_mid*(x-x_bot).*(x_top-x)./((x_mid-x_bot)*(x_top-x_mid))+...
            y_bot*(x_top-x).*(x_mid-x)./((x_top-x_bot).*(x_mid-x_bot));
        end

        function y=interp3D(x,x_bot,x_min_dn,x_mid_up,x_top,y_bot,y_mid_dn,y_mid_up,y_top)
            function Y=lagrange_interpolate_3(x,x1,y1,x2,y2,x3,y3,x4,y4)
                Y=...
                y1*(x-x2)/(x1-x2)*(x-x3)/(x1-x3)*(x-x4)/(x1-x4)...
                +y2*(x-x1)/(x2-x1)*(x-x3)/(x2-x3)*(x-x4)/(x2-x4)...
                +y3*(x-x1)/(x3-x1)*(x-x2)/(x3-x2)*(x-x4)/(x3-x4)...
                +y4*(x-x1)/(x4-x1)*(x-x2)/(x4-x2)*(x-x3)/(x4-x3);
                return
            end
            y=lagrange_interpolate_3(x,x_bot,y_bot,x_min_dn,y_mid_dn,x_mid_up,y_mid_up,x_top,y_top);
        end

        function str=renderMATLABcode(function_name,LUT,InputDomain,mode,customTpl,InterpolationDegree,fixptprefix,typeProposalSettings)%#ok<INUSD,INUSL>



            if(nargin<5)
                customTpl=[];
            end
            if(nargin<6)
                fixptprefix='';
            end
            if(nargin<7)
                typeProposalSettings=[];
            end

            N=length(InputDomain);%#ok<PROP,NASGU>
            [pathParent,~,~]=fileparts(mfilename('fullpath'));






            if(isempty(customTpl))
                switch(mode)
                case 'Exact'
                    str=coder.internal.tools.TML.render(fullfile(pathParent,[fixptprefix,'hdl_lookup_skeleton.tpl.m']));
                case 'UniformInterpolation'
                    NT=getNumericType(LUT,typeProposalSettings);
                    str=coder.internal.tools.TML.render(fullfile(pathParent,[fixptprefix,'hdl_lookup_skeleton_1Dinterp_uniform.tpl.m']));
                case 'CustomInterpolation'
                    str=coder.internal.tools.TML.render(fullfile(pathParent,[fixptprefix,'hdl_lookup_skeleton_1Dinterp_binsearch.tpl.m']));
                case 'ShiftAndAdd'
                    str=TML.render(fullfile(pathParent,[fixptprefix,'hdl_skeleton_ShiftAndAdd.tpl.m']));
                end
            else
                NT=getNumericType(LUT,typeProposalSettings);
                str=coder.internal.tools.TML.render(fullfile(pathParent,customTpl));
            end



            function NT=getNumericType(LUT,typeProposalSettings)
                if(nargin<2||isempty(typeProposalSettings))
                    typeProposalSettings=coder.internal.Float2FixedConverter.getTypeSettingsForApproximation();
                end
                NT=coder.internal.getBestNumericTypeForVal(min(LUT),max(LUT),false,typeProposalSettings);
            end
        end

        function pretty_code=doPrettyPrint(code)
            pretty_code=code;
        end


        function str=renderShiftAndAddMatlabCode(className,function_name,Gain,LUT,Iterations,InputDomain,Pipelined,genFixptCode)%#ok<INUSD>
            if genFixptCode
                fixptPrefix='fixpt_';
                typeProposalSettings=coder.internal.Float2FixedConverter.getTypeSettingsForApproximation();
                typeProposalSettings.safetyMargin=0;
                NT=coder.internal.getBestNumericTypeForVal(min(LUT),max(LUT),false,typeProposalSettings);%#ok<NASGU>
            else
                fixptPrefix='';
            end
            className=regexp(className,'HDL\w*','match');
            className=className{1};
            Implemented_ShiftAndAdd=any(strcmpi({'HDLExp','HDLInvlog','HDLLog','HDLLog_base'},className));
            Implemented_Hyperbolic=any(strcmpi({'HDLCosh','HDLSinh','HDLSqrt'},className));
            Implemented_Circular=any(strcmpi({'HDLSin','HDLCos','HDLAsin','HDLAcos','HDLAtan'},className));
            Implemented_Linear=strcmpi('HDLReciprocal',className);

            [pathParent,~,~]=fileparts(mfilename('fullpath'));

            if Pipelined
                if(Implemented_ShiftAndAdd)


                    str=coder.internal.tools.TML.render(fullfile(pathParent,'hdl_skeleton_ShiftAndAdd_pipelined.tpl.m'));
                elseif(Implemented_Hyperbolic)


                    str=coder.internal.tools.TML.render(fullfile(pathParent,'hdl_hyperbolic_Cordic_pipelined.tpl.m'));
                elseif(Implemented_Circular)


                    str=coder.internal.tools.TML.render(fullfile(pathParent,'hdl_Circular_Cordic_pipelined.tpl.m'));
                elseif(Implemented_Linear)


                    str=coder.internal.tools.TML.render(fullfile(pathParent,'hdl_linear_Cordic_pipelined.tpl.m'));
                else

                    error(message('float2fixed:MFG:MethodNotImpl',className))
                end

            else
                if(Implemented_ShiftAndAdd)


                    str=coder.internal.tools.TML.render(fullfile(pathParent,[fixptPrefix,'hdl_skeleton_ShiftAndAdd.tpl.m']));
                elseif(Implemented_Hyperbolic)


                    str=coder.internal.tools.TML.render(fullfile(pathParent,'hdl_hyperbolic_Cordic.tpl.m'));
                elseif(Implemented_Circular)


                    str=coder.internal.tools.TML.render(fullfile(pathParent,'hdl_Circular_Cordic.tpl.m'));
                elseif(Implemented_Linear)


                    str=coder.internal.tools.TML.render(fullfile(pathParent,'hdl_linear_Cordic.tpl.m'));
                else

                    error(message('float2fixed:MFG:MethodNotImpl',className))
                end

            end




        end

        function str_tb=renderTestBench(className,candidate_function_call,function_name,...
            InputDomain,output,Iterations,PipelinedCode,genFixptCode,typeProposalSettings)%#ok<INUSL>

            if(nargin<9)
                if(genFixptCode)
                    typeProposalSettings=coder.internal.Float2FixedConverter.getTypeSettingsForApproximation();
                else
                    typeProposalSettings=[];
                end
            end

            if genFixptCode
                fixptprefix='fixpt_';
                NT=coder.internal.getBestNumericTypeForVal(min(InputDomain),max(InputDomain),false,typeProposalSettings);%#ok<NASGU>
                FimathStr=coder.FixPtConfig.FIMATHSTR;%#ok<NASGU>
            else
                fixptprefix='';
            end

            TestBenchName=[function_name,'_tb'];%#ok<NASGU>
            className=regexp(className,'HDL\w*','match');
            className=className{1};%#ok<NASGU>
            [pathParent,~,~]=fileparts(mfilename('fullpath'));
            if PipelinedCode
                str_tb=coder.internal.tools.TML.render(fullfile(pathParent,'TestBench_OneInput_Pipelined.tpl.m'));
            else
                str_tb=coder.internal.tools.TML.render(fullfile(pathParent,[fixptprefix,'TestBench_OneInput.tpl.m']));
            end
        end
    end

    methods(Access=public)

        function[code,code_tb]=writeToFile(obj,FullFileName,verbose)
            if(nargin<3)
                verbose=false;
            end


            [~,fcnName,~]=fileparts(FullFileName);
            [code,~,code_tb]=obj.generateMATLAB(fcnName);
            fp=fopen(FullFileName,'w');
            if(~(fp>0))
                error(message('float2fixed:MFG:FOpenFail',FullFileName));
            end
            fprintf(fp,'%s',code);
            fclose(fp);

            if(obj.GenerateTestBench)
                [a,fcnName,b]=fileparts(FullFileName);
                FullFileNameTB=fullfile(a,[fcnName,'_tb',b]);
                fp=fopen(FullFileNameTB,'w');
                if(fp<=0)
                    error(message('float2fixed:MFG:FOpenFail',FullFileName));
                end
                fprintf(fp,'%s',code_tb);
                fclose(fp);
                if(verbose)
                    disp(['**** file ',FullFileName,' created with the MATLAB code and test bench for object ',class(obj),'.'])
                end
            else
                if(verbose)
                    disp(['**** file ',FullFileName,' created with the MATLAB code for object ',class(obj),'.'])
                end
            end
            return
        end



        function h=plot_interp(obj,h)
            if nargin<2
                h=figure();
            else
                axes(h);
            end
            if(isempty(obj.N))
                newInterpDomain=linspace(obj.InputExtents(1),obj.InputExtents(2),500);
            else
                newInterpDomain=linspace(obj.InputExtents(1),obj.InputExtents(2),obj.N*3);
            end

            switch(obj.getNumInputs())
            case 2
                y_interp=arrayfun(@(x)setup(obj,1,x),newInterpDomain);
            case 1
                y_interp=arrayfun(@(x)setup(obj,x),newInterpDomain);
            end

            switch(obj.Mode)
            case 'ShiftAndAdd'
                plot(obj.InputDomain,feval(obj.CandidateFunction,obj.InputDomain),'-or',newInterpDomain,y_interp,'-b');
                title(['Plot of original and CORDIC versions for ',func2str(obj.CandidateFunction)])
                xlabel('Input domain (x)')
                ylabel(' y = f(x)')
                legend({'Original function','Interpolation function'},'Location','SouthEast')
            otherwise
                plot(obj.InputDomain,obj.LUT,'-or',newInterpDomain,y_interp,'-b');
                title(['Plot LUT [',num2str(numel(obj.LUT)),' pts] and interpolated versions for ',func2str(obj.CandidateFunction)])
                xlabel('Input domain (x)')
                ylabel(' y = f(x)')
                legend({'Lookup table points','Interpolation function'},'Location','SouthEast')
            end
        end


        function[code,function_name,code_tb]=generateMATLAB(obj,function_name)
            if(obj.RequireSetup())
                obj.setup_internal(obj.InputExtents(1));
                obj.setup(obj.InputExtents(1));
            end
            if nargin<2
                function_name=strrep(class(obj),'.','_');
            end


            if(strcmpi(obj.Mode,'ShiftAndAdd'))


                str=coder.internal.mathfcngenerator.HDLLookupTable.renderShiftAndAddMatlabCode(class(obj),function_name,obj.Gain,obj.LUT,obj.Iterations,obj.InputDomain,obj.PipelinedCode,obj.GenFixptCode);
            else
                if~(numel(obj.LUT)>0)
                    error(message('float2fixed:MFG:LUTNonZero'))
                end
                if(obj.GenFixptCode)
                    fixptprefix='fixpt_';
                else
                    fixptprefix='';
                end
                str=coder.internal.mathfcngenerator.HDLLookupTable.renderMATLABcode(function_name,obj.LUT,...
                obj.InputDomain,obj.Mode,obj.SpecialTemplate,obj.InterpolationDegree,...
                fixptprefix,obj.TypeProposalSettings);
            end


            reFormatCode=@(code)regexprep(code,'(\n\s+\n)+',char(10));

            code_tb=reFormatCode(obj.generateTB(function_name));
            code=reFormatCode(obj.prettyPrint(str));
        end


        function[AEop,MSE,RE]=calculateErrors(obj)

            Y=arrayfun(obj.CandidateFunction,linspace(obj.InputExtents(1),obj.InputExtents(2),obj.N*5));
            switch(obj.getNumInputs())
            case 2
                Yint=arrayfun(@(x)setup(obj,1,x),linspace(obj.InputExtents(1),obj.InputExtents(2),obj.N*5));
            case 1
                Yint=arrayfun(@(x)setup(obj,x),linspace(obj.InputExtents(1),obj.InputExtents(2),obj.N*5));
            end

            AE=abs(Y-Yint);
            obj.AbsError=[min(AE),max(AE)];
            AEop=obj.AbsError;


            MSE=sum(AE.^2)/sum(Y.^2);
            obj.MsqError=MSE;


            RE=sum(AE)./sum(abs(Y));
            obj.RelError=RE;
        end


        function[ValidBool,ErrorStr]=InputRangeValidate(obj)
            ErrorStr='';
            ValidBool=true;


            if(isempty(obj.InputExtents))
                ValidBool=false;
                ErrorStr=message('float2fixed:MFG:InputNotSpec').getString();
            elseif(strcmpi(obj.Mode,'UniformInterpolation')&&obj.N<=2)

                ValidBool=false;
                ErrorStr=message('float2fixed:MFG:InvalidNpts').getString();
            elseif(any(strcmpi(obj.Mode,'ShiftAndAdd'))&&obj.Iterations<=0)
                ValidBool=false;
                ErrorStr=message('float2fixed:MFG:Iterations_Err').getString();
            end

            if(~ValidBool)
                return;
            end



            ValidBool=isreal(obj.InputExtents(1))&&isreal(obj.InputExtents(2));

            if(~ValidBool)
                ErrorStr=message('float2fixed:MFG:ComplexNotAllowed_Err').getString();
                return;
            end




            ValidBool=(obj.InputExtents(1)<=obj.InputExtents(2));
            if(~ValidBool)
                ErrorStr=message('float2fixed:MFG:RangeInvalidMinMax').getString();
            end

        end

    end
end
