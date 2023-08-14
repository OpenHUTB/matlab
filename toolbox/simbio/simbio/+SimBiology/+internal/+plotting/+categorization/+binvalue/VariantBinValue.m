classdef VariantBinValue<SimBiology.internal.plotting.categorization.binvalue.BinValue

    properties(Access=public)
        content=SimBiology.internal.plotting.categorization.binvalue.VariantBinValue.empty;
    end


    methods(Access=?SimBiology.internal.plotting.categorization.binvalue.BinValue)
        function obj=getEmptyObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.VariantBinValue.empty;
        end

        function obj=getUnconfiguredObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.VariantBinValue;
        end

        function flag=isValueInput(obj,values)
            flag=isa(values,'SimBiology.Variant');
        end

        function configureSingleObjectFromValue(obj,value)
            set(obj,'value',value.name,...
            'content',SimBiology.internal.plotting.categorization.binvalue.VariantContent(value.content));
        end

        function obj=configureSingleObjectFromStruct(obj,value)
            configureSingleObjectFromStruct@SimBiology.internal.plotting.categorization.binvalue.BinValue(obj,value);
            set(obj,'content',SimBiology.internal.plotting.categorization.binvalue.VariantContent(value.content));
        end
    end


    methods(Access=public)
        function value=type(obj)
            value=SimBiology.internal.plotting.categorization.binvalue.BinValue.VARIANT;
        end
    end


    methods(Access=public)

        function flag=isEqual(obj,comparisonObj,useDataSource)
            if ischar(comparisonObj)
                flag=strcmp(obj.value,comparisonObj);
            elseif strcmp(obj.value,'sliders')
                flag=obj.isEqualByIndex(comparisonObj);
            else
                flag=strcmp(obj.value,comparisonObj.value);
            end
        end

        function name=getDisplayNameHelper(obj,plotDefinition,categoryDefinition)
            if strcmp(obj.value,'sliders')
                if isempty(obj.content)
                    name=['Run ',num2str(obj.index)];
                else
                    name=obj.content.getDisplayString;
                end
            else
                name=obj.value;
            end
        end
    end

    methods(Access=protected)
        function bin=getStructForSingleObject(obj)
            bin=getStructForSingleObject@SimBiology.internal.plotting.categorization.binvalue.BinValue(obj);
            bin.content=obj.content.getStruct();
        end
    end
end