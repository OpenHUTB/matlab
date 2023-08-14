


classdef FixPtConfig<handle
    properties(SetObservable,AbortSet)
TestBenchName
ProposeFractionLengthsForDefaultWordLength
DefaultWordLength
ProposeWordLengthsForDefaultFractionLength
DefaultFractionLength
DefaultSignedness
OptimizeWholeNumber
SafetyMargin
fimath
LaunchNumericTypesReport
LogIOForComparisonPlotting

ComputeSimulationRanges
ComputeDerivedRanges

        StaticAnalysisTimeoutMinutes;
        StaticAnalysisQuickMode;


FixPtFileNameSuffix

TestNumerics

PlotFunction

DetectFixptOverflows

TypesTable
HighlightPotentialDataTypeIssues
ProposeTargetContainerTypes
PlotWithSimulationDataInspector


ComputeCodeCoverage
    end

    properties(Dependent,SetObservable,AbortSet)
ProposeTypesUsing
    end

    properties(Dependent,Hidden)
OutputFileNameSuffix
    end

    properties(Hidden)
CodegenDirectory
CodegenWorkDirectory
DesignDirectory
OutputFilesDirectory
DesignFunctionName
GenCodeOnly
UserFunctionTemplatePath
GenerateComparisonPlots
SuppressErrorMessages
SimulationIterationLimit
FiCastFiVars
FiCastIntegerVars
FiCastDoubleLiteralVars
GenerateReport
LaunchReport
HardwareImplementation
F2FMexConfig


ConvertedInputFiTypesInfo




ConvertedInputFiTypes

DebugEnabled




InferTypesWithLogging


InputArgs


CodingForHDL
ProposeTypesMode


BasicBlockAnalysisIterations

EnableSDIPlotting

IncrementalConversion
GenerateParametrizedCode


LogHighlightPotentialDataTypeIssues



HistogramLogging


        UseSimulationRanges;
        UseDerivedRanges;

ConvertConstantsToFi

EmitTypesTable

UseF2FPrimitives
DoubleToSingle

EnableArrayOfStructures
EnableStaticAnalysisForNonScalar
ProposeAggregateStructureTypes



EmitSeperateFimathFunction

