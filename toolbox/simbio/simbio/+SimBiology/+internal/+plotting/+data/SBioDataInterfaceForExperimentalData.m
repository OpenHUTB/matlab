classdef SBioDataInterfaceForExperimentalData<SimBiology.internal.plotting.data.SBioDataInterfaceForTimecourseData

    properties(Access=private)

numGroups
groupNames
isNumericGroup
tableIndicesByGroup
categoryVariables
    end




    methods(Access=public)
        function obj=SBioDataInterfaceForExperimentalData(sbiodata,dataSource,columnInfo,~)
            obj.dataSource=dataSource;
            switch class(sbiodata)
            case 'groupedData'
                obj.data=sbiodata;
            case{'table','dataset'}
                obj.data=groupedData(sbiodata);
            otherwise
                error("Invalid data source.");
            end

            if iscell(columnInfo)
                columnInfo=vertcat(columnInfo{:});
            end
            obj.columnInfo=columnInfo;
            obj.updateColumnClassifications();
            obj.updateCategoryVariables();
            obj.updateUnits();
        end
    end

    methods(Access=private)
        function updateColumnClassifications(obj)
            if~isempty(obj.columnInfo)

                groupIdx=strcmp({obj.columnInfo.classification},'group');
                indVarIdx=strcmp({obj.columnInfo.classification},'independent');

                groupColumn=obj.columnInfo(groupIdx);
                if numel(groupColumn)==1&&~obj.doesColumnHaveError(groupColumn,'expression')
                    obj.data.Properties.GroupVariableName=groupColumn.name;
                else
                    obj.data.Properties.GroupVariableName='';
                end

                independentColumn=obj.columnInfo(indVarIdx);
                if numel(independentColumn)==1&&~obj.doesColumnHaveError(independentColumn,'expression')
                    obj.data.Properties.IndependentVariableName=independentColumn.name;
                else
                    obj.data.Properties.IndependentVariableName='';
                end
            end
            obj.updateGroupCacheValues;
        end
    end




    methods(Access=?SimBiology.internal.plotting.data.SBioDataInterfaceForTimecourseData)
        function data=getDataForVariable(obj,varName)
            data=cell(obj.getNumberOfGroups,1);
            for i=1:obj.getNumberOfGroups
                data{i}=obj.data{obj.tableIndicesByGroup{i},varName};
            end
        end

        function timeVariableName=getTimeVariableName(obj)
            timeVariableName=obj.data.Properties.IndependentVariableName;
            if isempty(timeVariableName)
                error(message('SimBiology:Plotting:NO_VALID_INDEPENDENT_VARIABLE_COLUMN'));
            end
        end
    end




    methods(Access=public)
        function numberOfGroups=getNumberOfGroups(obj)
            numberOfGroups=obj.numGroups;
        end

        function name=getGroupCategoryName(obj)


            name='';



        end

        function flag=anyNumTimepointsPerGroupIsGreaterThan(obj,cutoff)
            timesByGroup=obj.getDataForTimeVariable();
            numTimes=cellfun(@(t)numel(unique(t)),timesByGroup);
            flag=any(numTimes>cutoff);
        end
    end

    methods(Access=?SimBiology.internal.plotting.data.SBioDataInterfaceForTimecourseData)
        function names=getGroupNames(obj)

            if isnumeric(obj.groupNames)
                names=arrayfun(@(n)num2str(n),obj.groupNames,'UniformOutput',false);
            elseif iscategorical(obj.groupNames)
                names=cellstr(obj.groupNames);
            else
                names=obj.groupNames;
            end
        end

        function displayString=getGroupDisplayString(obj)
            displayString=obj.data.Properties.GroupVariableName;
            if isempty(displayString)
                displayString='';
            end
        end
    end




    methods(Access=public)
        function categoryVariables=getCategoryVariables(obj,excludeAssociatedGroupParameters)
            categoryVariables=obj.categoryVariables;
        end

        function scalarParameter=getScalarParameter(obj,categoryVariable)
            binValues=getCategoryVariableValues(obj,categoryVariable);
            values=getCategoryVariableValuesForGroups(obj,categoryVariable);
            scalarParameter=SimBiology.internal.plotting.categorization.ScalarParameter(categoryVariable,binValues,values);
        end

        function binValues=getCategoryVariableValues(obj,categoryVariable)
            binValues=getUniqueValues(obj,categoryVariable.name);
            if isnumeric(binValues)
                binValues=SimBiology.internal.plotting.categorization.binvalue.NumericBinValue(binValues);
            elseif islogical(binValues)
                binValues=SimBiology.internal.plotting.categorization.binvalue.LogicalBinValue(binValues);
            else
                binValues=SimBiology.internal.plotting.categorization.binvalue.CategoricalBinValue(binValues);
            end
        end

        function values=getCategoryVariableValuesForGroups(obj,categoryVariable)

            catVarValues=obj.data{:,categoryVariable.name};

            idx=transpose(1:obj.getNumberOfGroups);
            if isnumeric(catVarValues)

                values=arrayfun(@(g)mean(catVarValues(obj.tableIndicesByGroup{g}),'omitnan'),idx);
                values=SimBiology.internal.plotting.categorization.binvalue.NumericBinValue(values);
            else

                values=arrayfun(@(g)(catVarValues(find(obj.tableIndicesByGroup{g},1))),idx,'UniformOutput',false);
                if islogical(values)
                    values=SimBiology.internal.plotting.categorization.binvalue.LogicalBinValue(values);
                else
                    values=SimBiology.internal.plotting.categorization.binvalue.CategoricalBinValue(values);
                end
            end
        end
    end





    methods(Access=private)
        function updateGroupCacheValues(obj)
            if~isempty(obj.data.Properties.GroupVariableName)
                obj.groupNames=obj.getUniqueValues(obj.data.Properties.GroupVariableName);

            else
                obj.groupNames={''};
            end
            obj.numGroups=numel(obj.groupNames);
            obj.isNumericGroup=isnumeric(obj.groupNames);
            obj.tableIndicesByGroup=arrayfun(@(group)obj.getTableIndicesForGroup(group),obj.groupNames,'UniformOutput',false);
        end

        function idx=getTableIndicesForGroup(obj,group)
            if obj.numGroups==1
                idx=1:size(obj.data,1);
            else
                namesColumn=obj.data{:,obj.data.Properties.GroupVariableName};

                if isnumeric(obj.groupNames)||iscategorical(obj.groupNames)
                    idx=(group==namesColumn());

                else
                    idx=strcmp(group,namesColumn);
                end
            end
        end

        function updateCategoryVariables(obj)
            idx=arrayfun(@(c)(~strcmp(c.classification,'group')&&...
            ~strcmp(c.classification,'independent')&&...
            ~strcmp(c.classification,'dependent')&&...
            obj.isColumnValidCategoryVariable(c)),obj.columnInfo);
            obj.categoryVariables=arrayfun(@(c)obj.createCategoryVariable(c),obj.columnInfo(idx));
        end

        function flag=isColumnValidCategoryVariable(obj,column)
            flag=obj.columnHasNoErrors(column)&&...
            (~isnumeric(obj.data{:,column.name})||~all(isnan(obj.data{:,column.name})));
        end

        function categoryVariable=createCategoryVariable(obj,columnInfoForVariable)
            if isnumeric(obj.data{1,columnInfoForVariable.name})
                subtype=SimBiology.internal.plotting.categorization.CategoryVariable.CONTINUOUS;
            else
                subtype=SimBiology.internal.plotting.categorization.CategoryVariable.CATEGORICAL;
            end
            categoryVariable=SimBiology.internal.plotting.categorization.CategoryVariable(struct('name',columnInfoForVariable.name,...
            'type',SimBiology.internal.plotting.categorization.CategoryVariable.COVARIATE,...
            'subtype',subtype,...
            'dataSource',obj.dataSource,...
            'associatedDataSource',[]));
        end

        function uniqueValues=getUniqueValues(obj,variableName)
            if isempty(variableName)
                uniqueValues={};
            else
                uniqueValues=obj.data{:,variableName};

                [uniqueValues,iu]=unique(uniqueValues,'first');
                [~,iuidx]=sort(iu);
                uniqueValues=uniqueValues(iuidx);
            end
        end
    end




    methods(Static,Access=public)

        function timeVector=computeUniformTimeVector(dataSeries,~,useParameterizationVariable)
            paramName=SimBiology.internal.plotting.sbioplot.DataSeries.getTimeDataPropertyName(useParameterizationVariable);

            numTimepoints=max(arrayfun(@(ds)numel(unique(ds.(paramName))),dataSeries));


            minTime=min(arrayfun(@(ds)min(ds.(paramName),[],'omitnan'),dataSeries));
            maxTime=max(arrayfun(@(ds)max(ds.(paramName),[],'omitnan'),dataSeries));

            timeVector=transpose(linspace(minTime,maxTime,numTimepoints));
        end

        function resampledData=resample(timeVector,dataSeries,interpolationMethod)
            excludedGroups=SimBiology.internal.plotting.categorization.binvalue.GroupBinValue.empty;

            for d=numel(dataSeries):-1:1
                ds=dataSeries(d);
                [ds.independentVariableData,ds.dependentVariableData]=...
                SimBiology.internal.plotting.data.SBioDataInterfaceForExperimentalData.cleanDataForResample(ds.independentVariableData,ds.dependentVariableData);

                [resampledData(:,d),isExcluded]=SimBiology.internal.plotting.data.SBioDataInterfaceForExperimentalData.applyInterpolation(interpolationMethod,...
                ds.independentVariableData,...
                ds.dependentVariableData,...
                timeVector);


                if isExcluded
                    excludedGroups=[ds.groupBinValue,excludedGroups];%#ok<AGROW>
                end
            end
            SimBiology.internal.plotting.data.SBioDataInterfaceForExperimentalData.warnForExcludedGroups(excludedGroups);

        end

        function[resampledDataX,resampledDataY]=resampleWithParameterization(timeVector,dataSeries,interpolationMethod)
            excludedGroups=SimBiology.internal.plotting.categorization.binvalue.GroupBinValue.empty;
            for d=numel(dataSeries):-1:1
                ds=dataSeries(d);
                [ds.parameterizationVariableData,ds.independentVariableData,ds.dependentVariableData]=...
                SimBiology.internal.plotting.data.SBioDataInterfaceForExperimentalData.cleanDataForResample(ds.parameterizationVariableData,...
                ds.independentVariableData,...
                ds.dependentVariableData);

                [resampledDataX(:,d),isExcluded]=SimBiology.internal.plotting.data.SBioDataInterfaceForExperimentalData.applyInterpolation(interpolationMethod,...
                ds.parameterizationVariableData,...
                ds.independentVariableData,...
                timeVector);

                [resampledDataY(:,d),isExcluded]=SimBiology.internal.plotting.data.SBioDataInterfaceForExperimentalData.applyInterpolation(interpolationMethod,...
                ds.parameterizationVariableData,...
                ds.dependentVariableData,...
                timeVector);

                if isExcluded
                    excludedGroups=[ds.groupBinValue,excludedGroups];%#ok<AGROW>
                end
            end
            SimBiology.internal.plotting.data.SBioDataInterfaceForExperimentalData.warnForExcludedGroups(excludedGroups);
        end

        function[timeVector,varargout]=cleanDataForResample(timeVector,varargin)

            idx=~isnan(timeVector);
            timeVector=timeVector(idx);
            for v=numel(varargin):-1:1
                varargout{v}=varargin{v}(idx);
            end


            [timeVector,idx]=sort(timeVector);
            for v=1:numel(varargout)
                varargout{v}=varargin{v}(idx);
            end



            i=numel(timeVector);
            while i>1
                lastIdx=i;


                while(i>1)&&(timeVector(i)==timeVector(i-1))
                    i=i-1;
                end


                if i~=lastIdx
                    timeVector(i+1:lastIdx)=[];
                    for v=1:numel(varargout)
                        varargout{v}(i)=mean(varargout{v}(i:lastIdx),'omitnan');
                        varargout{v}(i+1:lastIdx)=[];
                    end
                end
                i=i-1;
            end
        end

        function[resampledData,isExcluded]=applyInterpolation(interpolationMethod,originalTimeVector,originalDataVector,targetTimeVector)

            isExcluded=false;
            if numel(originalTimeVector)<2||numel(originalDataVector)<2
                isExcluded=true;
                resampledData=nan(size(targetTimeVector));
            else
                switch interpolationMethod
                case SimBiology.internal.plotting.data.SBioDataInterfaceForTimecourseData.ZOH
                    resampledData=SimBiology.internal.piecewiseInterpolation(originalTimeVector,...
                    originalDataVector,...
                    targetTimeVector,...
                    interpolationMethod);
                otherwise
                    resampledData=interp1(originalTimeVector,...
                    originalDataVector,...
                    targetTimeVector,...
                    interpolationMethod);
                end
                if~isempty(resampledData)&&all(isnan(resampledData))
                    warning(message('SimBiology:Plotting:INTERPOLATION_ALL_NAN'));
                end
            end
        end

        function warnForExcludedGroups(excludedGroups)
            if~isempty(excludedGroups)
                groupList=excludedGroups(1).value;
                for g=2:numel(excludedGroups)
                    groupList=[groupList,', ',excludedGroups(g).value];%#ok<AGROW> 
                end
                warning(message('SimBiology:Plotting:GROUPS_EXCLUDED_FROM_RESAMPLING',groupList));
            end
        end
    end
end