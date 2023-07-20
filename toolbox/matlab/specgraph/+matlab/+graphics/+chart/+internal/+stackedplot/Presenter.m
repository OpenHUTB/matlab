classdef Presenter<handle




    properties(Dependent)

XData
YData
SourceTable
DisplayVariables
XVariable
CombineMatchingNames


XData_I
YData_I
SourceTable_I
DisplayVariables_I
XVariable_I
CombineMatchingNames_I

DisplayVariablesMode
ChartClassName
    end

    properties


        ChartDataChanged(1,1)logical=true
    end

    properties(Access=private)
        Model matlab.graphics.chart.internal.stackedplot.Model
        Warnings=struct(Args={{}},Issued=logical.empty)
    end

    properties(Access=?matlab.graphics.chart.StackedLineChart,NonCopyable)
        View matlab.graphics.chart.StackedLineChart
    end

    methods
        function obj=Presenter(model,view)
            obj.Model=model;
            obj.View=view;
        end

        function state=copyState(obj)
            state=obj.Model.copyState();
        end
    end

    methods
        function xData=get.XData(obj)
            xData=obj.Model.XData;
        end

        function set.XData(obj,xData)
            obj.Model.XData=xData;
            obj.ChartDataChanged=true;
        end

        function set.XData_I(obj,xData)
            obj.Model.XData_I=xData;
            obj.ChartDataChanged=true;
        end

        function yData=get.YData(obj)
            yData=obj.Model.YData;
        end

        function set.YData(obj,yData)
            obj.Model.YData=yData;
            obj.ChartDataChanged=true;
        end

        function set.YData_I(obj,yData)
            obj.Model.YData_I=yData;
            obj.ChartDataChanged=true;
        end

        function sourceTable=get.SourceTable(obj)
            sourceTable=obj.Model.SourceTable;
        end

        function set.SourceTable(obj,sourceTable)
            obj.Model.SourceTable=sourceTable;
            obj.ChartDataChanged=true;
        end

        function set.SourceTable_I(obj,sourceTable)
            obj.Model.SourceTable_I=sourceTable;
            obj.ChartDataChanged=true;
        end

        function displayVariables=get.DisplayVariables(obj)
            displayVariables=obj.Model.DisplayVariables;
        end

        function set.DisplayVariables(obj,displayVariables)
            obj.Model.DisplayVariables=displayVariables;
            obj.ChartDataChanged=true;
        end

        function set.DisplayVariables_I(obj,displayVariables)
            obj.Model.DisplayVariables_I=displayVariables;
            obj.ChartDataChanged=true;
        end

        function displayVariablesMode=get.DisplayVariablesMode(obj)
            displayVariablesMode=obj.Model.DisplayVariablesMode;
        end

        function set.DisplayVariablesMode(obj,displayVariablesMode)
            obj.Model.DisplayVariablesMode=displayVariablesMode;
            obj.ChartDataChanged=true;
        end

        function xVariable=get.XVariable(obj)
            xVariable=obj.Model.XVariable;
        end

        function set.XVariable(obj,xVariable)
            obj.Model.XVariable=xVariable;
            obj.ChartDataChanged=true;
        end

        function set.XVariable_I(obj,xVariable)
            obj.Model.XVariable_I=xVariable;
            obj.ChartDataChanged=true;
        end

        function combineMatchingNames=get.CombineMatchingNames(obj)
            combineMatchingNames=obj.Model.CombineMatchingNames;
        end

        function set.CombineMatchingNames(obj,combineMatchingNames)
            obj.Model.CombineMatchingNames=combineMatchingNames;
            obj.ChartDataChanged=true;
        end

        function set.CombineMatchingNames_I(obj,combineMatchingNames)
            obj.Model.CombineMatchingNames_I=combineMatchingNames;
            obj.ChartDataChanged=true;
        end

        function name=get.ChartClassName(obj)
            name=class(obj.View);
        end
    end

    methods
        function numAxes=getNumAxes(obj)
            numAxes=obj.Model.getNumAxes();
        end

        function x=getAxesXData(obj,varargin)
            x=obj.Model.getAxesXData(varargin{:});
        end

        function y=getAxesYData(obj,varargin)
            y=obj.Model.getAxesYData(varargin{:});
        end

        function c=getAxesSeriesIndices(obj,varargin)
            c=obj.Model.getAxesSeriesIndices(varargin{:});
        end

        function c=getAxesLineStyles(obj,varargin)
            c=obj.Model.getAxesLineStyles(varargin{:});
        end

        function labels=getAxesLabels(obj,varargin)
            labels=obj.Model.getAxesLabels(varargin{:});
        end

        function labels=getLegendLabels(obj,varargin)
            labels=obj.Model.getLegendLabels(varargin{:});
        end

        function xLabel=getXLabel(obj)
            xLabel=obj.Model.getXLabel();
        end

        function xLimits=getXLimits(obj)
            xLimits=obj.Model.getXLimits();
        end

        function yLimits=getYLimits(obj,axesIndex)
            yLimits=obj.Model.getYLimits(axesIndex);
        end

        function[axesMapping,plotMapping]=mapPlotObjects(obj,varargin)
            [axesMapping,plotMapping]=obj.Model.mapPlotObjects(varargin{:});
        end

        function plotTypes=getAxesPlotType(obj,varargin)
            plotTypes=obj.Model.getAxesPlotType(varargin{:});
        end

        function groups=getPropertyGroups(obj)
            groups=obj.Model.getPropertyGroups();
        end

        function labels=getCollapseLegend(obj,varargin)
            labels=obj.Model.getCollapseLegend(varargin{:});
        end

        function visible=getChartLegendVisible(obj)
            visible=obj.Model.getChartLegendVisible();
        end

        function labels=getChartLegendLabels(obj)
            labels=obj.Model.getChartLegendLabels();
        end

        function validate(obj)
            obj.Model.validate();
        end

        function varIndex=getVariableIndex(obj)
            varIndex=obj.Model.getVariableIndex();
        end

        function innerVarIdx=getInnerVariableIndex(obj)
            innerVarIdx=obj.Model.getInnerVariableIndex();
        end

        function logWarning(obj,varargin)

            msg={varargin};
            if~obj.hasWarning(msg)
                obj.Warnings.Args=[obj.Warnings.Args,msg];
                obj.Warnings.Issued=[obj.Warnings.Issued,false];
            end
        end

        function issueWarnings(obj)





            if numel(obj.Warnings.Args)==0
                return
            end
            for i=1:numel(obj.Warnings.Args)
                if~obj.Warnings.Issued(i)

                    warnState=warning("off","backtrace");
                    warning(obj.Warnings.Args{i}{:});
                    warning(warnState);
                    obj.Warnings.Issued(i)=true;
                end
            end
        end

        function clearWarnings(obj)

            obj.Warnings.Args={};
            obj.Warnings.Issued=logical.empty;
        end
    end

    methods(Access=private)
        function tf=hasWarning(obj,msg)

            tf=false;
            for i=1:numel(obj.Warnings.Args)
                if isequal(msg,obj.Warnings.Args(i))
                    tf=true;
                    return
                end
            end
        end
    end
end
