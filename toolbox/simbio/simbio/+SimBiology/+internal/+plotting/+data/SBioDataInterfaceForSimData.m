classdef SBioDataInterfaceForSimData<SimBiology.internal.plotting.data.SBioDataInterfaceForTimecourseData&...
    SimBiology.internal.plotting.data.SBioDataInterfaceForScalarData

    properties(Constant)
        TIME='time';
    end

    properties(Access=public)
        scalarParameters=SimBiology.internal.plotting.categorization.ScalarParameter.empty;
        associatedGroupParameters=SimBiology.internal.plotting.categorization.ScalarParameter.empty;
    end

    properties(Access=private)
        runNames=[];


        samplesTable=[];
        scalarObservablesTable=[];
    end




    methods(Access=public)
        function obj=SBioDataInterfaceForSimData(sbiodata,dataSource,columnInfo,dataInfo)
            obj.dataSource=dataSource;

            obj.data=sbiodata;

            obj.data=vertcat(obj.data(:));
            if~isempty(dataInfo)
                obj.dataSource.associatedDataSources=dataInfo.associatedDataSources;
                obj.configureScalarParameters(dataInfo.scalarParameters);
                if isfield(dataInfo,'runNames')
                    obj.runNames=dataInfo.runNames;
                end

            end
            obj.columnInfo=columnInfo;
        end
    end

    methods(Access=protected)
        function configureScalarParameters(obj,scalarParameters)
            if~isempty(scalarParameters)
                idx=isAssociatedGroup([scalarParameters.categoryVariable]);


                obj.associatedGroupParameters=scalarParameters(idx);

                obj.scalarParameters=scalarParameters(~idx);
                obj.scalarParameters.setDataSource(obj.dataSource);
            end
        end
    end




    methods(Access=?SimBiology.internal.plotting.data.SBioDataInterfaceForTimecourseData)
        function data=getDataForVariable(obj,varName)

            if strcmp(varName,obj.TIME)
                data=transpose({obj.data.Time});

            else





                [sd,~]=obj.data.selectbyname(varName,WarnNames=true,Format='simdata');
                data=transpose({sd.Data});
            end
        end

        function timeVariableName=getTimeVariableName(obj)
            timeVariableName=obj.TIME;
        end

        function associatedGroups=getAssociatedGroups(obj,dataSource)
            idx=arrayfun(@(p)p.categoryVariable.associatedDataSource.isEqual(dataSource),obj.associatedGroupParameters);
            associatedGroups=obj.associatedGroupParameters(idx).values;
            set(associatedGroups,'dataSource',dataSource);
        end
    end

    methods(Access=private)
        function data=getDataForVariableSingleGroup(obj,sd,varName)
            idx=strcmp(sd.DataNames,varName);
            if any(idx)
                data=sd.Data(:,idx);
            else
                data=NaN;
            end
        end
    end




    methods(Access=public)
        function numberOfGroups=getNumberOfGroups(obj,varargin)
            numberOfGroups=numel(obj.data);
        end

        function name=getGroupCategoryName(obj)
            if numel(obj.scalarParameters)==1
                name=obj.scalarParameters.categoryVariable.name;
            else
                name='';
            end
        end

        function flag=hasOneToOneGroupMatchingOnly(obj)
            flag=numel(obj.scalarParameters)<=1;
        end

        function cacheMatchedGroups(obj,matchedData)
            if obj.doGroupsMatchOneToOne(matchedData)



                obj.matchedGroupsMap=[];




                associatedGroupBinValues=obj.getAssociatedGroupBinValues();
                if~isempty(associatedGroupBinValues)
                    dataGroups={associatedGroupBinValues.value};
                    matchedDataGroups={matchedData.getGroups().value};
                    [~,matchedDataToDataIdx]=ismember(matchedDataGroups,dataGroups);
                    if~issorted(matchedDataToDataIdx)


                        obj.matchedGroupsMap=num2cell(matchedDataToDataIdx);
                    end
                end
            else
                dataBins=obj.getAssociatedGroups(matchedData.getDataSourceForMatching());
                matchedGroupBins=matchedData.getGroups;
                cacheMatchedGroupsHelper(obj,dataBins,matchedGroupBins);
            end
        end

        function numberOfGroups=getNumberOfAssociatedGroups(obj)
            associatedDataSource=obj.getDataSourceForMatching();
            idx=arrayfun(@(p)p.categoryVariable.associatedDataSource.isEqual(associatedDataSource),obj.associatedGroupParameters);
            numberOfGroups=numel(obj.associatedGroupParameters(idx).binValues);
        end

        function cacheAssociatedGroups(obj)
            associatedDataSource=obj.getDataSourceForMatching();
            dataBins=obj.getAssociatedGroups(associatedDataSource);
            matchedGroupBins=obj.getAssociatedGroupBinValues();
            cacheMatchedGroupsHelper(obj,dataBins,matchedGroupBins);
        end

        function groupBinValues=getAssociatedGroupBinValues(obj)
            groupBinValues=SimBiology.internal.plotting.categorization.binvalue.GroupBinValue.empty;

            associatedDataSource=obj.getDataSourceForMatching();
            idx=arrayfun(@(p)p.categoryVariable.associatedDataSource.isEqual(associatedDataSource),obj.associatedGroupParameters);
            if any(idx)
                assert(sum(idx)==1);
                groupBinValues=obj.associatedGroupParameters(idx).binValues;
                for i=1:numel(groupBinValues)
                    groupBinValues(i).setDataIndex(i);
                end
                obj.addInfoBinsToAssociatedGroups(groupBinValues);
            end
        end

        function flag=anyNumTimepointsPerGroupIsGreaterThan(obj,cutoff)
            flag=false;
            for i=1:numel(obj.data)
                if numel(obj.data(i).Time)>cutoff
                    flag=true;
                    break;
                end
            end
        end
    end

    methods(Access=private)
        function addInfoBinsToAssociatedGroups(obj,groupBinValues)
            associatedDataSource=obj.getDataSourceForMatching();
            categoryVariable=SimBiology.internal.plotting.categorization.CategoryVariable(struct('type',SimBiology.internal.plotting.categorization.CategoryVariable.GROUP,...
            'name',SimBiology.internal.plotting.categorization.CategoryVariable.GROUP,...
            'subtype',[],...
            'dataSource',associatedDataSource,...
            'associatedDataSource',[]));
            values=SimBiology.internal.plotting.categorization.binvalue.GroupBinValue(groupBinValues);
            set(values,'dataSource',associatedDataSource);
            infoBins=arrayfun(@(bin)SimBiology.internal.plotting.categorization.Bin(categoryVariable,bin),values,'UniformOutput',false);
            for i=1:numel(groupBinValues)
                groupBinValues(i).infoBins=infoBins{i};
            end
        end

        function cacheMatchedGroupsHelper(obj,dataBins,matchedGroupBins)
            numGroupBins=numel(matchedGroupBins);
            obj.matchedGroupsMap=cell(numGroupBins,1);


            for matchIdx=1:numGroupBins

                obj.matchedGroupsMap{matchIdx}=transpose(find(arrayfun(@(dataBin)matchedGroupBins(matchIdx).isEqual(dataBin),dataBins)));
            end
        end

        function flag=doGroupsMatchOneToOne(obj,matchedData)












            flag=~obj.dataSource.hasAssociatedDataSource(matchedData.getDataSourceForMatching())||...
            (obj.hasOneToOneGroupMatchingOnly&&(obj.getNumberOfGroups==matchedData.getNumberOfGroups));
        end

        function name=getName(obj,i)
            if isempty(obj.runNames)

                name=['Run ',num2str(i)];
            else
                name=obj.runNames{i};
            end
        end
    end

    methods(Access=?SimBiology.internal.plotting.data.SBioDataInterfaceForTimecourseData)
        function names=getGroupNames(obj)
            idx=transpose(1:obj.getNumberOfGroups);
            names=arrayfun(@(sd,i)obj.getName(i),obj.data,idx,'UniformOutput',false);
        end

        function displayString=getGroupDisplayString(obj)
            displayString='Run';
        end

        function values=getInfoBins(obj)
            if isempty(obj.scalarParameters)

                values=getInfoBins@SimBiology.internal.plotting.data.SBioDataInterfaceForTimecourseData(obj);
            else
                values=cell(obj.getNumberOfGroups,1);
                for i=1:obj.getNumberOfGroups
                    values{i}=arrayfun(@(p)SimBiology.internal.plotting.categorization.Bin(p.categoryVariable,...
                    p.values(i)),obj.scalarParameters);
                end
            end
        end
    end




    methods(Access=public)
        function categoryVariables=getCategoryVariables(obj,excludeAssociatedGroupParameters)
            if isempty(obj.scalarParameters)
                categoryVariables=[];
                return;
            end

            if nargin==1


                excludeAssociatedGroupParameters=true;
            end

            categoryVariables=vertcat(obj.scalarParameters.categoryVariable);
            if numel(categoryVariables)>0
                if excludeAssociatedGroupParameters
                    idx=categoryVariables.isAssociatedGroup;
                    categoryVariables=categoryVariables(~idx);
                end
            end



            if numel(categoryVariables)<=1&&excludeAssociatedGroupParameters
                categoryVariables=[];
            end
        end

        function scalarParameter=getScalarParameter(obj,categoryVariable)
            idx=arrayfun(@(param)param.isEqual(categoryVariable),obj.scalarParameters);
            scalarParameter=obj.scalarParameters(idx);
        end

        function values=getCategoryVariableValuesForGroups(obj,categoryVariable)
            scalarParam=getScalarParameter(obj,categoryVariable);
            values=scalarParam.values;
        end

        function binValues=getCategoryVariableValues(obj,categoryVariable)
            scalarParam=getScalarParameter(obj,categoryVariable);
            binValues=scalarParam.binValues;
        end
    end




    methods(Access=public)
        function flag=supportsSensitivities(obj)
            dataCount=get(obj.data,'DataCount');
            flag=(dataCount.Sensitivity>0);
        end

        function[result,inputStrings,outputStrings]=getIntegratedSensitivities(obj,inputs,outputs)

            [t,R,outputStrings,inputStrings]=getsensmatrix(obj.data,outputs,inputs);
            [~,outputFactors,inputFactors]=size(R);
            result=zeros(outputFactors,inputFactors);
            for i=1:outputFactors
                for j=1:inputFactors
                    index=~isnan(R(:,i,j))&~isinf(R(:,i,j));
                    result(i,j)=trapz(t(index),abs(R(index,i,j)));
                end
            end
        end
    end




    methods(Access=public)
        function flag=supportsPlotMatrixPlot(obj)
            paramTable=obj.getScalarObservablesTable();
            flag=~isempty(paramTable);
        end

        function flag=hasSingleInput(obj)
            flag=isempty(obj.scalarParameters);
        end

        function paramTable=getIndependentParameterTable(obj)
            if obj.hasSingleInput
                paramTable=obj.getScalarObservablesTable();
            else
                paramTable=obj.getSamplesTable();
            end
        end

        function paramNames=getIndependentParameterNames(obj)
            if obj.hasSingleInput
                paramNames=obj.getScalarObervablesNames();
            else
                paramNames=obj.getSamplesNames();
            end
        end

        function paramTable=getDependentParameterTable(obj)
            if obj.hasSingleInput
                paramTable=[];
            else
                paramTable=obj.getScalarObservablesTable();
            end
        end

        function paramNames=getDependentParameterNames(obj)
            if obj.hasSingleInput
                paramNames={};
            else
                paramNames=obj.getScalarObervablesNames();
            end
        end
    end

    methods(Access=private)
        function samplesTable=getSamplesTable(obj)
            if isempty(obj.samplesTable)&&~isempty(obj.scalarParameters)
                samples=arrayfun(@(p)p.values.getScatterplotValue(),obj.scalarParameters,'UniformOutput',false);
                names=arrayfun(@(p)p.categoryVariable.name,obj.scalarParameters,'UniformOutput',false);

                obj.samplesTable=table(samples{:});
                obj.samplesTable.Properties.VariableDescriptions=names;
            end
            samplesTable=obj.samplesTable;
        end

        function paramNames=getSamplesNames(obj)
            paramTable=obj.getSamplesTable();
            paramNames=transpose(paramTable.Properties.VariableDescriptions);
        end

        function scalarObservablesTable=getScalarObservablesTable(obj)
            if isempty(obj.scalarObservablesTable)
                obj.scalarObservablesTable=SimBiology.web.datahandler('getSimdataScalarObservables',obj.data);


                if ismember('SimDataRun',obj.scalarObservablesTable.Properties.VariableNames)
                    obj.scalarObservablesTable.SimDataRun=[];
                end
            end
            scalarObservablesTable=obj.scalarObservablesTable;
        end

        function paramNames=getScalarObervablesNames(obj)
            paramTable=obj.getScalarObservablesTable();
            paramNames=transpose(paramTable.Properties.VariableNames);
        end
    end




    methods(Static,Access=public)

        function timeVector=computeUniformTimeVector(dataSeries,numTimepoints,useParameterizationVariable)
            paramName=SimBiology.internal.plotting.sbioplot.DataSeries.getTimeDataPropertyName(useParameterizationVariable);


            minTime=min(arrayfun(@(ds)ds.(paramName)(1),dataSeries));
            maxTime=max(arrayfun(@(ds)ds.(paramName)(end),dataSeries));
            timeVector=transpose(linspace(minTime,maxTime,numTimepoints));
        end

        function resampledData=resample(timeVector,dataSeries,interpolationMethod)
            for d=numel(dataSeries):-1:1
                ds=dataSeries(d);

                resampledData(:,d)=SimBiology.internal.piecewiseInterpolation(ds.independentVariableData,...
                ds.dependentVariableData,...
                timeVector,...
                interpolationMethod);
            end

            if any(all(isnan(resampledData),1))
                warning(message('SimBiology:Plotting:INTERPOLATION_ALL_NAN'));
            end
        end

        function[resampledDataX,resampledDataY]=resampleWithParameterization(timeVector,dataSeries,interpolationMethod)
            for d=numel(dataSeries):-1:1
                ds=dataSeries(d);

                resampledDataX(:,d)=SimBiology.internal.piecewiseInterpolation(ds.parameterizationVariableData,...
                ds.independentVariableData,...
                timeVector,...
                interpolationMethod);

                resampledDataY(:,d)=SimBiology.internal.piecewiseInterpolation(ds.parameterizationVariableData,...
                ds.dependentVariableData,...
                timeVector,...
                interpolationMethod);
            end

            if any(all(isnan(resampledDataX),1))||any(all(isnan(resampledDataY),1))
                warning(message('SimBiology:Plotting:INTERPOLATION_ALL_NAN'));
            end
        end
    end

end