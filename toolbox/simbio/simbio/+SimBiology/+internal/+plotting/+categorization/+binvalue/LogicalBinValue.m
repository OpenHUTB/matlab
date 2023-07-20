classdef LogicalBinValue<SimBiology.internal.plotting.categorization.binvalue.BinValue

    methods(Static,Access=public)
    end


    methods(Access=?SimBiology.internal.plotting.categorization.binvalue.BinValue)
        function obj=getEmptyObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.LogicalBinValue.empty;
        end

        function obj=getUnconfiguredObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.LogicalBinValue;
        end

        function flag=isValueInput(obj,values)

            flag=islogical(values);
        end

        function configureSingleObjectFromValue(obj,value)
            set(obj,'value',value);
        end
    end


    methods(Access=public)
        function value=type(obj)
            value=SimBiology.internal.plotting.categorization.binvalue.BinValue.LOGICAL;
        end


        function flag=isEqual(obj,comparisonObj)
            if islogical(comparisonObj)
                flag=(obj.value==comparisonObj);
            else
                flag=(obj.value==comparisonObj.value);
            end
        end

        function name=getDisplayNameHelper(obj,plotDefinition,categoryDefinition)
            if obj.value
                name='true';
            else
                name='false';
            end
        end
    end
end