classdef ProposalSettings<matlab.mixin.CustomDisplay




























    properties(Dependent)
        ProposeWordLength;
        ProposeFractionLength;
        ProposeSignedness;
        ProposeForInherited;
        ProposeForFloatingPoint;
        SafetyMargin;
        UseSimMinMax;
        UseDerivedMinMax;
        DefaultWordLength;
        DefaultFractionLength;
    end



    properties(Dependent,Hidden)
        ProposeWordLengthsForDefaultFractionLength;
        ProposeFractionLengthsForDefaultWordLength;
        SimSafetyMargin;
        FloatingPointDefaultDataType;
        scaleUsingRunName;
    end


    properties(Access={?fxptui.Web.CallbackService.ProposeHandler,?DataTypeWorkflowTestCase})
        AutoscalerProposalSettings SimulinkFixedPoint.AutoscalerProposalSettings;


        FloatingPointDefaultDataType_;
    end

    properties(Hidden)
        ExecuteConditionalProposal logical;
    end

    properties(Access={?fxpOptimizationOptions})
        optimizationOptions;
    end

    methods
        function obj=ProposalSettings()
            obj.AutoscalerProposalSettings=SimulinkFixedPoint.AutoscalerProposalSettings;
            obj.FloatingPointDefaultDataType_=getString(message('FixedPointTool:fixedPointTool:defaultDTRemainFlt'));
            obj.optimizationOptions=fxpOptimizationOptions();
            obj.ExecuteConditionalProposal=false;
        end

        function addTolerance(this,blockPath,portIndex,tolType,tolValue)
































            validateattributes(blockPath,{'char','string'},{'nonempty'});

            ph=get_param(blockPath,'PortHandles');
            numOutports=numel(ph.Outport);


            validateattributes(portIndex,{'numeric'},{'scalar','nonnegative','real','finite','integer','>=',1,'<=',numOutports});










            signalLogging=get_param(ph.Outport(portIndex),'DataLogging');
            if strcmp(signalLogging,'off')
                errorMessage=message('FixedPointTool:fixedPointTool:SignalWithLoggingOff',blockPath,num2str(portIndex));
                exception=MException(errorMessage.Identifier,errorMessage.getString);
                throw(exception);
            end



            addTolerance(this.optimizationOptions,blockPath,portIndex,tolType,tolValue);

        end

        function showTolerances(this)












            showTolerances(this.optimizationOptions);
        end

        function clearTolerances(this)














            this.optimizationOptions.clearTolerances();
        end


        function value=get.ProposeWordLength(this)
            value=this.AutoscalerProposalSettings.isWLSelectionPolicy;
        end
        function this=set.ProposeWordLength(this,value)
            this.AutoscalerProposalSettings.isWLSelectionPolicy=logical(value);
        end


        function value=get.ProposeFractionLength(this)
            value=~this.AutoscalerProposalSettings.isWLSelectionPolicy;
        end
        function this=set.ProposeFractionLength(this,value)
            this.AutoscalerProposalSettings.isWLSelectionPolicy=~logical(value);
        end


        function value=get.ProposeSignedness(this)
            value=this.AutoscalerProposalSettings.isAutoSignedness;
        end
        function this=set.ProposeSignedness(this,value)
            this.AutoscalerProposalSettings.isAutoSignedness=logical(value);
        end


        function value=get.ProposeForInherited(this)
            value=this.AutoscalerProposalSettings.ProposeForInherited;
        end
        function this=set.ProposeForInherited(this,value)
            this.AutoscalerProposalSettings.ProposeForInherited=logical(value);
        end


        function value=get.ProposeForFloatingPoint(this)
            value=this.AutoscalerProposalSettings.ProposeForFloatingPoint;
        end
        function this=set.ProposeForFloatingPoint(this,value)
            this.AutoscalerProposalSettings.ProposeForFloatingPoint=logical(value);
        end


        function value=get.SafetyMargin(this)
            value=this.AutoscalerProposalSettings.SafetyMarginForSimMinMax;
        end
        function this=set.SafetyMargin(this,value)
            this.AutoscalerProposalSettings.SafetyMarginForSimMinMax=value;
        end


        function value=get.UseSimMinMax(this)
            value=this.AutoscalerProposalSettings.isUsingSimMinMax;
        end
        function this=set.UseSimMinMax(this,value)
            this.AutoscalerProposalSettings.isUsingSimMinMax=logical(value);
        end


        function value=get.UseDerivedMinMax(this)
            value=this.AutoscalerProposalSettings.isUsingDerivedMinMax;
        end
        function this=set.UseDerivedMinMax(this,value)
            this.AutoscalerProposalSettings.isUsingDerivedMinMax=logical(value);
        end


        function value=get.DefaultWordLength(this)
            value=this.AutoscalerProposalSettings.DefaultWordLength;
        end
        function this=set.DefaultWordLength(this,value)
            this.AutoscalerProposalSettings.DefaultWordLength=value;
        end


        function value=get.DefaultFractionLength(this)
            value=this.AutoscalerProposalSettings.DefaultFractionLength;
        end
        function this=set.DefaultFractionLength(this,value)
            this.AutoscalerProposalSettings.DefaultFractionLength=value;
        end


        function value=get.scaleUsingRunName(this)
            value=this.AutoscalerProposalSettings.scaleUsingRunName;
        end
        function this=set.scaleUsingRunName(this,value)
            this.AutoscalerProposalSettings.scaleUsingRunName=value;
        end




        function value=get.ProposeWordLengthsForDefaultFractionLength(this)
            value=this.AutoscalerProposalSettings.isWLSelectionPolicy;
        end
        function this=set.ProposeWordLengthsForDefaultFractionLength(this,value)
            this.AutoscalerProposalSettings.isWLSelectionPolicy=logical(value);
        end


        function value=get.ProposeFractionLengthsForDefaultWordLength(this)

            value=~this.AutoscalerProposalSettings.isWLSelectionPolicy;
        end
        function this=set.ProposeFractionLengthsForDefaultWordLength(this,value)


            this.AutoscalerProposalSettings.isWLSelectionPolicy=~logical(value);
        end


        function value=get.SimSafetyMargin(this)
            value=this.AutoscalerProposalSettings.SafetyMarginForSimMinMax;
        end
        function this=set.SimSafetyMargin(this,value)
            this.AutoscalerProposalSettings.SafetyMarginForSimMinMax=value;
        end


        function value=get.FloatingPointDefaultDataType(this)
            value=this.FloatingPointDefaultDatatype_;
        end
        function this=set.FloatingPointDefaultDataType(this,value)
            validateType(value,'char');
            this.FloatingPointDefaultDataType_=value;


            dtContainerInfo=SimulinkFixedPoint.DTContainerInfo(value,[]);
            if~isempty(dtContainerInfo.evaluatedNumericType)
                dt=dtContainerInfo.evaluatedNumericType;
                this.AutoscalerProposalSettings.DefaultFractionLength=dt.FractionLength;
                this.AutoscalerProposalSettings.DefaultWordLength=dt.WordLength;
            end
        end
    end

    methods(Access=protected,Hidden)

        function group=getPropertyGroups(~)

            group(1)=matlab.mixin.util.PropertyGroup({'ProposeSignedness','ProposeWordLength','ProposeFractionLength','ProposeForInherited','ProposeForFloatingPoint','UseSimMinMax','UseDerivedMinMax'},'Proposal Specifications');
            group(2)=matlab.mixin.util.PropertyGroup({'SafetyMargin'},'Safety margin (%) for simulation minimum and maximum values');
            group(3)=matlab.mixin.util.PropertyGroup({'DefaultWordLength','DefaultFractionLength'},'Defaults for floating-point and inherited types');
        end

        function footer=getFooter(obj)

            var=inputname(1);
            footer='';
            if feature('hotlinks')
                if~isempty(var)&&~isempty(obj.optimizationOptions.Constraints)
                    footer=sprintf(...
                    '\tUse the <a href="matlab: if exist(''%s'', ''var'') && isa(%s, ''DataTypeWorkflow.ProposalSettings''),  DataTypeWorkflow.hyperlink(%s); end">showTolerances</a> method to view the added tolerances.',var,var,var);
                end
            end
        end
    end

    methods(Hidden)
        function value=getSettings(this)
            value=this.AutoscalerProposalSettings;
        end

        function value=getOptimizationOptions(this)
            value=this.optimizationOptions;
        end

    end

end

function validateType(value,type)
    p=inputParser;
    p.addRequired('value',@(x)validateattributes(x,{type},{'nonempty'}));
    try
        p.parse(value);
    catch e
        throwAsCaller(e);
    end
end
