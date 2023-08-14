classdef ScalarParameter<matlab.mixin.SetGet

    properties(Access=public)
        categoryVariable=[];
        binValues=[];
        values=[];
    end
    methods(Access=public)
        function obj=ScalarParameter(categoryVariable,binValues,values)

            if(nargin>0)
                obj.categoryVariable=categoryVariable;
                obj.binValues=binValues;
                obj.values=values;
            end
        end

        function flag=isEqual(obj,comparisonObj)
            flag=obj.categoryVariable.isEqual(comparisonObj);
        end

        function setDataSource(obj,dataSource)
            arrayfun(@(p)set(p.categoryVariable,'dataSource',dataSource),obj);
        end
    end
end