classdef CategoricalBinValue<SimBiology.internal.plotting.categorization.binvalue.BinValue


    methods(Access=?SimBiology.internal.plotting.categorization.binvalue.BinValue)
        function obj=getEmptyObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.CategoricalBinValue.empty;
        end

        function obj=getUnconfiguredObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.CategoricalBinValue;
        end

        function flag=isValueInput(obj,values)

            flag=iscell(values)||isstring(values);
        end

        function configureSingleObjectFromValue(obj,value)
            set(obj,'value',value{1});
        end
    end


    methods(Access=public)
        function value=type(obj)
            value=SimBiology.internal.plotting.categorization.binvalue.BinValue.CATEGORICAL;
        end


        function flag=isEqual(obj,comparisonObj)
            if ischar(comparisonObj)
                flag=strcmp(obj.value,comparisonObj);
            else
                flag=strcmp(obj.value,comparisonObj.value);
            end
        end

        function name=getDisplayNameHelper(obj,plotDefinition,categoryDefinition)
            name=obj.value;
        end
    end
end