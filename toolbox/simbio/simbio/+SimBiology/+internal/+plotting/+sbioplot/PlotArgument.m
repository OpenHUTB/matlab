classdef PlotArgument<handle&matlab.mixin.SetGet


    properties(Access=public)
        dataSource=SimBiology.internal.plotting.data.DataSource.empty;
        responses=SimBiology.internal.plotting.sbioplot.Response.empty;
    end

    properties(GetAccess=public,SetAccess=private)
        data={};

        isMissing=false;
        matchedDataSource=SimBiology.internal.plotting.data.DataSource.empty;
        matchedDataSourceKey='';
    end

    properties(Access=private)


        dataCache;

        matfileInfo;
    end

    methods
        function obj=PlotArgument(input)
            if nargin>0
                if isempty(input)
                    obj=SimBiology.internal.plotting.sbioplot.PlotArgument.empty;
                    return;
                end

                if~isfield(input,'matfileInfo')
                    [input.matfileInfo]=deal([]);
                end

                numObj=numel(input);
                obj=arrayfun(@(~)SimBiology.internal.plotting.sbioplot.PlotArgument(),transpose(1:numObj));

                dataSources=arrayfun(@(in)SimBiology.internal.plotting.data.DataSource(in.dataSource),input);
                matchedDataSources=arrayfun(@(in)SimBiology.internal.plotting.data.DataSource(in.matchedDataSource),input,'UniformOutput',false);
                arrayfun(@(arg,in,ds,mds)set(arg,...
                'dataSource',ds,...
                'responses',SimBiology.internal.plotting.sbioplot.Response(in.responses),...
                'matfileInfo',in.matfileInfo,...
                'isMissing',in.isMissing,...
                'matchedDataSource',mds{1},...
                'matchedDataSourceKey',in.matchedDataSourceKey),...
                obj,input,dataSources,matchedDataSources);
            end
        end

        function info=getStruct(obj)
            info=arrayfun(@(arg)struct('dataSource',arg.dataSource.getStruct(),...
            'responses',arg.responses.getStruct(),...
            'isMissing',arg.isMissing,...
            'matchedDataSource',arg.matchedDataSource.getStruct(),...
            'matchedDataSourceKey',arg.matchedDataSourceKey),...
            obj);
        end

        function loadData(obj,newdata,plotDefinition)
            for i=1:numel(obj)
                plotArg=obj(i);
                data={};
                updateResponses=false;


                if isempty(newdata)
                    idx=[];
                else
                    idx=arrayfun(@(nd)plotArg.dataSource.isEqual(nd.dataSource),newdata);
                end

                if any(idx)
                    data=newdata(idx).data;
                    dataInfo=newdata(idx).dataInfo;
                    columnInfo=newdata(idx).columnInfo;
                    updateResponses=true;
                end


                if(isempty(data)&&~isempty(plotArg.matfileInfo))
                    [data,dataInfo]=plotArg.loadDataFromMatfile(plotArg.matfileInfo);
                    columnInfo=plotArg.matfileInfo.columnInfo;
                end



                if isempty(data)
                    plotArg.data={};
                    plotArg.isMissing=true;
                else
                    plotArg.setData(data,columnInfo,dataInfo);
                    plotArg.isMissing=false;
                    if updateResponses

                        plotArg.updateResponses(plotDefinition.isTimePlot);
                    end
                end
            end
        end

        function setData(obj,data,columnInfo,dataInfo)

            if nargin==2
                columnInfo=[];
                dataInfo=[];
            end
            obj.data=SimBiology.internal.plotting.data.SBioDataInterface.createSBioDataInterface(data,obj.dataSource,columnInfo,dataInfo);


            if isempty(obj.dataSource)
                obj.dataSource=SimBiology.internal.plotting.data.DataSource();
            end

            obj.dataSource.type=obj.data.getDataType();
        end

        function cacheGroups(obj)
            for i=1:numel(obj)
                if obj(i).useOriginalGroups
                    obj(i).data.cacheGroups();
                else
                    obj(i).data.cacheAssociatedGroups();
                end
            end
        end

        function numGroups=getNumberOfGroups(obj)
            for i=numel(obj):-1:1
                if isa(obj(i).data,'SimBiology.internal.plotting.data.SBioDataInterface')
                    if obj(i).useOriginalGroups()
                        numGroups(i)=obj(i).data.getNumberOfGroups();
                    else
                        numGroups(i)=obj(i).data.getNumberOfAssociatedGroups();
                    end
                else
                    numGroups(i)=NaN;
                end
            end
        end

        function numGroups=getNumberOfAssociatedGroups(obj)
            for i=numel(obj):-1:1
                numGroups(i)=obj(i).data.getNumberOfAssociatedGroups();
            end
        end

        function numResponses=getNumberOfResponses(obj)
            numResponses=numel(obj.responses);
        end

        function flag=hasOneToOneGroupMatchingOnly(obj)
            flag=arrayfun(@(arg)arg.data.hasOneToOneGroupMatchingOnly,obj);
        end

        function flag=useOriginalGroups(obj)
            for i=numel(obj):-1:1
                flag(i)=isempty(obj(i).matchedDataSourceKey)||obj(i).matchedDataSource.isEqualToKey(obj(i).matchedDataSourceKey);
            end
        end

        function resetMatchedDataSources(obj)

            if~isempty(obj(1).dataSource)
                arrayfun(@(arg)set(arg,'matchedDataSource',arg.dataSource),obj);
                arrayfun(@(arg)set(arg,'matchedDataSourceKey',arg.dataSource.key),obj);
            end
        end

        function primaryPlotArguments=matchDataSources(obj,categories)
            obj.resetMatchedDataSources();
            matchedDataSources=containers.Map;
            for i=1:numel(obj)
                plotArg=obj(i);
                dataSource=plotArg.dataSource;
                numGroups=plotArg.getNumberOfGroups();

                associatedDataSource=dataSource.associatedDataSources;
                isMatchPrimaryDataSource=matchedDataSources.isKey(dataSource.key);
                isMatchAssociatedDataSource=~isempty(associatedDataSource)&&matchedDataSources.isKey(associatedDataSource(1).key);

                matched=isMatchPrimaryDataSource||isMatchAssociatedDataSource;


                if isMatchPrimaryDataSource

                    matchedDataSources(dataSource.key)=vertcat(plotArg,matchedDataSources(dataSource.key));


                elseif isMatchAssociatedDataSource

                    matchedDataSources(associatedDataSource(1).key)=vertcat(matchedDataSources(associatedDataSource(1).key),plotArg);


                else
                    keys=matchedDataSources.keys;
                    for k=1:numel(keys)
                        plotArgs=matchedDataSources(keys{k});
                        if(plotArgs(1).getNumberOfGroups==numGroups)

                            matchedDataSources(keys{k})=vertcat(plotArgs,plotArg);
                            matched=true;
                            break;
                        end
                    end
                end

                if~matched
                    if isempty(associatedDataSource)

                        matchedDataSources(dataSource.key)=plotArg;
                    else

                        matchedDataSources(associatedDataSource(1).key)=plotArg;
                    end
                end
            end


            keys=matchedDataSources.keys;
            for i=1:numel(keys)
                plotArgs=matchedDataSources(keys{i});

                if all(plotArgs.hasOneToOneGroupMatchingOnly())||plotArgs(1).dataSource.isEqualToKey(keys{i})
                    matchedDataSourceKey=plotArgs(1).dataSource.key;
                else




                    numGroups=plotArgs(1).getNumberOfAssociatedGroups();
                    isMatch=true;
                    for p=2:numel(plotArgs)
                        if(numGroups~=plotArgs(p).getNumberOfAssociatedGroups())
                            isMatch=false;
                            break;
                        end
                    end
                    if isMatch
                        matchedDataSourceKey=keys{i};
                    else


                        matchedDataSourceKey='';
                        remove(matchedDataSources,keys{i});
                        for p=1:numel(plotArgs)
                            matchedDataSources(plotArgs(p).dataSource.key)=plotArgs(p);
                            plotArgs(p).setMatchedDataSource(plotArgs(p),plotArgs(p).dataSource.key);
                        end
                    end
                end

                if~isempty(matchedDataSourceKey)
                    for j=1:numel(plotArgs)
                        plotArgs(j).setMatchedDataSource(plotArgs(1),matchedDataSourceKey);
                    end
                end
            end


            cellfun(@(plotArgs)plotArgs.mergeInfo(categories),matchedDataSources.values);

            primaryPlotArguments=cellfun(@(plotArgs)plotArgs(1),matchedDataSources.values);
        end

        function setMatchedDataSource(obj,matchedPlotArg,matchedDataSourceKey)

            obj.matchedDataSource=matchedPlotArg.dataSource;
            obj.matchedDataSourceKey=matchedDataSourceKey;

            if obj~=matchedPlotArg
                obj.data.cacheMatchedGroups(matchedPlotArg.data);
            elseif~obj.matchedDataSource.isEqualToKey(matchedDataSourceKey)
                obj.data.cacheAssociatedGroups();
            end
        end

        function mergeInfo(obj,categories)


            primaryDataSource=obj(1);
            for i=2:numel(obj)
                primaryDataSource.data.mergeGroupInfo(obj(i).data);
            end
            for i=1:numel(obj)
                for j=(i+1):numel(obj)
                    obj(i).data.addCategoriesFromData(obj(j).data,categories);
                    obj(j).data.addCategoriesFromData(obj(i).data,categories);
                end
            end
        end

        function groups=getGroups(obj)
            groups=[];
            for i=1:numel(obj)
                if obj(i).useOriginalGroups()
                    groupsToAdd=obj(i).data.getGroups();
                else
                    groupsToAdd=obj(i).data.getAssociatedGroupBinValues();
                end
                groups=vertcat(groups,groupsToAdd);%#ok<AGROW>
            end
        end

        function name=getGroupCategoryName(obj)

            name=obj.data.getGroupCategoryName();
        end

        function flag=areResponsesEmpty(obj)
            flag=arrayfun(@(plotArg)isempty(plotArg.responses),obj);
        end

        function updateResponses(obj,isTimePlot)
            for i=1:numel(obj)
                plotArg=obj(i);
                if~isempty(plotArg.responses)
                    if isTimePlot
                        xVar=plotArg.responses(1).independentVar;
                        if~plotArg.data.containsVariables({xVar})
                            plotArg.responses=SimBiology.internal.plotting.sbioplot.Response.empty;
                            break;
                        end
                        yVar={plotArg.responses.dependentVar};
                        idx=plotArg.data.containsVariables(yVar);
                    else
                        for j=numel(plotArg.responses):-1:1
                            idx(j)=all(plotArg.data.containsVariables({plotArg.responses(j).independentVar;...
                            plotArg.responses(j).dependentVar}));
                        end
                    end
                    plotArg.responses=plotArg.responses(idx);
                end
            end
        end

        function responses=getResponseBins(obj)
            obj.data.updateResponseUnits(obj.responses);
            idx=transpose(1:numel(obj.responses));
            responses=arrayfun(@(response,i)SimBiology.internal.plotting.categorization.binvalue.ResponseBinValue(struct('dataSource',obj.dataSource,...
            'index',i,...
            'isSimulation',obj.isSimulation,...
            'value',response,...
            'displayType','',...
            'info',struct)),...
            obj.responses,idx);
        end

        function values=getCategoryVariableValues(obj,categoryVariable)
            if isa(obj.data,'SimBiology.internal.plotting.data.SBioDataInterface')
                values=obj.data.getCategoryVariableValues(categoryVariable);
            else
                values=SimBiology.internal.plotting.categorization.binvalue.BinValue.empty;
            end
        end

        function values=getCategoryVariableValuesForGroups(obj,categoryVariable)
            if isa(obj.data,'SimBiology.internal.plotting.data.SBioDataInterface')
                values=obj.data.getCategoryVariableValuesForGroups(categoryVariable);
            else
                values=SimBiology.internal.plotting.categorization.binvalue.BinValue.empty;
            end
        end

        function flag=getName(obj)
            flag=obj.DataSource.getName();
        end

        function flag=isEqual(obj,comparisonObj)
            if isa(comparisonObj,'SimBiology.internal.plotting.data.DataSource')
                flag=obj.dataSource.isEqual(comparisonObj);
            else
                flag=obj.dataSource.isEqual(comparisonObj.dataSource);
            end
        end

        function flag=isSimulation(obj)
            flag=isa(obj.data,'SimBiology.internal.plotting.data.SBioDataInterfaceForSimData');
        end

        function flag=anyMissingData(obj)
            flag=any([obj.isMissing]);
        end

        function cacheData(obj,targetXUnits,targetYUnits,categories,plotDefinition)
            for i=1:numel(obj)
                plotArg=obj(i);
                if~plotArg.isMissing
                    plotArg.dataCache=plotArg.data.getDataSeries(plotArg,targetXUnits,targetYUnits,categories,plotDefinition);
                end
            end
        end

        function dataSeries=getCachedData(obj,responseBinValue)


            idx=arrayfun(@(response)response.isEqual(responseBinValue.value),obj.responses);
            dataSeries=obj.dataCache{idx};
        end

        function plotArgument=getPlotArgumentForDataSource(obj,dataSource)
            for i=1:numel(obj)
                if(obj(i).dataSource.isEqualByKey(dataSource))
                    plotArgument=obj(i);
                    break;
                end
            end
        end

        function dataSources=getDataSources(obj)

            if isempty(obj)
                dataSources=SimBiology.internal.plotting.data.DataSource.empty;
            else
                dataSources=[obj.dataSource];
            end
        end
    end


    methods(Access=public)
        function flag=supportsPlotMatrixPlot(obj)
            flag=~isempty(obj)&&obj.data.supportsPlotMatrixPlot();
        end

        function flag=hasSingleInput(obj)
            flag=obj.data.hasSingleInput();
        end

        function paramNames=getIndependentParameterNames(obj)
            paramNames=obj.data.getIndependentParameterNames();
        end

        function paramNames=getDependentParameterNames(obj)
            paramNames=obj.data.getDependentParameterNames();
        end

        function paramTable=getIndependentParameterTable(obj)
            paramTable=obj.data.getIndependentParameterTable();
        end

        function paramTable=getDependentParameterTable(obj)
            paramTable=obj.data.getDependentParameterTable();
        end
    end


    methods(Access=public)
        function flag=supportsSensitivities(obj)
            flag=~isempty(obj)&&all(arrayfun(@(o)o.data.supportsSensitivities(),obj));
        end

        function[result,inputStrings,outputStrings]=getIntegratedSensitivities(obj,inputs,outputs)
            [result,inputStrings,outputStrings]=getIntegratedSensitivities(obj.data,inputs,outputs);
        end
    end


    methods(Access=public)
        function cacheTaskResult(obj,plotType,varargin)
            obj.data.cacheTaskResult(plotType,varargin{:});
        end

        function numResponses=getNumberOfComparedResponses(obj)
            numResponses=obj.data.getNumberOfComparedResponses();
        end

        function names=getObservationResponseNames(obj)
            names=obj.data.getObservationResponseNames();
        end

        function names=getPredictionResponseNames(obj)
            names=obj.data.getPredictionResponseNames();
        end

        function flag=shouldApplyUnitConversion(obj)
            flag=obj.data.shouldApplyUnitConversion();
        end

        function flag=supportsPopulationFit(obj)
            flag=obj.data.supportsPopulationFit();
        end

        function[obsPlotArg,predPlotArg]=getFitPlotArguments(obj,isPopulation)
            [obsPlotArg,predPlotArg]=obj.data.getFitPlotArguments(isPopulation);
        end
    end


    methods(Access=public)
        function numParameterTypes=getNumberOfParameterTypes(obj)
            numParameterTypes=obj.data.getNumberOfParameterTypes();
        end

        function residualTypes=getResidualTypes(obj)
            residualTypes=obj.data.getResidualTypes();
        end

        function residuals=getResiduals(obj)
            residuals=obj.data.getResiduals();
        end

        function stackedTimes=getStackedTimes(obj)
            stackedTimes=obj.data.getStackedTimes();
        end

        function stackedPredictions=getStackedPredictions(obj)
            stackedPredictions=obj.data.getStackedPredictions();
        end

        function stackedObservations=getStackedObservations(obj)
            stackedObservations=obj.data.getStackedObservations();
        end

        function stackedGroups=getStackedGroups(obj)
            stackedGroups=obj.data.getStackedGroups();
        end

        function responseUnits=getComparedResponseUnits(obj)
            [responseUnits,~]=obj.data.getResponseUnits();
        end
    end


    methods(Access=public)
        function beta=getEstimatedParameterData(obj)
            beta=obj.data.getEstimatedParameterData();
        end

        function transformedNames=getTransformedEstimatedParameterNames(obj)
            transformedNames=obj.data.getTransformedEstimatedParameterNames();
        end

        function displayString=getEstimatedParametersDescriptionString(obj)
            displayString=obj.data.getEstimatedParametersDescriptionString();
        end
    end


    methods(Access=public)
        function flag=supportsProfileLikelihood(obj)
            flag=obj.data.supportsProfileLikelihood();
        end

        function flag=isParameterConfidenceInterval(obj)
            flag=obj.data.isParameterConfidenceInterval();
        end
    end


    methods(Access=public)
        function flag=isMPGSA(obj)
            flag=strcmp(obj.dataSource.type,'SimBiology.gsa.MPGSA');
        end

        function flag=isSobol(obj)
            flag=strcmp(obj.dataSource.type,'SimBiology.gsa.Sobol');
        end

        function flag=isElementaryEffects(obj)
            flag=strcmp(obj.dataSource.type,'SimBiology.gsa.ElementaryEffects');
        end

        function names=getParameterNames(obj)
            names=obj.data.getParameterNames();
        end

        function names=getObservableNames(obj)
            names=obj.data.getObservableNames();
        end

        function names=getClassifierNames(obj)
            names=obj.data.getClassifierNames();
        end

        function flag=isEmptyGSAResults(obj)
            flag=obj.data.isEmptyGSAResults();
        end
    end


    methods(Static,Access=private)
        function[data,dataInfo]=loadDataFromMatfile(matfileInfo)
            dataInfo=[];
            data=[];

            if isempty(matfileInfo.matfileName)
                return;
            end

            originalData=SimBiology.internal.plotting.sbioplot.PlotArgument.loadVariable(matfileInfo.matfileName,matfileInfo.matfileVariableName);
            variableName=matfileInfo.variableName;


            if isstruct(originalData)&&isfield(originalData,variableName)
                data=originalData.(variableName);


                dataInfoStruct=SimBiology.internal.plotting.sbioplot.PlotArgument.loadVariable(matfileInfo.matfileName,'dataInfo');
                if isfield(dataInfoStruct,variableName)
                    dataInfo=dataInfoStruct.(variableName);
                end


            elseif isempty(variableName)
                data=originalData;


                derivedData=SimBiology.internal.plotting.sbioplot.PlotArgument.loadVariable(matfileInfo.matfileName,matfileInfo.matfileDerivedVariableName);
                if~isempty(derivedData)&&isa(data,'table')
                    derivedData=derivedData;
                    data=[data,derivedData];
                end
            end
        end

        function data=loadVariable(matfile,matfileVarName)
            data=SimBiology.web.codegenerationutil('loadVariable',matfile,matfileVarName);
        end
    end
end