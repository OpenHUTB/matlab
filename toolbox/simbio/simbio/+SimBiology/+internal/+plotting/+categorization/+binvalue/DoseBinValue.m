classdef DoseBinValue<SimBiology.internal.plotting.categorization.binvalue.BinValue

    properties(Access=public)
        doseParameters=SimBiology.internal.plotting.categorization.binvalue.DoseParameters.empty;
    end


    methods(Access=?SimBiology.internal.plotting.categorization.binvalue.BinValue)
        function obj=getEmptyObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.DoseBinValue.empty;
        end

        function obj=getUnconfiguredObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.DoseBinValue;
        end

        function flag=isValueInput(obj,values)
            flag=isa(values,'SimBiology.Dose');
        end

        function configureSingleObjectFromValue(obj,value)
            set(obj,'value',value.name,...
            'doseParameters',SimBiology.internal.plotting.categorization.binvalue.DoseParameters(value));
        end

        function configureSingleObjectFromStruct(obj,value)
            configureSingleObjectFromStruct@SimBiology.internal.plotting.categorization.binvalue.BinValue(obj,value);
            set(obj,'doseParameters',SimBiology.internal.plotting.categorization.binvalue.DoseParameters(value.doseParameters));
        end
    end


    methods(Access=public)
        function value=type(obj)
            value=SimBiology.internal.plotting.categorization.binvalue.BinValue.DOSE;
        end
    end


    methods(Access=public)

        function flag=isEqual(obj,comparisonObj,useDataSource)
            if ischar(comparisonObj)
                flag=strcmp(obj.value,comparisonObj)
            else
                flag=strcmp(obj.value,comparisonObj.value);
            end
        end

        function name=getDisplayNameHelper(obj,plotDefinition,categoryDefinition)
            name=obj.value;
        end
    end

    methods(Access=protected)
        function bin=getStructForSingleObject(obj)
            bin=getStructForSingleObject@SimBiology.internal.plotting.categorization.binvalue.BinValue(obj);
            bin.doseParameters=obj.doseParameters.getStruct();
        end
    end
end