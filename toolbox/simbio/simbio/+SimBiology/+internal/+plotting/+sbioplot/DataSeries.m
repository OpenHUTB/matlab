classdef DataSeries<matlab.mixin.SetGet
    properties(Access=public)
        groupBinValue=[];
        responseBinValue=SimBiology.internal.plotting.categorization.binvalue.ResponseBinValue.empty;
        independentVariableData=[];
        dependentVariableData=[];
        parameterizationVariableData=[];
    end

    methods(Access=public)
        function obj=DataSeries(responseBinValue,groupBinValues)
            if nargin>0
                numObj=numel(groupBinValues);
                obj(numObj)=SimBiology.internal.plotting.sbioplot.DataSeries();
                obj=transpose(obj);
                arrayfun(@(ds,group)set(ds,'responseBinValue',responseBinValue,...
                'groupBinValue',group),...
                obj,groupBinValues);
            end
        end

        function binValue=getBinValueForVariable(obj,categoryVariable)
            binValue=obj.groupBinValue.getBinValueForVariable(categoryVariable);
        end
    end

    methods(Static,Access=public)
        function paramName=getTimeDataPropertyName(useParameterizationVariable)
            if useParameterizationVariable
                paramName='parameterizationVariableData';
            else
                paramName='independentVariableData';
            end
        end
    end
end