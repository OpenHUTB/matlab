classdef SBioDataInterfaceForTimecourseData<SimBiology.internal.plotting.data.SBioDataInterface




    properties(Constant)
        LINEAR='linear';
        NEAREST='nearest';
        NEXT='next';
        PREVIOUS='previous';
        PCHIP='pchip';
        CUBIC='cubic';
        MAKIMA='makima';
        SPLINE='spline';
        ZOH='zoh';
    end




    properties(Access=protected)
        columnInfo=[];


        mergedInfoBins=[];

        mergedScalarParameters=SimBiology.internal.plotting.categorization.ScalarParameter.empty;



        matchedGroupsMap=[];
    end

    properties(Access=private)
        cachedGroups=SimBiology.internal.plotting.categorization.binvalue.GroupBinValue.empty;
    end




    methods(Abstract,Access=public)

        numGroups=getNumberOfGroups(obj)
        name=getGroupCategoryName(obj)
        flag=anyNumTimepointsPerGroupIsGreaterThan(obj,cutoff)


        categoryVariables=getCategoryVariables(obj,excludeAssociatedGroupParameters)
        scalarParameter=getScalarParameter(obj,categoryVariable)
        binValues=getCategoryVariableValues(obj,categoryVariable)
        binValues=getCategoryVariableValuesForGroups(obj,categoryVariable)
    end




    methods(Abstract,Access=?SimBiology.internal.plotting.data.SBioDataInterfaceForTimecourseData)

        data=getDataForVariable(obj,varName)



        timeVariableName=getTimeVariableName(obj);



        names=getGroupNames(obj)
        displayString=getGroupDisplayString(obj)
    end




    methods(Access=public)
        function data=getDataForTimeVariable(obj)
            indVar=obj.getTimeVariableName();
            data=obj.getDataForVariable(indVar);
        end

        function flag=containsVariables(obj,variables)
            for i=numel(variables):-1:1
                flag(i)=false;
                for j=1:numel(obj.columnInfo)
                    if iscell(obj.columnInfo)
                        info=obj.columnInfo{j};
                    else
                        info=obj.columnInfo(j);
                    end
                    if strcmp(variables{i},info.name)
                        flag(i)=true;
                        break;
                    end
                end
            end
        end

        function updateResponseUnits(obj,responses)
            for i=1:numel(responses)
                responses(i).independentVarUnits=getUnits(obj,responses(i).independentVar);
                responses(i).dependentVarUnits=getUnits(obj,responses(i).dependentVar);
            end
        end

        function dataSeries=getDataSeries(obj,plotArgument,targetXUnits,targetYUnits,categories,plotDefinition)
            responses=plotArgument.responses;
            numResponses=numel(responses);
            dataSeries=cell({numResponses,1});
            unitConvertX=~isempty(targetXUnits);
            unitConvertY=~isempty(targetYUnits);


            timeData=obj.getDataForTimeVariable();


            for r=1:numResponses


                response=responses(r);


                yData=obj.getDataForVariable(response.dependentVar);
                if plotDefinition.isTimePlot
                    xData=timeData;
                    pData={};
                    [xData,yData]=cellfun(@(x,y)obj.removeNaNs(x,y),xData,yData,'UniformOutput',false);
                else
                    xData=obj.getDataForVariable(response.independentVar);
                    pData=timeData;
                    [xData,yData,pData]=cellfun(@(x,y,p)obj.removeNaNsForParameterizedData(x,y,p),xData,yData,pData,'UniformOutput',false);
                end




                if(unitConvertX&&~isempty(targetXUnits))
                    xData=cellfun(@(data)sbiounitcalculator(response.independentVarUnits,targetXUnits,data),xData,'UniformOutput',false);
                    response.independentVarUnits=targetXUnits;
                end
                if(unitConvertY&&~isempty(targetYUnits))
                    yData=cellfun(@(data)sbiounitcalculator(response.dependentVarUnits,targetYUnits,data),yData,'UniformOutput',false);
                    response.dependentVarUnits=targetYUnits;
                end

                responseBinValue=SimBiology.internal.plotting.categorization.binvalue.ResponseBinValue(struct('dataSource',obj.dataSource,...
                'isSimulation',true,...
                'value',response,...
                'index',0,...
                'displayType','',...
                'info',struct));


                if(plotDefinition.supportsMatchGroups()&&plotDefinition.hasMatchedGroups())
                    dataSeries{r}=createdDataSeriesForMatchedData(obj,xData,yData,pData,responseBinValue,plotArgument,categories,plotDefinition);
                else
                    groups=obj.getGroups();
                    obj.cacheCategoryVariableValuesOnGroups(groups,[categories.categoryVariable]);
                    dataSeries{r}=createDataSeries(obj,xData,yData,pData,responseBinValue,groups);
                end
            end
        end
    end




    methods(Access=protected)
        function[x,y]=removeNaNs(obj,x,y)
            if numel(x)~=numel(y)
                x=NaN;
                y=NaN;
            else
                nanIdx=isnan(x)|isnan(y);
                x=x(~nanIdx);
                y=y(~nanIdx);


                if isempty(x)
                    x=NaN;
                    y=NaN;
                end
            end
        end

        function[x,y,p]=removeNaNsForParameterizedData(obj,x,y,p)
            if(numel(x)~=numel(y))||(numel(x)~=numel(p))
                x=NaN;
                y=NaN;
                p=NaN;
            else
                nanIdx=isnan(x)|isnan(y)|isnan(p);
                x=x(~nanIdx);
                y=y(~nanIdx);
                p=p(~nanIdx);


                if isempty(x)
                    x=NaN;
                    y=NaN;
                    p=NaN;
                end
            end
        end

        function units=getUnits(obj,varName)




            units='';
            if~isempty(obj.columnInfo)

                if iscell(obj.columnInfo)
                    idx=cellfun(@(x)strcmp(x.name,varName),obj.columnInfo);
                    if any(idx)
                        units=obj.columnInfo{idx}.units;
                    end
                else
                    idx=arrayfun(@(x)strcmp(x.name,varName),obj.columnInfo);
                    if any(idx)
                        units=obj.columnInfo(idx).units;
                    end
                end
            end
        end

        function dataSeriesForResponse=createDataSeries(obj,xData,yData,pData,responseBinValue,groups)

            dataSeriesForResponse=num2cell(SimBiology.internal.plotting.sbioplot.DataSeries(responseBinValue,groups));
            cellfun(@(ds,x,y)set(ds,'independentVariableData',x,...
            'dependentVariableData',y),...
            dataSeriesForResponse,xData,yData);
            if~isempty(pData)
                cellfun(@(ds,p)set(ds,'parameterizationVariableData',p),...
                dataSeriesForResponse,pData);
            end
        end

        function dataSeriesForResponse=createdDataSeriesForMatchedData(obj,xData,yData,pData,responseBinValue,plotArgument,categories,plotDefinition)
            groupCategory=plotDefinition.getCategories().getGroupCategory();


            if isempty(obj.matchedGroupsMap)&&plotArgument.matchedDataSource.isEqualToKey(plotArgument.matchedDataSourceKey)
                groupBins=groupCategory.getBinsForDataSource(plotArgument.matchedDataSourceKey);


                groups=SimBiology.internal.plotting.categorization.binvalue.GroupBinValue(arrayfun(@(b)b.value,groupBins,'UniformOutput',false));
                obj.cacheCategoryVariableValuesOnGroups(groups,[categories.categoryVariable]);

                dataSeriesForResponse=createDataSeries(obj,xData,yData,pData,responseBinValue,groups);


            else
                dataSeriesForResponse=createDataSeriesForMatchedDataWithout1To1Correlation(obj,xData,yData,pData,responseBinValue,plotArgument,categories,groupCategory);
            end
        end

        function dataSeriesForResponse=createDataSeriesForMatchedDataWithout1To1Correlation(obj,xData,yData,pData,responseBinValue,plotArgument,categories,groupCategory)
            groupBins=vertcat(groupCategory.getBinsForDataSource(plotArgument.matchedDataSource.key).value);
            numGroupBins=numel(groupBins);


            dataSeriesForResponse=repmat({SimBiology.internal.plotting.sbioplot.DataSeries.empty},numGroupBins,1);
            for matchedIdx=1:numGroupBins
                for dataIdx=obj.matchedGroupsMap{matchedIdx}

                    group=SimBiology.internal.plotting.categorization.binvalue.GroupBinValue(groupBins(matchedIdx));
                    obj.cacheCategoryVariableValuesOnGroups(group,[categories.categoryVariable],dataIdx,matchedIdx);

                    ds=SimBiology.internal.plotting.sbioplot.DataSeries(responseBinValue,group);
                    set(ds,'independentVariableData',xData{dataIdx},...
                    'dependentVariableData',yData{dataIdx});
                    if~isempty(pData)
                        set(ds,'parameterizationVariableData',pData{dataIdx});
                    end
                    dataSeriesForResponse{matchedIdx}=[dataSeriesForResponse{matchedIdx};ds];
                end
            end
        end
    end




    methods(Access=?SimBiology.internal.plotting.data.SBioDataInterfaceForTimecourseData)

        function groupBinValues=getAssociatedGroups(obj,matchedDataSource)

            groupBinValues=SimBiology.internal.plotting.categorization.binvalue.GroupBinValue.empty;
        end

        function infoBins=getInfoBins(obj)
            categoryVariable=SimBiology.internal.plotting.categorization.CategoryVariable(struct('type',SimBiology.internal.plotting.categorization.CategoryVariable.GROUP,...
            'name',obj.getGroupDisplayString(),...
            'subtype',[],...
            'dataSource',obj.dataSource,...
            'associatedDataSource',[]));
            names=obj.getGroupNames();
            values=SimBiology.internal.plotting.categorization.binvalue.GroupBinValue(names);
            set(values,'dataSource',obj.dataSource);
            infoBins=arrayfun(@(bin)SimBiology.internal.plotting.categorization.Bin(categoryVariable,bin),values,'UniformOutput',false);
        end
    end




    methods(Access=public)
        function groups=getGroups(obj)
            if isempty(obj.cachedGroups)
                groups=obj.createGroupBins();
            else
                groups=obj.cachedGroups;
            end
        end

        function flag=hasOneToOneGroupMatchingOnly(obj)

            flag=true;
        end

        function dataSource=getDataSourceForMatching(obj)
            if isempty(obj.dataSource.associatedDataSources)
                dataSource=obj.dataSource;
            else
                dataSource=obj.dataSource.associatedDataSources(1);
            end
        end

        function cacheGroups(obj)
            groupBinValues=obj.getGroups();
            obj.addInfoBinsToGroups(groupBinValues);
            obj.cachedGroups=groupBinValues;
        end

        function clearGroupCache(obj)
            obj.cachedGroups=SimBiology.internal.plotting.categorization.binvalue.GroupBinValue.empty;
        end

        function cacheMatchedGroups(obj,matchedData)

        end

        function cacheCategoryVariableValuesOnGroups(obj,groups,categoryVariablesToCache,dataGroupIdx,matchedGroupIdx)
            if nargin>3
                useSelectedGroups=true;
            else
                useSelectedGroups=false;
            end

            categoryVariables=obj.getCategoryVariables(false);

            groups.setupCategoryVariableCache;

            for i=1:numel(categoryVariablesToCache)
                matched=false;

                for j=1:numel(categoryVariables)
                    if categoryVariablesToCache(i).isEqual(categoryVariables(j))
                        values=obj.getCategoryVariableValuesForGroups(categoryVariablesToCache(i));
                        if useSelectedGroups
                            values=values(dataGroupIdx);
                        end
                        matched=true;
                        break;
                    end
                end

                if~matched
                    for j=1:numel(obj.mergedScalarParameters)
                        if categoryVariablesToCache(i).isEqual(obj.mergedScalarParameters(j).categoryVariable)
                            values=obj.mergedScalarParameters(j).values;
                            if useSelectedGroups
                                values=values(matchedGroupIdx);
                            end
                            matched=true;
                            break;
                        end
                    end
                end

                if matched
                    groups.cacheCategoryVariableValues(categoryVariablesToCache(i),values);
                end
            end
        end

        function bins=getMergedInfoBins(obj)
            bins=obj.getInfoBins();
            if~isempty(obj.mergedInfoBins)
                for i=1:obj.getNumberOfGroups
                    bins{i}=vertcat(bins{i},obj.mergedInfoBins{i});
                end
            end
        end

        function mergeGroupInfo(obj,dataInterfaceToMerge)

            if isempty(obj.mergedInfoBins)
                obj.mergedInfoBins=cell(obj.getNumberOfGroups,1);
            end

            infoBinsToMerge=dataInterfaceToMerge.getInfoBins();


            if isempty(dataInterfaceToMerge.matchedGroupsMap)
                for i=1:obj.getNumberOfGroups
                    obj.mergedInfoBins{i}=[obj.mergedInfoBins{i};infoBinsToMerge{i}];
                end


            elseif dataInterfaceToMerge.hasOneToOneGroupMatchingOnly

                blankInfoBins=SimBiology.internal.plotting.categorization.Bin(infoBinsToMerge{1});
                arrayfun(@(b)set(b.binValue,'value',''),blankInfoBins);

                for groupIdx=1:obj.getNumberOfGroups
                    mergeIdx=dataInterfaceToMerge.matchedGroupsMap{groupIdx};
                    if isempty(mergeIdx)
                        obj.mergedInfoBins{groupIdx}=[obj.mergedInfoBins{groupIdx};blankInfoBins];
                    else
                        obj.mergedInfoBins{groupIdx}=[obj.mergedInfoBins{groupIdx};infoBinsToMerge{mergeIdx}];
                    end
                end


            else
                groupsFromDataToMerge=dataInterfaceToMerge.getGroups();
                categoryVariable=SimBiology.internal.plotting.categorization.CategoryVariable(struct('type',SimBiology.internal.plotting.categorization.CategoryVariable.BIN_SET,...
                'name',dataInterfaceToMerge.dataSource.getShortName(),...
                'subtype',SimBiology.internal.plotting.categorization.CategoryVariable.GROUP,...
                'dataSource',dataInterfaceToMerge.dataSource,...
                'associatedDataSource',[]));
                for groupIdx=1:obj.getNumberOfGroups
                    mergeIdx=dataInterfaceToMerge.matchedGroupsMap{groupIdx};
                    binSetToMerge=SimBiology.internal.plotting.categorization.Bin(...
                    categoryVariable,...
                    SimBiology.internal.plotting.categorization.binvalue.BinSetBinValue({num2str(groupIdx)}));

                    if~isempty(mergeIdx)

                        binSetToMerge.binValue.binValues=groupsFromDataToMerge(mergeIdx);
                    end

                    obj.mergedInfoBins{groupIdx}=[obj.mergedInfoBins{groupIdx};binSetToMerge];
                end
            end
        end

        function addCategoriesFromData(obj,dataToMerge,categories)
            if dataToMerge.hasOneToOneGroupMatchingOnly()
                scalarParameters=dataToMerge.getCategoryVariablesToMerge(categories);
                obj.mergedScalarParameters=vertcat(obj.mergedScalarParameters,scalarParameters);
            end
        end

        function scalarParameters=getCategoryVariablesToMerge(obj,categories)
            if(obj.hasOneToOneGroupMatchingOnly)
                idx=arrayfun(@(c)(~isempty(c.categoryVariable.dataSource)&&...
                c.categoryVariable.dataSource.isEqual(obj.dataSource)),categories);
                categoryVariablesToMerge=vertcat(categories(idx).categoryVariable);
                scalarParameters=arrayfun(@(c)obj.getScalarParameter(c),categoryVariablesToMerge);
            end
        end
    end

    methods(Access=protected)
        function updateUnits(obj)

            if~isempty(obj.columnInfo)

                for i=1:numel(obj.columnInfo)
                    if obj.doesColumnHaveError(obj.columnInfo(i),'units')
                        obj.columnInfo(i).units='';
                    end
                end
            end
        end

        function addInfoBinsToGroups(obj,groupBinValues)
            infoBins=obj.getMergedInfoBins();
            for i=obj.getNumberOfGroups:-1:1
                groupBinValues(i).infoBins=infoBins{i};
            end
        end

        function groupBinValues=createGroupBins(obj)
            names=obj.getGroupNames();

            groupBinValues(obj.getNumberOfGroups)=SimBiology.internal.plotting.categorization.binvalue.GroupBinValue;
            groupBinValues=transpose(groupBinValues);
            for i=obj.getNumberOfGroups:-1:1
                groupBinValues(i)=SimBiology.internal.plotting.categorization.binvalue.GroupBinValue;
                groupBinValues(i).dataSource=obj.dataSource;
                groupBinValues(i).value=names{i};
                groupBinValues(i).setDataIndex(i);
            end
        end
    end

    methods(Static,Access=protected)
        function flag=doesColumnHaveError(column,type)
            flag=~isempty(column.errorMsgs)&&any(strcmpi({column.errorMsgs.type},type));
        end

        function flag=columnHasNoErrors(column)
            flag=isempty(column.errorMsgs)||...
            all(arrayfun(@(e)~strcmp(e.severity,'error'),column.errorMsgs));
        end
    end
end
