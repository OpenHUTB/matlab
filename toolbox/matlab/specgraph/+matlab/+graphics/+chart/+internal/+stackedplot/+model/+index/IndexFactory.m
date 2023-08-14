classdef IndexFactory<handle













    properties(Access=private)
        ChartData matlab.graphics.chart.internal.stackedplot.ChartData
Pool
    end

    methods
        function obj=IndexFactory(chartData)
            obj.ChartData=chartData;
            obj.Pool=struct();
        end

        function index=getIndex(obj,indexType)
            switch indexType
            case "TabularIndex"
                constructor=@matlab.graphics.chart.internal.stackedplot.model.index.TabularIndex;
            case "MultiTabularIndex"
                constructor=@matlab.graphics.chart.internal.stackedplot.model.index.MultiTabularIndex;
            otherwise
                assert(false);
            end
            index=obj.createIndexByType(indexType,constructor);
        end

        function varIndex=getVariableIndex(obj)
            tabularIndex=obj.getIndex("TabularIndex");
            varIndex=tabularIndex.getVariableIndex();
        end

        function innerVarIdx=getInnerVariableIndex(obj)
            tabularIndex=obj.getIndex("TabularIndex");
            innerVarIdx=tabularIndex.getInnerVariableIndex();
        end
    end

    methods(Access=private)
        function index=createIndexByType(obj,indexType,constructor)
            if~obj.hasIndex(indexType)
                obj.addIndex(indexType,constructor(obj.ChartData));
            end
            index=obj.retrieveIndex(indexType);
        end

        function tf=hasIndex(obj,indexType)
            tf=isfield(obj.Pool,indexType);
        end

        function addIndex(obj,indexType,index)
            obj.Pool.(indexType)=index;
        end

        function index=retrieveIndex(obj,indexType)
            index=obj.Pool.(indexType);
        end
    end
end