EnableMEXLogging
SupportMLXTestBench
    end

    properties(Hidden,Constant)
        AutoSignedness='Automatic';
        SignedSignedness='Signed';
        UnsignedSignedness='Unsigned';

        DefaultFixPtFileNameSuffix='_fixpt'

        DEFRM='Floor';
        DEFOA='Wrap';
        DEFAULTWORDLENGTH=14;
        DEFAULTFRACTIONLENGTH=4;
        SAFETYMARGIN=0;
        FIMATHSTR=['fimath(''RoundingMethod'', ''',coder.FixPtConfig.DEFRM,''', ''OverflowAction'', ''',coder.FixPtConfig.DEFOA,''', ''ProductMode'', ''FullPrecision'', ''MaxProductWordLength'', 128, ''SumMode'', ''FullPrecision'', ''MaxSumWordLength'', 128)'];

        MODE_C='C';
        MODE_HDL='HDL';
        MODE_FIXPT='FIXPT';
        MODE_MLFB='MLFB';
    end

    properties(Access='private')
proposeFractionLengthsForDefaultWL
proposeWordLengthsForDefaultFL




autoReplace


TransformForLoopIndexVariables


SearchPaths


fixedGlobalTypes
    end


    methods
        function value=get.ProposeFractionLengthsForDefaultWordLength(this)
            value=this.proposeFractionLengthsForDefaultWL;
        end
        function value=get.ProposeWordLengthsForDefaultFractionLength(this)
            value=this.proposeWordLengthsForDefaultFL;
        end

        function b=get.EmitTypesTable(this)
            b=this.EmitTypesTable||coder.FixPtConfig.TransformF2FInIR();
        end
    end
    methods
        function set.EnableMEXLogging(this,value)
            if value
                coder.internal.f2ffeature('MEXLOGGING',2);
            else
                coder.internal.f2ffeature('MEXLOGGING',0);
            end
            this.EnableMEXLogging=value;
        end

        function set.DesignFunctionName(this,value)
            propName='DesignFunctionName';
            if~isempty(value)&&~ischar(value)&&~iscell(value)
                throwError(this,propName,class(value),{class({}),class('')});
            end
            if isempty(value)
                value='';
            end
            this.(propName)=value;
        end


        function set.TestBenchName(this,value)
            value=convertStringsToChars(value);

            propName='TestBenchName';
            if~isempty(value)&&~ischar(value)&&~iscell(value)
                throwError(this,propName,class(value),{class({}),class('')});
            end
            if isempty(value)
                value='';
            end
            this.(propName)=value;
        end

        function set.CodegenDirectory(this,value)
            propName='CodegenDirectory';
            if~ischar(value)
                throwError(this,propName,class(value),class(''));
            end
            this.(propName)=value;
        end

        function set.ProposeFractionLengthsForDefaultWordLength(this,value)
            propName='ProposeFractionLengthsForDefaultWordLength';
            assert(isscalar(value),message('Coder:FxpConvDisp:FXPCONVDISP:ScalarValueExpected').getString());
            if~isReallyLogical(this,value)
                throwError(this,propName,class(value),class(0));
            end
            this.(propName)=value;
            this.proposeFractionLengthsForDefaultWL=value;
            this.proposeWordLengthsForDefaultFL=~value;
        end

        function set.DefaultWordLength(this,value)
            propName='DefaultWordLength';
            assert(isscalar(value),message('Coder:FxpConvDisp:FXPCONVDISP:ScalarValueExpected').getString());
            if~isa(value,'double')
                throwError(this,propName,class(value),class(0));
            end
            this.(propName)=value;
        end

        function set.ProposeWordLengthsForDefaultFractionLength(this,value)
            propName='ProposeWordLengthsForDefaultFractionLength';
            assert(isscalar(value),message('Coder:FxpConvDisp:FXPCONVDISP:ScalarValueExpected').getString());
            if~isReallyLogical(this,value)
                throwError(this,propName,class(value),class(0));
            end
            this.(propName)=value;
            this.proposeWordLengthsForDefaultFL=value;
            this.proposeFractionLengthsForDefaultWL=~value;
        end

        function set.DefaultFractionLength(this,value)
            propName='DefaultFractionLength';
            assert(isscalar(value),message('Coder:FxpConvDisp:FXPCONVDISP:ScalarValueExpected').getString());
            if~isa(value,'double')
                throwError(this,propName,class(value),class(0));
            end
            this.(propName)=value;
        end





        function set.SafetyMargin(this,value)
            propName='SafetyMargin';
            assert(isscalar(value),message('Coder:FxpConvDisp:FXPCONVDISP:ScalarValueExpected').getString())
            if~isa(value,'double')
                throwError(this,propName,class(value),class(0));
            end
            if value<=-100||isinf(value)||isnan(value)
                error(message('Coder:FXPCONV:invalidSafetyMargin'));
            end
            this.(propName)=value;
        end

        function set.fimath(this,value)

            propName='fimath';
            if ischar(value)||isstring(value)
                try
                    [~,fm]=evalc(value);
                catch ex
                    error(message('Coder:FXPCONV:IllegalFiMathStr','<a href="matlab: doc(''fimath'')">fimath</a>'));
                end

                if isstring(value)
                    value=strjoin(strsplit(strrep(fm.tostring,'...','')));
                end
            elseif isfimath(value)
                fm=value;
                value=strjoin(strsplit(strrep(fm.tostring,'...','')));
            else
                throwError(this,propName,class(value),class(''));
            end
            this.(propName)=value;
        end

        function set.StaticAnalysisTimeoutMinutes(this,value)
            propName='StaticAnalysisTimeoutMinutes';
            if~isnumeric(value)
                throwError(this,propName,class(value),'numeric');
            end
            this.(propName)=floor(value);
        end

        function set.StaticAnalysisQuickMode(this,value)
            propName='StaticAnalysisQuickMode';
            if~isReallyLogical(this,value)
                throwError(this,propName,class(value),class(true));
            end
            this.(propName)=value;
        end

        function set.ProposeTypesUsing(this,value)
            value=convertStringsToChars(value);

            propName='ProposeTypesUsing';
            if~ischar(value)
                throwError(this,propName,class(value),'char');
            end

            this.UseSimulationRanges=true;
            this.UseDerivedRanges=true;

            switch value
            case 'SimulationRanges',this.UseDerivedRanges=false;
            case 'DerivedRanges',this.UseSimulationRanges=false;
            case 'BothSimulationAndDerivedRanges'
            otherwise
                assert(false,message('Coder:FxpConvDisp:FXPCONVDISP:ValueMustBeOneOf',...
                '''SimulationRanges'' or ''DerivedRanges'' or ''BothSimulationAndDerivedRanges'''));
            end
        end

        function value=get.ProposeTypesUsing(this)
            if this.UseSimulationRanges&&this.UseDerivedRanges
                value='BothSimulationAndDerivedRanges';
            elseif this.UseSimulationRanges
                value='SimulationRanges';
            else
                value='DerivedRanges';
            end
        end

        function set.DefaultSignedness(this,value)
            switch value
            case coder.FixPtConfig.AutoSignedness
                this.DefaultSignedness=[];
            case coder.FixPtConfig.SignedSignedness
                this.DefaultSignedness=true;
            case coder.FixPtConfig.UnsignedSignedness
                this.DefaultSignedness=false;
            otherwise
                assert(false,message('Coder:FxpConvDisp:FXPCONVDISP:ValueMustBeOneOf',...
                ['',coder.FixPtConfig.AutoSignedness,' or ',coder.FixPtConfig.SignedSignedness,' or ',coder.FixPtConfig.UnsignedSignedness,'']));
            end
        end

        function val=get.DefaultSignedness(this)
            if isempty(this.DefaultSignedness)
                val=coder.FixPtConfig.AutoSignedness;
            elseif this.DefaultSignedness
                val=coder.FixPtConfig.SignedSignedness;
            else
                val=coder.FixPtConfig.UnsignedSignedness;
            end
        end

        function set.UseSimulationRanges(this,value)
            propName='UseSimulationRanges';
            assert(isscalar(value),message('Coder:FxpConvDisp:FXPCONVDISP:ScalarValueExpected').getString());
            if~isReallyLogical(this,value)
                throwError(this,propName,class(value),class(true));
            end
            this.(propName)=value;
        end

        function set.UseDerivedRanges(this,value)
            propName='UseDerivedRanges';
            assert(isscalar(value),message('Coder:FxpConvDisp:FXPCONVDISP:ScalarValueExpected').getString());
            if~isReallyLogical(this,value)
                throwError(this,propName,class(value),class(true));
            end
            this.(propName)=value;
        end

        function set.PlotWithSimulationDataInspector(this,value)
            propName='PlotWithSimulationDataInspector';
            assert(isscalar(value),message('Coder:FxpConvDisp:FXPCONVDISP:ScalarValueExpected').getString());
            if~isReallyLogical(this,value)
                throwError(this,propName,class(value),class(true));
            end
            this.(propName)=value;
            this.EnableSDIPlotting=value;%#ok<MCSUP>
        end

        function set.LaunchNumericTypesReport(this,value)
            propName='LaunchNumericTypesReport';
            assert(isscalar(value),message('Coder:FxpConvDisp:FXPCONVDISP:ScalarValueExpected').getString());
            if~isReallyLogical(this,value)
                throwError(this,propName,class(value),class(true));
            end
            this.(propName)=value;
        end

        function set.HighlightPotentialDataTypeIssues(this,value)
            propName='HighlightPotentialDataTypeIssues';
            assert(isscalar(value),message('Coder:FxpConvDisp:FXPCONVDISP:ScalarValueExpected').getString());
            if~isReallyLogical(this,value)
                throwError(this,propName,class(value),class(true));
            end
            this.(propName)=value;
        end

        function set.TransformForLoopIndexVariables(this,value)
            propName='TransformForLoopIndexVariables';
            assert(isscalar(value),message('Coder:FxpConvDisp:FXPCONVDISP:ScalarValueExpected').getString());
            if~isReallyLogical(this,value)
                throwError(this,propName,class(value),class(true));
            end
            this.(propName)=value;
        end

        function set.LogIOForComparisonPlotting(this,value)
            propName='LogIOForComparisonPlotting';
            assert(isscalar(value),message('Coder:FxpConvDisp:FXPCONVDISP:ScalarValueExpected').getString());
            if~isReallyLogical(this,value)
                throwError(this,propName,class(value),class(true));
            end
            this.(propName)=value;
        end

        function set.FixPtFileNameSuffix(this,value)
            value=convertStringsToChars(value);

            propName='FixPtFileNameSuffix';
            if isempty(value)
                throw(MException(message('Coder:FXPCONV:emptyFixPtSuffix')));
            end
            if~ischar(value)
                throwError(this,propName,class(value),class(''));
            end
            this.(propName)=value;
        end

        function set.TestNumerics(this,value)
            propName='TestNumerics';
            assert(isscalar(value),message('Coder:FxpConvDisp:FXPCONVDISP:ScalarValueExpected').getString());
            if~isReallyLogical(this,value)
                throwError(this,propName,class(value),class(true));
            end
            this.(propName)=value;
        end

        function set.PlotFunction(this,value)
            value=convertStringsToChars(value);

            propName='PlotFunction';
            if~isa(value,'function_handle')&&~isa(value,'char')&&~isempty(value)
                throwError(this,propName,class(value),'function_handle');
            end
            if ischar(value)


                [~,fileN,ext]=fileparts(value);
                if strcmp('.m',ext)
                    value=fileN;
                end
            end
            if ischar(value)&&~isempty(value)
                value=str2func(value);
            end
            this.(propName)=value;
        end

        function set.DetectFixptOverflows(this,value)
            propName='DetectFixptOverflows';
            assert(isscalar(value),message('Coder:FxpConvDisp:FXPCONVDISP:ScalarValueExpected').getString());
            if~isReallyLogical(this,value)
                throwError(this,propName,class(value),class(true));
            end
            this.(propName)=value;
        end

        function set.TypesTable(this,value)
            propName='TypesTable';

            if~isstruct(value)&&~isempty(value)
                throwError(this,propName,class(value),'struct');
            end
            this.(propName)=value;
        end

        function set.ProposeTypesMode(this,value)
            assert(any(strcmp({'HDL','C','FIXPT','MLFB'},value)),message('Coder:FxpConvDisp:FXPCONVDISP:ValueMustBeOneOf'...
            ,['''',coder.FixPtConfig.MODE_C,''', ''',coder.FixPtConfig.MODE_HDL,''' or ''',coder.FixPtConfig.MODE_FIXPT,'''',''' or ''',coder.FixPtConfig.MODE_MLFB,'''']));
            this.ProposeTypesMode=value;
        end

        function set.DoubleToSingle(this,value)
            propName='DoubleToSingle';
            assert(isscalar(value),message('Coder:FxpConvDisp:FXPCONVDISP:ScalarValueExpected').getString());
            if~isReallyLogical(this,value)
                throwError(this,propName,class(value),class(true));
            end
            this.(propName)=value;
        end

        function v=get.DoubleToSingle(this)
            propName='DoubleToSingle';
            v=this.(propName)||this.DoubleToSingleInFxpApp();
        end

        function v=get.FiCastIntegerVars(this)
            propName='FiCastIntegerVars';
            if this.DoubleToSingleInFxpApp()
                v=false;
            else
                v=this.(propName);
            end
        end

        function v=get.OutputFileNameSuffix(this)
            v=this.FixPtFileNameSuffix;
        end

        function set.OutputFileNameSuffix(this,value)
            propName='OutputFileNameSuffix';
            if isempty(value)
                throw(MException(message('Coder:FXPCONV:emptyOutputFilenameSuffix')));
            end
            if~ischar(value)
                throwError(this,propName,class(value),class(''));
            end
            this.FixPtFileNameSuffix=value;
        end
    end


    properties(Access='private')
fcnReplacements
typeSpec
designRangeMap
    end

    methods(Access='private')
        function throwError(~,propertyName,providedType,expectedTypes)
            if ischar(expectedTypes)
                expectedTypes={expectedTypes};
            end
            error(['Error setting property: ',propertyName,newline...
            ,' Type provided: ',providedType...
            ,', expected type: ',strjoin(expectedTypes,', ')]);
        end
    end

    methods
        function this=FixPtConfig(doubleToSingle)
            coderprivate.hasFixptPointDesignerLicense();
            if nargin==0
                doubleToSingle=false;
            end
            this.DesignFunctionName='';
            this.CodegenDirectory='';
            this.TestBenchName='';
            this.ProposeFractionLengthsForDefaultWordLength=true;
            this.DefaultWordLength=coder.FixPtConfig.DEFAULTWORDLENGTH;
            this.ProposeWordLengthsForDefaultFractionLength=false;
            this.DefaultFractionLength=coder.FixPtConfig.DEFAULTFRACTIONLENGTH;
            this.SafetyMargin=coder.FixPtConfig.SAFETYMARGIN;
            this.OptimizeWholeNumber=true;
            this.HistogramLogging=false;
            this.ComputeCodeCoverage=true;
            this.DefaultSignedness='Automatic';
            this.LaunchNumericTypesReport=false;
            this.HighlightPotentialDataTypeIssues=false;
            this.TransformForLoopIndexVariables=false;
            this.LogIOForComparisonPlotting=false;
            this.fimath=coder.FixPtConfig.FIMATHSTR;
            this.StaticAnalysisTimeoutMinutes=Inf;
            this.StaticAnalysisQuickMode=false;
            this.UseSimulationRanges=true;
            this.UseDerivedRanges=true;

            initHiddenPrivateProperties(this);

            this.ComputeDerivedRanges=false;
            this.FixPtFileNameSuffix=coder.FixPtConfig.DefaultFixPtFileNameSuffix;
            this.TestNumerics=false;
            this.PlotFunction='';
            this.DetectFixptOverflows=false;
            this.TypesTable=[];
            this.PlotWithSimulationDataInspector=false;

            function initHiddenPrivateProperties(this)
                this.CodegenWorkDirectory='';
                this.DesignDirectory='';
                this.OutputFilesDirectory='';
                this.DesignFunctionName='';
                this.GenCodeOnly=true;
                this.UserFunctionTemplatePath='';
                this.GenerateComparisonPlots=false;
                this.SuppressErrorMessages=true;
                this.SimulationIterationLimit=-1;
                this.FiCastFiVars=false;
                this.FiCastIntegerVars=true;
                this.FiCastDoubleLiteralVars=~coder.internal.f2ffeature('AnalyzeConstants');
                this.GenerateReport=false;
                this.LaunchReport=false;
                this.HardwareImplementation=coder.HardwareImplementation;

                this.F2FMexConfig=coder.MexCodeConfig;
                this.F2FMexConfig.EnableJIT=true;
                this.F2FMexConfig.ResponsivenessChecks=false;
                this.F2FMexConfig.GenerateComments=false;

                this.fcnReplacements=coder.internal.lib.Map();
                this.typeSpec=coder.internal.lib.Map();
                this.designRangeMap=coder.internal.lib.Map();


                this.ComputeSimulationRanges=true;
                this.ComputeDerivedRanges=false;

                this.ConvertedInputFiTypesInfo=[];

                this.DebugEnabled=false;
                this.InferTypesWithLogging=false;
                this.InputArgs={};
                this.CodingForHDL=true;
                this.ProposeTypesMode=coder.FixPtConfig.MODE_HDL;
                this.ProposeTargetContainerTypes=false;

                this.autoReplace=coder.internal.lib.Map.empty();
                this.BasicBlockAnalysisIterations=0;
                this.EnableSDIPlotting=false;
                this.IncrementalConversion=false;

                this.GenerateParametrizedCode=false;
                this.SearchPaths=[];

                this.LogHighlightPotentialDataTypeIssues=false;
                this.EmitTypesTable=false;

                this.ActiveDialog=[];
                this.UseF2FPrimitives=false;

                this.DoubleToSingle=doubleToSingle;

                this.fixedGlobalTypes={};

                this.EnableArrayOfStructures=true;
                this.EnableStaticAnalysisForNonScalar=coder.internal.f2ffeature('EnableNonScalarDerivedAnalaysis');
                this.ProposeAggregateStructureTypes=true;
                this.EmitSeperateFimathFunction=true;
                this.EnableMEXLogging=true;
                this.SupportMLXTestBench=true;
            end

            if this.DoubleToSingle
                this.OutputFileNameSuffix='_single';

                this.FiCastIntegerVars=0;
            end
        end


        function obj=copy(this)
            obj=this;
        end

        function clearApproximations(this)
            this.autoReplace=coder.internal.lib.Map.empty();
        end

        function addApproximation(this,autoRepCfg)
            assert(isa(autoRepCfg,'coder.internal.mathfcngenerator.Config'));

            a=coder.internal.mathfcngenerator.MathFunctionGenerator;
            name=autoRepCfg.getName();
            isInSupportedList=any(ismember(a.SupportedFcnList,name));
            isEmptyCandidateFcnForCustom=~isInSupportedList&&isempty(autoRepCfg.CandidateFunction);
            if(isEmptyCandidateFcnForCustom)
                disp(['### ',message('Coder:FXPCONV:MathFcnGenCandidateFcnNotProvided',name).getString()])
                autoRepCfg.CandidateFunction=str2func(name);
            end
            this.autoReplace(name)=autoRepCfg;
        end

        function addFunctionReplacement(this,fcn,replacement)
            [fcn,replacement]=convertStringsToChars(fcn,replacement);

            this.fcnReplacements(fcn)=replacement;
        end

        function removeFunctionReplacement(this,fcn)
            fcn=convertStringsToChars(fcn);

            this.fcnReplacements.remove(fcn);
        end

        function replacement=getFunctionReplacement(this,fcn)
            fcn=convertStringsToChars(fcn);

            if isKey(this.fcnReplacements,fcn)
                replacement=this.fcnReplacements(fcn);
            else
                replacement='';
            end
        end

        function clearFunctionReplacements(this)
            this.fcnReplacements.clear();
        end

        function res=hasFunctionReplacement(this,fcn)
            fcn=convertStringsToChars(fcn);

            if isKey(this.fcnReplacements,fcn)
                res=true;
            else
                res=false;
            end
        end

        function addTypeSpecification(this,arg2,arg3,arg4)
            [arg2,arg3,arg4]=convertStringsToChars(arg2,arg3,arg4);

            if nargin==3
                assert(isa(arg2,'char'),'second argument should be the qualified name of a variable');
                s=strsplit(arg2,'.');
                assert(length(s)>=2,'second argument should be the qualified name of a variable');

                fcn=s{1};
                varName=strjoin(s(2:end),'.');
                type=arg3;
            else
                fcn=arg2;
                varName=arg3;
                type=arg4;
            end

            tSpec=coder.FixPtTypeSpec;
            if isa(type,'embedded.fi')
                tSpec.ProposedType=numerictype(type);
                type=type.fimath;
            elseif isa(type,'embedded.numerictype')
                tSpec.ProposedType=type;
                type=[];
            end

            if isa(type,'embedded.fimath')
                tSpec.OverflowAction=type.OverflowAction;
                tSpec.RoundingMethod=type.RoundingMethod;
                type=[];
            end

            if~isempty(type)
                tSpec=type;
            end

            assert(isa(tSpec,'coder.FixPtTypeSpec'),...
            'typeSpec should be of type ''coder.FixPtTypeSpec''');
            if isa(tSpec.ProposedType,'embedded.numerictype')
                tSpec.ProposedType=coder.internal.getNumericTypeStr(tSpec.ProposedType);
            end

            if~isKey(this.typeSpec,fcn)
                fcnVarTypeSpecMap=coder.internal.lib.Map();
                fcnVarTypeSpecMap(varName)=tSpec;
                this.typeSpec(fcn)=fcnVarTypeSpecMap;
            else
                fcnVarTypeSpecMap=this.typeSpec(fcn);
                fcnVarTypeSpecMap(varName)=tSpec;
                this.typeSpec(fcn)=fcnVarTypeSpecMap;
            end
        end

        function clearTypeSpecifications(this)
            this.typeSpec.clear();
        end

        function spec=getTypeSpecification(this,functionName,varName)
            [functionName,varName]=convertStringsToChars(functionName,varName);

            if isKey(this.typeSpec,functionName)
                fcnTypeSpecMap=this.typeSpec(functionName);
                if isempty(fcnTypeSpecMap)
                    spec=[];
                    return
                end
                if fcnTypeSpecMap.isKey(varName)
                    spec=fcnTypeSpecMap(varName);
                else
                    spec=[];
                end
            else
                spec=[];
            end
        end

        function res=hasTypeSpecification(this,fcn,varName)
            [fcn,varName]=convertStringsToChars(fcn,varName);

            res=false;
            if isKey(this.typeSpec,fcn)
                typeSpecMap=this.typeSpec(fcn);
                if isKey(typeSpecMap,varName)
                    res=true;
                end
            end
        end


        function removeTypeSpecification(this,fcn,varName)
            [fcn,varName]=convertStringsToChars(fcn,varName);

            if isKey(this.typeSpec,fcn)
                typeSpecMap=this.typeSpec(fcn);
                if~isempty(typeSpecMap)
                    typeSpecMap.remove(varName);
                end
            else
                return;
            end
        end

        function addDesignRangeSpecification(this,fcnName,varName,designMin,designMax)
            [fcnName,varName]=convertStringsToChars(fcnName,varName);

            assert(isnumeric(designMin)&&~any(isinf(abs(designMin))),'Incorrect type for design min.');
            assert(isnumeric(designMax)&&~any(isinf(abs(designMax))),'Incorrect type for design max.');
            if~isempty(designMin)&&~isempty(designMax)

            end
            designRange.DesignMin=designMin;
            designRange.DesignMax=designMax;
            if isKey(this.designRangeMap,fcnName)
                fcnDesignRangeMap=this.designRangeMap(fcnName);
                fcnDesignRangeMap(varName)=designRange;
                this.designRangeMap(fcnName)=fcnDesignRangeMap;
            else
                varMap=coder.internal.lib.Map();
                varMap(varName)=designRange;
                this.designRangeMap(fcnName)=varMap;
            end
        end

        function[designMin,designMax]=getDesignRangeSpecification(this,fcnName,varName)
            [fcnName,varName]=convertStringsToChars(fcnName,varName);

            designMin=[];
            designMax=[];
            if isKey(this.designRangeMap,fcnName)
                fcnDesignRangeMap=this.designRangeMap(fcnName);
                if isKey(fcnDesignRangeMap,varName)
                    designRange=fcnDesignRangeMap(varName);
                    designMin=designRange.DesignMin;
                    designMax=designRange.DesignMax;
                end
            end
        end

        function res=hasDesignRangeSpecification(this,fcnName,varName)
            [fcnName,varName]=convertStringsToChars(fcnName,varName);

            if isKey(this.designRangeMap,fcnName)
                fcnVarDesignRangeMap=this.designRangeMap(fcnName);
                res=isKey(fcnVarDesignRangeMap,varName);
            else
                res=false;
            end
        end

        function clearDesignRangeSpecifications(this)

            this.designRangeMap.remove(this.designRangeMap.keys);
        end

        function removeDesignRangeSpecification(this,fcnName,varName)
            [fcnName,varName]=convertStringsToChars(fcnName,varName);

            if isKey(this.designRangeMap,fcnName)
                fcnVarDesignRangeMap=this.designRangeMap(fcnName);
                fcnVarDesignRangeMap.remove(varName);
            end
        end

        function disp(this)
            generalList={'CodegenDirectory'...
            ,'TestBenchName'};

            simulationRangeAnalysisList={'ComputeSimulationRanges'...
            ,'ComputeCodeCoverage'};

            derivedRangeAnalysisList={'ComputeDerivedRanges'...
            ,'StaticAnalysisTimeoutMinutes'...
            ,'StaticAnalysisQuickMode'};

            typeProposalList={'ProposeFractionLengthsForDefaultWordLength'...
            ,'DefaultWordLength'...
            ,'ProposeWordLengthsForDefaultFractionLength'...
            ,'DefaultFractionLength'...
            ,'ProposeTypesUsing'...
            ,'ProposeTargetContainerTypes'...
            ,'OptimizeWholeNumber'...
            ,'DefaultSignedness'...
            ,'SafetyMargin'...
            ,'fimath'...
            ,'LaunchNumericTypesReport'};
            fixedPtConvList={'FixPtFileNameSuffix'...
            ,'HighlightPotentialDataTypeIssues'};

            fixedPtVerificationList={'TestNumerics'...
            ,'LogIOForComparisonPlotting'...
            ,'PlotFunction'...
            ,'PlotWithSimulationDataInspector'...
            ,'DetectFixptOverflows'};


            list={generalList{:},simulationRangeAnalysisList{:},derivedRangeAnalysisList{:},typeProposalList{:},fixedPtConvList{:},fixedPtVerificationList{:}};%#ok<CCAT>

            paddedList=rightPad(list);

            generalList=paddedList(1:length(generalList));
            paddedList(1:length(generalList))=[];

            simulationRangeAnalysisList=paddedList(1:length(simulationRangeAnalysisList));
            paddedList(1:length(simulationRangeAnalysisList))=[];

            derivedRangeAnalysisList=paddedList(1:length(derivedRangeAnalysisList));
            paddedList(1:length(derivedRangeAnalysisList))=[];

            typeProposalList=paddedList(1:length(typeProposalList));
            paddedList(1:length(typeProposalList))=[];

            fixedPtConvList=paddedList(1:length(fixedPtConvList));
            paddedList(1:length(fixedPtConvList))=[];






            fixedPtVerificationList=paddedList(1:length(fixedPtVerificationList));
            paddedList(1:length(fixedPtVerificationList))=[];%#ok<NASGU>

            disp('Description: ''class FixPtConfig: Fixed-Point configuration objects.''');
            disp('Name: ''FixPtConfig''');
            disp(' ');

            disp('-------------------------------- General ------------------------------');
            disp(' ');
            cellfun(@(prop)printProperty(prop)...
            ,generalList);
            disp(' ');

            disp('---------------------- Simulation Range Analysis ----------------------');
            disp(' ');
            cellfun(@(prop)printProperty(prop)...
            ,simulationRangeAnalysisList);
            disp(' ');

            disp('------------------------ Derived Range Analysis -----------------------');
            disp(' ');
            cellfun(@(prop)printProperty(prop)...
            ,derivedRangeAnalysisList);
            disp(' ');

            disp('----------------------- Fixed-Point Type Proposal ---------------------');
            disp(' ');
            cellfun(@(prop)printProperty(prop)...
            ,typeProposalList);
            disp(' ');

            disp('---------------------- Fixed-Point Type Conversion --------------------');
            disp(' ');
            cellfun(@(prop)printProperty(prop)...
            ,fixedPtConvList);
            disp(' ');










            disp('----------------------- Fixed-Point Verification ----------------------');
            disp(' ');
            cellfun(@(prop)printProperty(prop)...
            ,fixedPtVerificationList);

            disp(' ');

            function printProperty(propName)
                propVal=this.(strtrim(propName));
                strPropVal=to_str(propVal);
                if ischar(propVal)
                    strPropVal=['''',strPropVal,''''];
                elseif isempty(propVal)
                    strPropVal='[]';
                end
                disp([propName,': ',strPropVal]);

                function res=to_str(val)
                    if iscell(val)
                        strCellVals=cellfun(@(v)to_str(v)...
                        ,val...
                        ,'UniformOutput',false);
                        res=strjoin(strCellVals,' ,');
                    elseif isnumeric(val)
                        res=num2str(val);
                    elseif ischar(val)
                        res=val;
                    elseif isa(val,'function_handle')
                        res=['@',func2str(val)];
                    elseif this.isReallyLogical(val)
                        res=logical2str(val);
                    else
                        error('unknown type');
                    end
                end

                function ret=logical2str(val)
                    if islogical(val)
                        if val
                            ret='true';
                        else
                            ret='false';
                        end
                    else
                        error('expecting logical input');
                    end
                end
            end

            function paddedList=rightPad(strList)
                paddedList=cell(1,length(strList));
                maxLength=max(cellfun(@(str)length(str),strList));
                for ii=1:length(strList)
                    str=strList{ii};
                    paddedList{ii}=[repmat(' ',1,maxLength-length(str)),str];
                end
            end
        end




        function dialog(this)
            if~usejava('jvm')
                error(message('Coder:FXPCONV:JvmRequiredForConfigDialog'));
            end


            function handleJavaPropertyChange(~,event)

                prop=char(event.getPropertyName());

                if~isprop(this,prop)

                    prop=[lower(prop(1)),prop(2:numel(prop))];

                    if~isprop(this,prop)
                        return;
                    end
                end

                this.(prop)=event.getNewValue();
            end


            function pushChangeToJava(localField,javaHandle,remoteSetterName)
                javaValue=this.(localField);
                if~isempty(javaValue)&&strcmp(class(javaValue),'function_handle')
                    javaValue=char(javaValue);
                end

                try
                    javaMethodEDT(remoteSetterName,javaHandle,javaValue);
                catch ex
                    if isempty(javaValue)
                        javaMethodEDT(remoteSetterName,javaHandle,0);
                    end
                end
            end


            function performCleanup(javaHandle,listeners)

                if~ismethod(javaHandle,'dispose')
                    return;
                end


                javaHandle.dispose();
                this.ActiveDialog=[];

                set(javaHandle,'PropertyChangeCallback',[]);
                set(javaHandle,'BoundObjectDisposedCallback',[]);
                cellfun(@(x)delete(x),listeners);
                delete(javaHandle);
            end


            if~isempty(this.ActiveDialog)
                this.ActiveDialog.show();
                return;
            end

            import('com.mathworks.toolbox.coder.fixedpoint.config.ConfigDialog');


            javaConfigPeer=ConfigDialog.showFixedPointConfigDialog();

            peerHandle=handle(javaConfigPeer,'CallbackProperties');


            localProperties=properties(this);
            listeners=cell(numel(localProperties)+1,1);


            for i=1:numel(localProperties)
                localProperty=char(localProperties(i));
                remoteSetter=['set',localProperty];
                if ismethod(javaConfigPeer,remoteSetter)
                    appliedPush=@(~,~)pushChangeToJava(localProperty,peerHandle,remoteSetter);
                    listeners{i}=addlistener(this,localProperty,'PostSet',appliedPush);

                    appliedPush();
                else
                    warning('Incorrect mapping for config property in bean');
                end
            end

            javaConfigPeer.markCurrentStateAsDefault();
            set(peerHandle,'PropertyChangeCallback',@handleJavaPropertyChange);


            appliedCleanup=@(~,~)performCleanup(peerHandle,listeners);
            set(peerHandle,'BoundObjectDisposedCallback',appliedCleanup);
            listeners{end}=addlistener(this,'ObjectBeingDestroyed',appliedCleanup);%#ok<NASGU> 

            this.ActiveDialog=peerHandle;
        end
    end

    properties(Access='private')
        ActiveDialog;
    end

    methods(Hidden)
        function fld=getRelativeBuildDirectory(~)
            fld='fixpt';
        end


        function cfg=transferDesignRangeSpecifications(this,cfg)
            fcns=this.designRangeMap.keys;
            for ii=1:length(fcns)
                fcn=fcns{ii};
                varMap=this.designRangeMap(fcn);
                cellfun(@(var)cfg.addDesignRangeSpecification(fcn,...
                var,...
                copyToInternalDesignRange(varMap.get(var))),...
                varMap.keys);
            end

            function internalDesignRange=copyToInternalDesignRange(designRange)
                internalDesignRange=coder.InternalDesignRange(designRange.DesignMin,designRange.DesignMax);
            end
        end



        function to_script(this,fileName)
            fileName=convertStringsToChars(fileName);

            templateDir=fileparts(which('coder.FixPtConfig'));
            templatePath=fullfile(templateDir,'config.m.eml');


            obj=this;%#ok<NASGU>
            code=coder.internal.tools.TML.render(templatePath);

            [outDir,name,~]=fileparts(fileName);
            if isempty(outDir)
                outDir=pwd;
            end
            coder.internal.Helper.createMATLABFile(outDir,name,code)
        end


        function closeDialog(this)
            if~isempty(this.ActiveDialog)
                this.ActiveDialog.dispose();
            end
        end
    end

    methods(Access='protected')


        function specMap=getTypeSpecMapForFcn(this,functionName)
            if isKey(this.typeSpec,functionName)
                specMap=this.typeSpec(functionName);
            else
                specMap=coder.internal.lib.Map();
            end
        end

        function designRngMap=getDesignRangeMapForFcn(this,functionName)
            if isKey(this.designRangeMap,functionName)
                designRngMap=this.designRangeMap(functionName);
            else
                designRngMap=coder.internal.lib.Map();
            end
        end


        function res=isReallyLogical(~,value)
            res=false;
            if iscell(value)
                return;
            end
            res=islogical(value)||all(value==1)||all(value==0);
        end
    end

    methods(Hidden)


        function val=getSearchPaths(this)
            val=this.SearchPaths;
        end


        function setSearchPaths(this,val)
            this.SearchPaths=val;
        end

        function res=getMathFcnConfigs(this)
            res=this.autoReplace;
        end

        function replacementMap=getFunctionReplacementMap(this)
            replacementMap=this.fcnReplacements;
        end
        function fcnList=getTypeSpecifiedFunctions(this)
            fcnList=this.typeSpec.keys;
        end

        function fcnList=getDesignSpecifiedFunctions(this)
            fcnList=this.designRangeMap.keys;
        end

        function varList=getDesignSpecifiedVars(this,fcnName)
            fcnName=convertStringsToChars(fcnName);

            varList={};
            if nargin<=1
                fcnName=[];
            end
            if isempty(fcnName)
                varCellByFcnName=cellfun(@(fcn)this.getDesignRangeMapForFcn(fcn),...
                this.getDesignSpecifiedFunctions);
                varList=coder.internal.lib.ListHelper.flatten(varCellByFcnName);
            else
                specMap=this.getDesignRangeMapForFcn(fcnName);
                if~specMap.isempty
                    varList=specMap.keys;
                end
            end
        end

        function varList=getTypeSpecifiedVars(this,fcnName)
            fcnName=convertStringsToChars(fcnName);

            varList={};
            if nargin<=1
                fcnName=[];
            end
            if isempty(fcnName)
                varCellByFcnName=cellfun(@(fcn)this.getTypeSpecForFcn(fcn),...
                this.getTypeSpecifiedFunctions);
                varList=coder.internal.lib.ListHelper.flatten(varCellByFcnName);
            else
                specMap=this.getTypeSpecMapForFcn(fcnName);
                if~specMap.isempty
                    varList=specMap.keys;
                end
            end
        end

        function setFixedGlobalTypes(this,val)
            this.fixedGlobalTypes=val;
        end

        function fxpGlobalTypes=getFixedGlobalTypes(this)
            fxpGlobalTypes=this.fixedGlobalTypes;
        end


        function res=isNonScalarSupportedForDVO(this)
            res=this.EnableStaticAnalysisForNonScalar;
        end

        function replacements=getAllFunctionReplacements(this)
            replacements=this.fcnReplacements.copy();
        end
    end

    properties(Constant,Hidden)
        FixptODS_None=0
        FixptODS_ScaledDoubleInFixedPointCode=1;
        FixptODS_DataTypeOverride=2;
        FixptODS_FiCastFunction=3;
    end

    methods(Static,Hidden)
        function out=FixptOverflowDetectionStrategy(in)
            persistent pStrategy;
            mlock;
            if isempty(pStrategy)
                pStrategy=coder.FixPtConfig.FixptODS_DataTypeOverride;
            end
            if nargin==1
                pStrategy=in;
            end
            out=pStrategy;
        end
    end
    methods(Static,Hidden)
        function b=TransformF2FInIR(in)
            mlock;
            persistent hIRF2F
            if isempty(hIRF2F)
                hIRF2F=false;
            end
            if nargin==1&&~isempty(in)
                hIRF2F=logical(in);
            end
            b=hIRF2F;
        end

        function b=DoubleToSingleInFxpApp(in)
            mlock;
            persistent hDTS
            if isempty(hDTS)
                hDTS=false;
            end
            if nargin==1&&~isempty(in)
                hDTS=logical(in);
            end
            b=hDTS;
        end
    end

end

