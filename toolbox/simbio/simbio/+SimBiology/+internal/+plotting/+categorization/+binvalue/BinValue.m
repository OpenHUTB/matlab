classdef(Abstract)BinValue<handle&matlab.mixin.SetGet


    methods(Static)
        function const=RESPONSE
            const='<RESPONSE>';
        end
        function const=RESPONSE_SET
            const='<RESPONSE_SET>';
        end
        function const=GROUP
            const='<GROUP>';
        end
        function const=NUMERIC
            const='<NUMERIC>';
        end
        function const=CATEGORICAL
            const='<CATEGORICAL>';
        end
        function const=LOGICAL
            const='<LOGICAL>';
        end
        function const=DOSE
            const='<DOSE>';
        end
        function const=VARIANT
            const='<VARIANT>';
        end
        function const=RANGE
            const='<RANGE>';
        end
        function const=BIN_SET
            const='<BIN_SET>';
        end

        function const=NOT_APPLICABLE
            const='Not applicable';
        end
    end

    properties(Access=public)
        index=0;
        value=[];
        isNA=false;
    end


    methods
        function obj=BinValue(values)
            if nargin>0
                numObj=numel(values);
                if numObj==0
                    obj=obj.getEmptyObject();
                    return;
                end


                obj=arrayfun(@(~)obj.getUnconfiguredObject(),transpose(1:numObj));
                obj.configure(values);
            end
        end
    end


    methods(Abstract,Access=?SimBiology.internal.plotting.categorization.binvalue.BinValue)
        obj=getEmptyObject(obj);
        obj=getUnconfiguredObject(obj);
    end

    methods(Access=?SimBiology.internal.plotting.categorization.binvalue.BinValue)
        function obj=configure(obj,values)

            if obj.isValueInput(values)
                configureObjectsFromValues(obj,values);
            else
                configureObjectsFromStructs(obj,values);
            end
        end

        function flag=isValueInput(obj,values)

            flag=false;
        end

        function configureObjectsFromValues(obj,values)
            arrayfun(@(bin,value)bin.configureSingleObjectFromValue(value),obj,values);
        end

        function configureObjectsFromStructs(obj,values)
            if~isfield(values,'isNA')
                [values.isNA]=deal(false);
            end
            arrayfun(@(bin,value)bin.configureSingleObjectFromStruct(value),obj,values);
        end

        function flag=configureSingleObjectFromValue(obj,value)

        end

        function obj=configureSingleObjectFromStruct(obj,value)
            set(obj,'value',value.value,...
            'index',value.index,...
            'isNA',value.isNA);
        end
    end

    methods(Access=public)
        function flag=isEqualByIndex(obj,comparisonObj)

            flag=arrayfun(@(b)(b.index==comparisonObj.index),obj);
        end

        function flag=isEqualToIndex(obj,index)

            flag=arrayfun(@(b)(b.index==index),obj);
        end

        function flag=isMatch(obj,comparisonBin)
            if obj.isNA
                flag=isempty(comparisonBin);
            else
                flag=~isempty(comparisonBin)&&obj.isEqual(comparisonBin);
            end
        end

        function flag=isMatchDataSeries(obj,singleDataSeries,categoryVariable,useDataSource)
            binValue=singleDataSeries.getBinValueForVariable(categoryVariable);
            if obj.isNA
                flag=isempty(binValue);
            else
                flag=~isempty(binValue)&&obj.isEqual(binValue);
            end
        end

        function copySettings(obj,binValueToCopy)


        end

        function updateSettings(obj,index)

            obj.index=index;
        end

        function flag=varyLineStyle(obj)
            flag=true;
        end

        function bin=getStruct(obj)
            bin=arrayfun(@(bin)bin.getStructForSingleObject(),obj);
        end

        function names=getDisplayNames(obj,plotDefinition,categoryDefinition)
            for i=numel(obj):-1:1
                names{i,1}=obj(i).getDisplayNameSingleObject(plotDefinition,categoryDefinition);
            end
        end

        function names=getDisplayNamesForExport(obj,plotDefinition,categoryDefinition)
            names=obj.getDisplayNames(obj,plotDefinition,categoryDefinition);
        end

        function name=getAlternateDisplayName(obj,plotDefinition,categoryDefinition)
            name=obj.getDisplayNames(plotDefinition,categoryDefinition);
        end

        function value=getScatterplotValue(obj)

            if ischar(obj(1).value)
                values={obj.value};
                values=transpose(values);
            else
                values=vertcat(obj.value);
            end

            if isnumeric(values)
                value=categorical(values);
            else
                uniqueValues=unique(values,'stable');
                value=categorical(values,uniqueValues,'Ordinal',true);
            end
        end
    end

    methods(Access=protected)
        function bin=getStructForSingleObject(obj)
            bin=struct('type',obj.type(),...
            'index',obj.index,...
            'value',obj.value,...
            'isNA',obj.isNA);
        end

        function name=getDisplayNameSingleObject(obj,plotDefinition,categoryDefinition)

            if(obj.isNA)
                name=obj.NOT_APPLICABLE;
            else
                name=obj.getDisplayNameHelper(plotDefinition,categoryDefinition);
            end
        end
    end

    methods(Abstract)
        value=type(obj);
        flag=isEqual(obj)
        name=getDisplayNameHelper(obj,plotDefinition,categoryDefinition)
    end

    methods(Static,Access=public)
        function values=createBinValues(binStructs)
            if isempty(binStructs)
                values=SimBiology.internal.plotting.categorization.binvalue.ResponseBinValue.empty;
            else
                type=binStructs(1).type;
                values=SimBiology.internal.plotting.categorization.binvalue.BinValue.createBinValuesByType(type,binStructs);
            end
        end

        function values=addNABinValue(values)
            type=values(1).type();
            value=SimBiology.internal.plotting.categorization.binvalue.BinValue.createBinValuesByType(type);
            set(value,'isNA',true);
            values=vertcat(values,value);
        end

        function values=createBinValuesByType(type,varargin)
            switch(type)
            case SimBiology.internal.plotting.categorization.binvalue.BinValue.RESPONSE
                values=SimBiology.internal.plotting.categorization.binvalue.ResponseBinValue(varargin{:});
            case SimBiology.internal.plotting.categorization.binvalue.BinValue.RESPONSE_SET
                values=SimBiology.internal.plotting.categorization.binvalue.ResponseSetBinValue(varargin{:});
            case SimBiology.internal.plotting.categorization.binvalue.BinValue.GROUP
                values=SimBiology.internal.plotting.categorization.binvalue.GroupBinValue(varargin{:});
            case SimBiology.internal.plotting.categorization.binvalue.BinValue.NUMERIC
                values=SimBiology.internal.plotting.categorization.binvalue.NumericBinValue(varargin{:});
            case SimBiology.internal.plotting.categorization.binvalue.BinValue.RANGE
                values=SimBiology.internal.plotting.categorization.binvalue.RangeBinValue(varargin{:});
            case SimBiology.internal.plotting.categorization.binvalue.BinValue.CATEGORICAL
                values=SimBiology.internal.plotting.categorization.binvalue.CategoricalBinValue(varargin{:});
            case SimBiology.internal.plotting.categorization.binvalue.BinValue.LOGICAL
                values=SimBiology.internal.plotting.categorization.binvalue.LogicalBinValue(varargin{:});
            case SimBiology.internal.plotting.categorization.binvalue.BinValue.VARIANT
                values=SimBiology.internal.plotting.categorization.binvalue.VariantBinValue(varargin{:});
            case SimBiology.internal.plotting.categorization.binvalue.BinValue.DOSE
                values=SimBiology.internal.plotting.categorization.binvalue.DoseBinValue(varargin{:});
            case SimBiology.internal.plotting.categorization.binvalue.BinValue.BIN_SET
                values=SimBiology.internal.plotting.categorization.binvalue.BinSetBinValue(varargin{:});
            end
        end
    end
end