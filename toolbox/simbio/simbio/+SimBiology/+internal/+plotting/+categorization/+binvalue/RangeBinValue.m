classdef RangeBinValue<SimBiology.internal.plotting.categorization.binvalue.BinValue


    methods(Access=?SimBiology.internal.plotting.categorization.binvalue.BinValue)
        function obj=getEmptyObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.RangeBinValue.empty;
        end

        function obj=getUnconfiguredObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.RangeBinValue;
        end

        function flag=isValueInput(obj,values)
            flag=isnumeric(values);
        end

        function configureSingleObjectFromValue(obj,value)
            set(obj,'value',value);
        end

        function configureObjectsFromStructs(obj,values)

            if numel(values(1).value)==1
                values(1).value=[-inf,values(1).value];
            end
            if numel(values(end).value)==1
                values(end).value=[values(end).value,inf];
            end
            configureObjectsFromStructs@SimBiology.internal.plotting.categorization.binvalue.BinValue(obj,values);
        end
    end


    methods(Access=public)
        function value=type(obj)
            value=SimBiology.internal.plotting.categorization.binvalue.BinValue.RANGE;
        end


        function flag=isEqual(obj,comparisonObj)
            if isa('SimBiology.internal.plotting.categorization.binvalue.RangeBinValue')
                flag=all(obj.value==comparisonObj.value);
            else

                error('Wrong input type to RangeBinValue isEqual method.')
            end
        end

        function flag=isMatch(obj,comparisonBin)
            if obj.isNA
                flag=isempty(comparisonBin);
            else
                flag=~isempty(comparisonBin)&&obj.isInRange(comparisonBin.value);
            end
        end

        function flag=isMatchDataSeries(obj,singleDataSeries,categoryVariable,useDataSource)
            value=singleDataSeries.getBinValueForVariable(categoryVariable);
            if isempty(value)
                flag=obj.isNA;
            else
                flag=isInRange(obj,value.value);
            end
        end

        function value=getScatterplotValue(obj)

            value=categorical(vertcat(obj.index));
        end

        function flag=isInRange(obj,value)

            flag=(value>=obj.lowerBound)&&...
            ((value<obj.upperBound)||isinf(obj.upperBound));
        end

        function value=lowerBound(obj)
            value=obj.value(1);
        end

        function value=upperBound(obj)
            value=obj.value(2);
        end

        function name=getDisplayNameHelper(obj,plotDefinition,categoryDefinition)
            categoryVariableName=categoryDefinition.getDisplayName(plotDefinition);
            if isinf(obj.lowerBound)
                name=[categoryVariableName,' < ',num2str(obj.upperBound)];
            elseif isinf(obj.upperBound)
                name=[categoryVariableName,' >= ',num2str(obj.lowerBound)];
            else
                name=[num2str(obj.lowerBound),' <= ',categoryVariableName,' < ',num2str(obj.upperBound)];
            end
        end
    end
end