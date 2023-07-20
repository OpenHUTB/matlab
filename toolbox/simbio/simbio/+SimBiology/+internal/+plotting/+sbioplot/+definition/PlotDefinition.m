classdef PlotDefinition<matlab.mixin.SetGet




    properties(Constant)
        ACTUAL_VS_PREDICTED='actual_vs_predicted';
        ANY='any';
        BOX='box';
        CONFIDENCE_INTERVAL='confidenceInterval';
        FIT='fit';
        GSA_BAR='gsa_bar';
        GSA_ECDF='gsa_ecdf';
        GSA_HISTOGRAM='gsa_histogram';
        GSA_PARAMETER_GRID='gsa_parameter_grid';
        GSA_TIME='gsa_time';
        PERCENTILE='percentile';
        PERCENTILE_XY='percentile_xy';
        PLOTMATRIX='plotMatrix';
        RESIDUAL_DISTRIBUTION='residual_distribution';
        RESIDUALS='residuals';
        SENSITIVITY='sensitivity';
        TIME='time';
        XY='xy';
    end

    properties(Access=public)
        plotStyle='';
        plotArguments=SimBiology.internal.plotting.sbioplot.PlotArgument.empty;
        props=SimBiology.internal.plotting.sbioplot.definition.DefinitionProps;
    end




    methods(Access=public)
        function obj=PlotDefinition(input)

            if nargin>0
                if isstruct(input)
                    obj.configureSingleObjectFromStruct(input);
                else
                    obj.props=SimBiology.internal.plotting.sbioplot.definition.DefinitionProps.constructDefinitionProps(input);
                end
            end
        end

        function info=getStruct(obj)
            info=struct('plotStyle',obj.plotStyle,...
            'plotArguments',obj.plotArguments.getStruct(),...
            'props',obj.props.getStruct());
        end
    end

    methods(Access=?SimBiology.internal.plotting.sbioplot.definition)
        function configureSingleObjectFromStruct(obj,input)
            set(obj,'plotStyle',input.plotStyle,...
            'plotArguments',SimBiology.internal.plotting.sbioplot.PlotArgument(input.plotArguments),...
            'props',SimBiology.internal.plotting.sbioplot.definition.DefinitionProps.constructDefinitionProps(input.plotStyle,input.props));
        end
    end

    methods(Access=public)
        function setProperty(obj,property,value)
            set(obj.props,property,value);
        end

        function value=getProperty(obj,property)
            value=get(obj.props,property);
        end
    end
end