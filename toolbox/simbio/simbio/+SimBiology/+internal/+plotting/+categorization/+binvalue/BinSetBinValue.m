classdef BinSetBinValue<SimBiology.internal.plotting.categorization.binvalue.BinValue

    properties(Access=public)
        binValues=SimBiology.internal.plotting.categorization.binvalue.GroupBinValue.empty;
    end


    methods(Access=?SimBiology.internal.plotting.categorization.binvalue.BinValue)
        function obj=getEmptyObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.BinSetBinValue.empty;
        end

        function obj=getUnconfiguredObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.BinSetBinValue;
        end

        function configureSingleObjectFromStruct(obj,value)
            configureSingleObjectFromStruct@SimBiology.internal.plotting.categorization.binvalue.BinValue(obj,value);
            set(obj,'binValues',SimBiology.internal.plotting.categorization.binvalue.BinValue.createBinValues(value.binValues));
        end

        function flag=isValueInput(obj,values)
            flag=iscell(values);
        end
    end


    methods(Access=public)
        function value=type(obj)
            value=SimBiology.internal.plotting.categorization.binvalue.BinValue.BIN_SET;
        end
    end


    methods(Access=public)

        function flag=isEqual(obj,comparisonObj,useDataSource)
            if ischar(comparisonObj)
                strcmp(obj.value,comparisonObj)
            else
                strcmp(obj.value,comparisonObj.value);
            end
        end

        function flag=isMatchDataSeries(obj,singleDataSeries,categoryVariable,useDataSource)

        end

        function name=getDisplayNameHelper(obj,plotDefinition,categoryDefinition)

            name=obj.value;
        end
    end

    methods(Access=protected)
        function bin=getStructForSingleObject(obj)
            bin=getStructForSingleObject@SimBiology.internal.plotting.categorization.binvalue.BinValue(obj);
            bin.binValues=obj.binValues.getStruct;
        end
    end
end