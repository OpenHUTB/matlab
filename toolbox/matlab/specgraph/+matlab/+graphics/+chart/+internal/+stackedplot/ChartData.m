classdef ChartData<handle&matlab.mixin.Copyable




    properties(SetObservable)
XData
YData
SourceTable
DisplayVariables
XVariable
CombineMatchingNames

        DisplayVariablesMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual
    end

    properties(SetAccess=private,NonCopyable)
        IndexFactory matlab.graphics.chart.internal.stackedplot.model.index.IndexFactory
    end

    methods
        function obj=ChartData(varargin)
            obj.IndexFactory=matlab.graphics.chart.internal.stackedplot.model.index.IndexFactory(obj);
            set(obj,varargin{:});
        end

        function set(obj,varargin)
            for i=1:2:nargin-1
                obj.(varargin{i})=varargin{i+1};
            end
        end

        function varIndex=getVariableIndex(obj)
            varIndex=obj.IndexFactory.getVariableIndex();
        end

        function innerVarIdx=getInnerVariableIndex(obj)
            innerVarIdx=obj.IndexFactory.getInnerVariableIndex();
        end
    end

    methods(Access=protected)
        function cpObj=copyElement(obj)
            cpObj=copyElement@matlab.mixin.Copyable(obj);
            cpObj.IndexFactory=matlab.graphics.chart.internal.stackedplot.model.index.IndexFactory(cpObj);
        end
    end
end
