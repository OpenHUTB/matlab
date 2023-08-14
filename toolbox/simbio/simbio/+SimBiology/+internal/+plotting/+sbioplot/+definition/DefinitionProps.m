classdef DefinitionProps<matlab.mixin.SetGet

    properties(Access=public)
        UnitConversion=false;
    end




    methods(Access=public)
        function obj=DefinitionProps(input)

            if nargin>0&&~isempty(input)
                obj.configureSingleObjectFromStruct(input);
            end
        end

        function info=getStruct(obj)
            info=struct('UnitConversion',obj.UnitConversion);
        end
    end

    methods(Access=?SimBiology.internal.plotting.sbioplot.definition.DefinitionProps)
        function configureSingleObjectFromStruct(obj,input)
            set(obj,'UnitConversion',input.UnitConversion);
        end

        function params=importUseStruct(obj,input)
            if isempty(input)
                params=obj.getDefaultUseStruct({});
            else
                params=input;
            end
        end

        function updatedUseStruct=updateUseStruct(obj,names,oldUseStruct)
            updatedUseStruct=obj.getDefaultUseStruct(names);

            anyUsed=false;

            for i=1:numel(updatedUseStruct)
                for j=1:numel(oldUseStruct)
                    if strcmp(updatedUseStruct(i).name,oldUseStruct(j).name)
                        updatedUseStruct(i).use=oldUseStruct(j).use;
                        break;
                    end
                end
                anyUsed=anyUsed||updatedUseStruct(i).use;
            end



            if~anyUsed
                [updatedUseStruct.use]=deal(true);
            end
        end
    end

    methods(Access=protected,Static)
        function params=getDefaultUseStruct(names)
            if numel(names)>0
                params=cellfun(@(n)struct('name',n,'use',true),names);
            else
                params=struct('name',{},'use',{});
            end
        end
    end


    methods(Access=public,Static)
        function obj=constructDefinitionProps(plotStyle,input)
            if nargin==1
                input=[];
            end
            import SimBiology.internal.plotting.sbioplot.definition.*;
            switch(plotStyle)
            case{PlotDefinition.ACTUAL_VS_PREDICTED}
                obj=SimBiology.internal.plotting.sbioplot.definition.ActualVsPredictedDefinitionProps(input);
            case{PlotDefinition.BOX}
                obj=SimBiology.internal.plotting.sbioplot.definition.BoxPlotDefinitionProps(input);
            case{PlotDefinition.CONFIDENCE_INTERVAL}
                obj=SimBiology.internal.plotting.sbioplot.definition.ConfidenceIntervalDefinitionProps(input);
            case{PlotDefinition.FIT}
                obj=SimBiology.internal.plotting.sbioplot.definition.FitPlotDefinitionProps(input);
            case{PlotDefinition.GSA_BAR}
                obj=SimBiology.internal.plotting.sbioplot.definition.GSABarDefinitionProps(input);
            case{PlotDefinition.GSA_ECDF}
                obj=SimBiology.internal.plotting.sbioplot.definition.GSAECDFDefinitionProps(input);
            case{PlotDefinition.GSA_HISTOGRAM}
                obj=SimBiology.internal.plotting.sbioplot.definition.GSAHistogramDefinitionProps(input);
            case{PlotDefinition.GSA_PARAMETER_GRID}
                obj=SimBiology.internal.plotting.sbioplot.definition.GSAParameterGridDefinitionProps(input);
            case{PlotDefinition.GSA_TIME}
                obj=SimBiology.internal.plotting.sbioplot.definition.GSATimeDefinitionProps(input);
            case{PlotDefinition.PERCENTILE}
                obj=SimBiology.internal.plotting.sbioplot.definition.TimePercentileDefinitionProps(input);
            case{PlotDefinition.PERCENTILE_XY}
                obj=SimBiology.internal.plotting.sbioplot.definition.XYPercentileDefinitionProps(input);
            case{PlotDefinition.PLOTMATRIX}
                obj=SimBiology.internal.plotting.sbioplot.definition.PlotMatrixDefinitionProps(input);
            case{PlotDefinition.RESIDUAL_DISTRIBUTION}
                obj=SimBiology.internal.plotting.sbioplot.definition.ResidualDistributionDefinitionProps(input);
            case{PlotDefinition.RESIDUALS}
                obj=SimBiology.internal.plotting.sbioplot.definition.ResidualsDefinitionProps(input);
            case{PlotDefinition.SENSITIVITY}
                obj=SimBiology.internal.plotting.sbioplot.definition.SensitivityDefinitionProps(input);
            case{PlotDefinition.TIME}
                obj=SimBiology.internal.plotting.sbioplot.definition.TimeLineDefinitionProps(input);
            case{PlotDefinition.XY}
                obj=SimBiology.internal.plotting.sbioplot.definition.XYLineDefinitionProps(input);
            otherwise
                obj=SimBiology.internal.plotting.sbioplot.definition.DefinitionProps(input);
            end
        end
    end

end