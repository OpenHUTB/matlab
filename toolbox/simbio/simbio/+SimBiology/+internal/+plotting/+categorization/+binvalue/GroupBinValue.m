classdef GroupBinValue<SimBiology.internal.plotting.categorization.binvalue.BinValue

    properties(Access=public)
        dataSource=SimBiology.internal.plotting.data.DataSource.empty;
        infoBins=SimBiology.internal.plotting.categorization.Bin.empty;
        categoryVariableCache;
    end

    properties(Access=private)

        dataIndex=[];
    end


    methods(Access=?SimBiology.internal.plotting.categorization.binvalue.BinValue)
        function obj=getEmptyObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.GroupBinValue.empty;
        end

        function obj=getUnconfiguredObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.GroupBinValue;
        end

        function flag=isValueInput(obj,values)

            flag=iscell(values)||isstring(values);
        end

        function configureSingleObjectFromValue(obj,value)
            set(obj,'value',value{1});
        end

        function configureSingleObjectFromStruct(obj,value)
            configureSingleObjectFromStruct@SimBiology.internal.plotting.categorization.binvalue.BinValue(obj,value);
            set(obj,'dataSource',SimBiology.internal.plotting.data.DataSource(value.dataSource),...
            'infoBins',SimBiology.internal.plotting.categorization.Bin(value.infoBins));
        end
    end


    methods(Access=public)
        function value=type(obj)
            value=SimBiology.internal.plotting.categorization.binvalue.BinValue.GROUP;
        end


        function flag=isEqual(obj,comparisonObj)
            if ischar(comparisonObj)
                flag=strcmp(obj.value,comparisonObj);
            else

                flag=strcmp(obj.value,comparisonObj.value);

            end
        end

        function flag=isMatchDataSeries(obj,singleDataSeries,categoryVariable,useDataSource)
            flag=obj.value.isEqual(singleDataSeries.groupBinValue);
        end

        function name=getDisplayNameHelper(obj,plotDefinition,categoryDefinition)
            prefix='';
            if plotDefinition.qualifyGroupsByDataSource
                prefix=[obj.dataSource.getShortName(),'.'];
                name=obj.value;
            elseif numel(obj.infoBins)==1


                name=obj.infoBins.binValue.getDisplayNames(plotDefinition,[]);
                name=name{1};
            else
                name=obj.value;
            end
            name=[prefix,name];
        end

        function setupCategoryVariableCache(obj)
            arrayfun(@(bin)set(bin,'categoryVariableCache',containers.Map),obj);
        end

        function cacheCategoryVariableValues(obj,categoryVariable,values)

            key=categoryVariable.key();
            arrayfun(@(bin,value)bin.cacheCategoryVariableValue(key,value),obj,values);
        end

        function binValue=getBinValueForVariable(obj,categoryVariable)
            if obj.categoryVariableCache.isKey(categoryVariable.key)
                binValue=obj.categoryVariableCache(categoryVariable.key);
            else
                binValue=[];
            end
        end
    end

    methods(Access=public)
        function setDataIndex(obj,index)
            for i=1:(numel(obj))
                obj(i).dataIndex=index(i);
            end
        end

        function index=getDataIndex(obj)
            for i=numel(obj):-1:1
                index(i)=obj(i).dataIndex;
            end
        end
    end

    methods(Access=private)
        function cacheCategoryVariableValue(obj,key,value)

            obj.categoryVariableCache(key)=value;
        end
    end

    methods(Access=protected)
        function bin=getStructForSingleObject(obj)
            bin=getStructForSingleObject@SimBiology.internal.plotting.categorization.binvalue.BinValue(obj);
            bin.dataSource=obj.dataSource.getStruct;
            bin.infoBins=obj.infoBins.getStruct;
        end
    end
end