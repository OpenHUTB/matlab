classdef ResponseBinValue<SimBiology.internal.plotting.categorization.binvalue.BinValue

    properties(Access=public)
        dataSource=[];
        isSimulation=true;
        displayType=[];
    end


    methods(Access=?SimBiology.internal.plotting.categorization.binvalue.BinValue)
        function obj=getEmptyObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.ResponseBinValue.empty;
        end

        function obj=getUnconfiguredObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.ResponseBinValue;
        end

        function configureSingleObjectFromStruct(obj,value)
            configureSingleObjectFromStruct@SimBiology.internal.plotting.categorization.binvalue.BinValue(obj,value);
            set(obj,'dataSource',SimBiology.internal.plotting.data.DataSource(value.dataSource),...
            'isSimulation',value.isSimulation,...
            'value',obj.createResponseObject(value.value),...
            'displayType',value.displayType);
        end
    end

    methods(Static,Access=private)
        function response=createResponseObject(response)
            if~isa(response,'SimBiology.internal.plotting.sbioplot.Response')
                response=SimBiology.internal.plotting.sbioplot.Response(response);
            end
        end
    end


    methods(Access=public)
        function value=type(obj)
            value=SimBiology.internal.plotting.categorization.binvalue.BinValue.RESPONSE;
        end

        function flag=varyLineStyle(obj)
            flag=obj.isSimulation;
        end

        function copySettings(obj,binValueToCopy)

            set(obj,'displayType',binValueToCopy.displayType);
        end

        function updateSettings(obj,index)

            obj.updateSettings@SimBiology.internal.plotting.categorization.binvalue.BinValue(index);
            if isempty(obj.displayType)
                if obj.isSimulation
                    obj.displayType=SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionProps.PERCENTILE;
                else
                    obj.displayType=SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionProps.MEAN;
                end
            end
        end

        function value=getScatterplotValue(obj)

            value=categorical(vertcat(obj.index));
        end
    end


    methods(Access=public)

        function flag=isEqual(obj,comparisonObj,useDataSource)
            if(nargin==2)
                useDataSource=true;
            end
            flag=((~useDataSource||obj.dataSource.isEqual(comparisonObj.dataSource))&&...
            obj.value.isEqual(comparisonObj.value));
        end

        function flag=isMatchDataSeries(obj,singleDataSeries,categoryVariable,useDataSource)

        end

        function name=getDisplayNameHelper(obj,plotDefinition,categoryDefinition)
            qualifyByDataSource=plotDefinition.qualifyByDataSource;
            showIndependentVariable=plotDefinition.showIndependentVariable;
            areResponseLabelsMatched=categoryDefinition.areResponseLabelsMatched;

            name=createLabelForSingleObject(obj,false,qualifyByDataSource,~areResponseLabelsMatched.dependentVarUnits);

            if showIndependentVariable||(~areResponseLabelsMatched.independentVarUnits&&~isempty(obj.value.independentVarUnits))
                independentVarLabel=createLabelForSingleObject(obj,true,false,areResponseLabelsMatched.dependentVarUnits);
                name=[name,' vs. ',independentVarLabel];
            end
        end

        function name=getAlternateDisplayName(obj,plotDefinition,categoryDefinition)
            qualifyByDataSource=plotDefinition.qualifyByDataSource;
            showIndependentVariable=plotDefinition.showIndependentVariable;
            areResponseLabelsMatched=categoryDefinition.areResponseLabelsMatched;
            name=arrayfun(@(bin)getAlternateDisplayNameHelper(bin,qualifyByDataSource,showIndependentVariable,areResponseLabelsMatched),obj,'UniformOutput',false);
        end

        function name=getDisplayNameForExportSingleObject(obj,plotDefinition,categoryDefinition)
            name=obj.getDisplayNameHelper(plotDefinition,categoryDefinition);
            if plotDefinition.supportsResponseDisplayType
                name=[name,' (',obj.displayType,')'];
            end
        end

        function flag=includes(obj,responseBinValue,qualifyByDataSource)
            flag=false;
            for b=1:numel(obj)
                if obj(b).isEqual(responseBinValue,qualifyByDataSource)
                    flag=true;
                    break;
                end
            end
        end
    end

    methods(Access=public)
        function dataSourceToBinsDict=mapBinsToDataSources(obj,dataSourcesOrKeys)



            responseDataSources=[obj.dataSource];
            responseDataSourceKeys={responseDataSources.key};


            if isa(dataSourcesOrKeys,'SimBiology.internal.plotting.data.DataSource')
                dataSourceKeys={dataSourcesOrKeys.key};
            else
                dataSourceKeys=dataSourcesOrKeys;
            end

            [~,idx]=ismember(responseDataSourceKeys,dataSourceKeys);


            dataSourceToBinsDict=dictionary;
            for d=1:numel(dataSourceKeys)
                dataSourceToBinsDict(dataSourceKeys{d})={obj(idx==d)};
            end
        end
    end

    methods(Access=protected)
        function bin=getStructForSingleObject(obj)
            bin=getStructForSingleObject@SimBiology.internal.plotting.categorization.binvalue.BinValue(obj);
            bin.dataSource=obj.dataSource.getStruct;
            bin.value=obj.value.getStruct;
            bin.isSimulation=obj.isSimulation;
            bin.displayType=obj.displayType;
        end
    end

    methods(Access=public)
        function allMatch=allMatchInResponseProperty(obj,prop)
            allMatch=true;
            firstBin=obj(1);
            for b=2:numel(obj)
                if~strcmp(firstBin.value.(prop),obj(b).value.(prop))
                    allMatch=false;
                    break;
                end
            end
        end

        function targetUnits=getTargetUnitsForDimension(obj,useX)
            if useX
                unitsProp='independentVarUnits';
            else
                unitsProp='dependentVarUnits';
            end
            firstBin=obj(1);
            targetUnits=firstBin.value.(unitsProp);
            for i=2:numel(obj)
                if~obj.doDimensionsMatch(targetUnits,obj(i).value.(unitsProp))
                    targetUnits='';
                    break;
                end
            end
        end

        function labels=getResponseXLabels(obj,plotDefinition,categoryDefinition)
            if~categoryDefinition.areResponseLabelsMatched().independentVar
                includeUnits=~categoryDefinition.areResponseLabelsMatched().independentVarUnits;

                labels=arrayfun(@(bin)bin.createLabelForSingleObject(true,false,includeUnits),...
                obj,'UniformOutput',false);
            else
                labels=repmat({''},size(obj));
            end
        end

        function labels=getResponseYLabels(obj,plotDefinition,categoryDefinition)
            if~categoryDefinition.areResponseLabelsMatched().dependentVar
                includeUnits=~categoryDefinition.areResponseLabelsMatched().dependentVarUnits;
                labels=arrayfun(@(bin)bin.createLabelForSingleObject(false,plotDefinition.qualifyByDataSource,includeUnits),...
                obj,'UniformOutput',false);
            else
                labels=repmat({''},size(obj));
            end
        end

        function names=getDisplayNamesForExport(obj,plotDefinition,categoryDefinition)
            for i=numel(obj):-1:1
                names{i,1}=obj(i).getDisplayNameForExportSingleObject(plotDefinition,categoryDefinition);
            end
        end
    end

    methods(Access=private)
        function label=createLabelForSingleObject(obj,isIndependentVar,qualifyByDataSource,includeUnits)
            if isIndependentVar
                varProp='independentVar';
                unitsProp='independentVarUnits';
            else
                varProp='dependentVar';
                unitsProp='dependentVarUnits';
            end

            if qualifyByDataSource
                prefix=[obj.dataSource.getShortName(),'.'];
            else
                prefix='';
            end

            if includeUnits&&~isempty(obj.value.(unitsProp))
                suffix=[' (',obj.value.(unitsProp),')'];
            else
                suffix='';
            end

            label=[prefix,obj.value.(varProp),suffix];
        end

        function name=getAlternateDisplayNameHelper(obj,qualifyByDataSource,showIndependentVariable,areResponseLabelsMatched)
            name=createLabelForSingleObject(obj,false,qualifyByDataSource,~areResponseLabelsMatched.dependentVarUnits);
            name=[obj.dataSource.getShortName(),' (',name,')'];
        end
    end

    methods(Static,Access=private)
        function isMatch=doDimensionsMatch(units1,units2)
            if isempty(units1)||isempty(units2)
                isMatch=false;
            else
                try
                    sbiounitcalculator(units1,units2,1);
                    isMatch=true;
                catch ex
                    isMatch=false;
                end
            end
        end
    end
end