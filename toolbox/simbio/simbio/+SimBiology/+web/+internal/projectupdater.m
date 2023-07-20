classdef projectupdater<SimBiology.web.internal.abstractProjectHelper











    properties
        converted=false;
        projectStruct=[];
    end

    methods
        function backupIfNeeded(obj,sbioprojectObj,projectPath)
            version=sbioprojectObj.getProjectVersion();
            if isempty(version)||version<obj.getCurrentVersion
                matlabRelease=sbioprojectObj.getReleaseVersion();
                backupProject(obj,projectPath,matlabRelease);
            end
        end

        function updateProject(obj,sbioprojectObj,projectStruct)
            obj.converted=false;
            originalProject=projectStruct;
            obj.projectStruct=projectStruct;
            try

                version=findProjectVersion(sbioprojectObj,projectStruct);
                if isempty(version)
                    return;
                end

                obj.convertVersionOneToOnePointOne(version);
                obj.updateProgramDataInfo(version);
                obj.updatePlots(version);
            catch e
                obj.projectStruct=originalProject;
                obj.converted=false;
                obj.addError(message('SimBiology:sbioloadproject:ProjectUpdateFailed').getString(),e);
            end
        end
    end

    methods(Access=private)
        function convertVersionOneToOnePointOne(obj,version)











            if(version>1)
                return;
            end


            obj.converted=true;

            projectStruct=obj.projectStruct;


            programs=projectStruct.Programs;


            if iscell(projectStruct.ProgramData.data)
                projectStruct.ProgramData.data=[projectStruct.ProgramData.data{:}];
            end


            projectStruct=updateExternalDataSimData(projectStruct);

            for i=1:numel(programs)
                program=programs{i};


                if program.programType~=10

                    program=updateStatisticsToObservables(program);
                    projectStruct.Programs{i}=program;


                    projectStruct=addObservablesToLastRun(program,i,projectStruct);



                    data=projectStruct.ProgramData.data;
                    for j=1:numel(data)
                        if~strcmp(data(j).name,'LastRun')&&strcmp(data(j).programName,program.programName)
                            [runInfo,~]=addObservableToSavedSimData(program,data(j),{});
                            data(j)=runInfo;
                        end
                    end
                    projectStruct.ProgramData.data=data;
                end
            end





            for i=1:numel(programs)
                program=programs{i};

                if program.programType==10


                    program=updateStatisticsToObservables(program);
                    projectStruct.Programs{i}=program;


                    projectStruct=convertStatsLastRunToSimData(program,projectStruct);



                    projectStruct=convertStatsSavedRunToSimData(program,projectStruct);
                end
            end




            for i=1:numel(projectStruct.Models)
                m=SimBiology.web.modelhandler('getModelFromSessionID',projectStruct.Models(i).obj);
                projectStruct.Models(i).info.observables=SimBiology.web.modelhandler('resolveObservables',m);
            end



            for i=numel(projectStruct.PlotDocuments):-1:1
                try
                    plotDoc=projectStruct.PlotDocuments(i);
                    if strcmpi(plotDoc.axes(1).plotStyle,'plotMatrix')&&~isempty(plotDoc.definition.dataSources)
                        variableName=plotDoc.definition.dataSources.dataSource.variableName;

                        if~iscell(variableName)
                            variableName={variableName};
                        end
                        if any(strcmpi(variableName,'stats'))

                            variableName={'samples','results'};

                            plotDoc.definition.dataSources.dataSource.variableName=variableName;

                            for j=1:numel(plotDoc.axes)
                                plotDoc.axes(j).plotArguments.dataSource.variableName=variableName;
                            end
                            projectStruct.PlotDocuments(i)=plotDoc;
                        end
                    end
                catch e
                    projectStruct.PlotDocuments(i)=[];
                    obj.addError(message('SimBiology:sbioloadproject:PlotMatrixFormatConversionFailed').getString(),e);
                end
            end

            obj.projectStruct=projectStruct;
        end

        function updatePlots(obj,version)
            if isempty(version)||numel(obj.projectStruct.PlotDocuments)==0
                return;
            elseif version<3.0

                obj.updatePre21aPlotStructs();
            elseif version<=3.1

                obj.updatePercentilePlots();
            end
        end

        function updatePre21aPlotStructs(obj)
            obj.converted=true;
            count=1;
            plotDocuments=struct('figure',{},'axes',{},'definition',{});
            for i=numel(obj.projectStruct.PlotDocuments):-1:1
                try
                    oldPlotStruct=obj.projectStruct.PlotDocuments(i);
                    figureInfo=obj.getFigureInfo(oldPlotStruct);
                    axesInfo=obj.getAxesInfo(oldPlotStruct);
                    definition=obj.getDefinition(oldPlotStruct);
                    plotDocuments(count)=struct('figure',figureInfo.getStruct(),...
                    'axes',axesInfo.getStruct(),...
                    'definition',definition.getStruct());
                    count=count+1;
                catch e
                    obj.addError(message('SimBiology:sbioloadproject:PlotFormatConversionFailed').getString(),e);
                end
            end

            obj.projectStruct.PlotDocuments=fliplr(plotDocuments);
        end

        function updatePercentilePlots(obj)
            plotDocuments=obj.projectStruct.PlotDocuments;
            for i=1:numel(obj.projectStruct.PlotDocuments)
                plotInfo=obj.projectStruct.PlotDocuments(i);


                if isfield(plotInfo,'currentPlotStyle')&&...
                    (strcmp(plotInfo.currentPlotStyle,SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.TIME)||...
                    strcmp(plotInfo.currentPlotStyle,SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.PERCENTILE))
                    for d=1:numel(plotInfo.definition)

                        if strcmp(plotInfo.definition(d).plotStyle,SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.PERCENTILE)
                            obj.converted=true;
                            plotInfo.definition(d)=obj.updatePercentilePlotDefinitionProperties(plotInfo.definition(d));
                            break;
                        end
                    end
                    plotDocuments(i)=plotInfo;
                end
            end


            obj.projectStruct.PlotDocuments=plotDocuments;
        end

        function updateProgramDataInfo(obj,version)

            if isempty(version)||version>=3.0
                return;
            end


            oldWarningState=warning('off');
            warningStateCleanup=onCleanup(@()warning(oldWarningState));

            programDataStruct=obj.projectStruct.ProgramData.data;
            for i=1:numel(programDataStruct)
                try
                    isDataInfoCell=iscell(programDataStruct(i).dataInfo);


                    if isDataInfoCell
                        hasSimData=any(cellfun(@(di)strcmp(di.type,'SimData'),programDataStruct(i).dataInfo));
                    else
                        hasSimData=any(arrayfun(@(di)strcmp(di.type,'SimData'),programDataStruct(i).dataInfo));
                    end
                    if~hasSimData
                        break;
                    end

                    matfileName=programDataStruct(i).matfileName;
                    dataStruct=load(matfileName);
                    if isempty(dataStruct.data)
                        break;
                    end

                    variableNames=fieldnames(dataStruct.data);

                    hasResults=any(strcmp(variableNames,'results'));
                    if hasResults
                        results=dataStruct.data.results;
                    else
                        results=[];
                    end
                    isScan=any(strcmp(variableNames,'samples'));
                    isOverlay=hasResults&&isa(results,'SimData')&&SimBiology.web.simdatainfohandler('usedSliders',results);

                    for j=1:numel(programDataStruct(i).dataInfo)
                        if isDataInfoCell
                            programDataInfo=programDataStruct(i).dataInfo{j};
                        else
                            programDataInfo=programDataStruct(i).dataInfo(j);
                        end

                        if strcmp(programDataInfo.type,'SimData')

                            input=struct;
                            input.name=programDataInfo.name;
                            input.next=dataStruct.data.(programDataInfo.name);
                            input.additionalArgs=dataStruct.data;

                            [info,dataInfoOut]=SimBiology.web.datahandler('getDataInfo',input);
                            programDataInfo.columnInfo=SimBiology.web.datahandler('getColumnInfoFromDataInfo',info,input.next);


                            if(isScan||isOverlay)&&strcmp(programDataInfo.name,'results')

                                programDataInfo.associatedDataSources=arrayfun(@(ds)ds.getStruct(),...
                                dataInfoOut.associatedDataSources);
                                programDataInfo.scalarParameters=arrayfun(@(catVar)catVar.getStruct(true),...
                                [dataInfoOut.scalarParameters.categoryVariable]);


                                dataInfo=struct('results',dataInfoOut);
                                SimBiology.web.datahandler('saveDataToMATFile',dataInfo,'dataInfo',matfileName);
                            end
                        end

                        if isDataInfoCell
                            programDataStruct(i).dataInfo{j}=programDataInfo;
                        else
                            programDataStruct(i).dataInfo(j)=programDataInfo;
                        end
                    end
                catch ex

                end
            end
            obj.projectStruct.ProgramData.data=programDataStruct;
        end
    end

    methods(Static,Access=private)
        function currentVersion=getCurrentVersion
            projectVersionFile=fullfile(matlabroot,'toolbox','simbio','simbio','+SimBiology','+web','+templates','projectVersion.json');
            jsonObj=jsondecode(fileread(projectVersionFile));
            currentVersion=jsonObj.currentVersion;
        end
    end

    methods(Static,Access=private)
        function figureInfo=getFigureInfo(oldPlotStruct)
            oldProps=oldPlotStruct.figure.properties;

            figureInfo=SimBiology.internal.plotting.hg.FigureInfo;

            figureInfo.name=oldPlotStruct.name;

            props=struct('Row',oldProps.Row,...
            'Column',oldProps.Column,...
            'Title',oldProps.Title,...
            'XLabel',oldProps.XLabel,...
            'YLabel',oldProps.YLabel,...
            'Insets',oldProps.Insets,...
            'Gap',oldProps.Gap,...
            'LinkedX',oldProps.LinkedX,...
            'LinkedY',oldProps.LinkedY);
            figureInfo.setProps(props);
        end

        function axesInfo=getAxesInfo(oldPlotStruct)

            oldAxesProps=[oldPlotStruct.axes.properties];

            axesInfo=arrayfun(@(idx)SimBiology.internal.plotting.hg.AxesInfo,transpose(1:numel(oldAxesProps)));

            xScale=arrayfun(@(ax)SimBiology.web.internal.projectupdater.convertBooleanToScale(ax.XScale),...
            oldAxesProps,'UniformOutput',false);
            yScale=arrayfun(@(ax)SimBiology.web.internal.projectupdater.convertBooleanToScale(ax.YScale),...
            oldAxesProps,'UniformOutput',false);
            xGrid=arrayfun(@(ax)SimBiology.web.internal.projectupdater.convertBooleanToOnOff(ax.XGrid),...
            oldAxesProps,'UniformOutput',false);
            yGrid=arrayfun(@(ax)SimBiology.web.internal.projectupdater.convertBooleanToOnOff(ax.YGrid),...
            oldAxesProps,'UniformOutput',false);

            props=struct('Title',{oldAxesProps.Title},...
            'XLabel',{oldAxesProps.XLabel},...
            'YLabel',{oldAxesProps.YLabel},...
            'XGrid',xGrid,...
            'YGrid',yGrid,...
            'GridColor',{oldAxesProps.GridColor},...
            'GridLineStyle',{oldAxesProps.GridLineStyle},...
            'XScale',xScale,...
            'YScale',yScale);
            props=transpose(props);
            axesInfo.setProps(props);
        end

        function definition=getDefinition(oldPlotStruct)
            definition=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition;

            definition.plotStyle=oldPlotStruct.axes(1).plotStyle;


            oldPlotArgs=oldPlotStruct.definition.dataSources;
            if isempty(oldPlotArgs)
                oldPlotArgs=oldPlotStruct.axes(1).plotArguments;
            elseif strcmp(definition.plotStyle,SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.PLOTMATRIX)


                if iscell(oldPlotArgs.dataSource.variableName)
                    oldPlotArgs.dataSource.variableName=oldPlotArgs.dataSource.variableName{end};
                end
            end

            if~isempty(oldPlotArgs)
                definition.plotArguments=arrayfun(@(oldArg)SimBiology.web.internal.projectupdater.getPlotArgument(definition.plotStyle,oldArg,oldPlotStruct),oldPlotArgs);
            end


            definition.props=SimBiology.web.internal.projectupdater.getDefinitionProps(definition.plotStyle,oldPlotStruct);
        end

        function plotArgument=getPlotArgument(plotStyle,oldPlotArg,oldPlotStruct)
            plotArgument=SimBiology.internal.plotting.sbioplot.PlotArgument;

            plotArgument.dataSource=SimBiology.internal.plotting.data.DataSource(oldPlotArg.dataSource);

            if strcmp(plotStyle,'time')||strcmp(plotStyle,'xy')
                responses(numel(oldPlotArg.y),1)=SimBiology.internal.plotting.sbioplot.Response;
                oldPlotArg.x=vertcat(oldPlotArg.x(:));
                oldPlotArg.y=vertcat(oldPlotArg.y(:));
                arrayfun(@(r,x,y)set(r,'independentVar',x{1},'dependentVar',y{1}),responses,oldPlotArg.x,oldPlotArg.y);
                plotArgument.responses=responses;
            end

        end

        function props=getDefinitionProps(plotStyle,oldPlotStruct)
            import SimBiology.internal.plotting.sbioplot.definition.*;

            switch(plotStyle)
            case{PlotDefinition.ACTUAL_VS_PREDICTED}
                props=SimBiology.web.internal.projectupdater.getActualVsPredictedDefinitionProps(oldPlotStruct);
            case{PlotDefinition.BOX}
                props=SimBiology.web.internal.projectupdater.getBoxPlotDefinitionProps(oldPlotStruct);
            case{PlotDefinition.CONFIDENCE_INTERVAL}
                props=SimBiology.web.internal.projectupdater.getConfidenceIntervalDefinitionProps(oldPlotStruct);
            case{PlotDefinition.FIT}
                props=SimBiology.web.internal.projectupdater.getFitPlotDefinitionProps(oldPlotStruct);
            case{PlotDefinition.PLOTMATRIX}
                props=SimBiology.web.internal.projectupdater.getPlotMatrixDefinitionProps(oldPlotStruct);
            case{PlotDefinition.RESIDUAL_DISTRIBUTION}
                props=SimBiology.web.internal.projectupdater.getResidualDistributionDefinitionProps(oldPlotStruct);
            case{PlotDefinition.RESIDUALS}
                props=SimBiology.web.internal.projectupdater.getResidualsDefinitionProps(oldPlotStruct);
            case{PlotDefinition.SENSITIVITY}
                props=SimBiology.web.internal.projectupdater.getSensitivityDefinitionProps(oldPlotStruct);
            case{PlotDefinition.TIME}
                props=SimBiology.web.internal.projectupdater.getTimeLineDefinitionProps(oldPlotStruct);
            case{PlotDefinition.XY}
                props=SimBiology.web.internal.projectupdater.getXYLineDefinitionProps(oldPlotStruct);
            otherwise
                props=SimBiology.web.internal.projectupdater.getAnyDefinitionProps(oldPlotStruct);
            end
        end

        function props=getSensitivityDefinitionProps(oldPlotStruct)
            props=SimBiology.internal.plotting.sbioplot.definition.SensitivityDefinitionProps();

            if isfield(oldPlotStruct.axes.properties.StyleProperties,'inputs')
                props.Inputs=oldPlotStruct.axes.properties.StyleProperties.inputs;
            end
            if isfield(oldPlotStruct.axes.properties.StyleProperties,'outputs')
                props.Outputs=oldPlotStruct.axes.properties.StyleProperties.outputs;
            end
        end

        function props=getPlotMatrixDefinitionProps(oldPlotStruct)
            props=SimBiology.internal.plotting.sbioplot.definition.PlotMatrixDefinitionProps();

            if~isempty(oldPlotStruct.definition.dataSources)
                props.SingleInput=numel(oldPlotStruct.definition.dataSources.dataSource.variableName)<2;
                if isfield(oldPlotStruct.figure.properties.StyleProperties,'XParameters')
                    props.XParameters=oldPlotStruct.figure.properties.StyleProperties.XParameters;
                end
                if isfield(oldPlotStruct.figure.properties.StyleProperties,'YParameters')
                    props.YParameters=oldPlotStruct.figure.properties.StyleProperties.YParameters;
                end
            end
        end

        function props=getFitPlotDefinitionProps(oldPlotStruct)
            props=SimBiology.internal.plotting.sbioplot.definition.FitPlotDefinitionProps();
            if isfield(oldPlotStruct.figure.properties.StyleProperties,'FitType')
                props.Type=oldPlotStruct.figure.properties.StyleProperties.FitType;
            end
            if isfield(oldPlotStruct.figure.properties.StyleProperties,'Layout')
                props.Layout=oldPlotStruct.figure.properties.StyleProperties.Layout;
            end
        end

        function props=getActualVsPredictedDefinitionProps(oldPlotStruct)
            props=SimBiology.internal.plotting.sbioplot.definition.ActualVsPredictedDefinitionProps();
        end

        function props=getResidualsDefinitionProps(oldPlotStruct)
            props=SimBiology.internal.plotting.sbioplot.definition.ResidualsDefinitionProps();
            if isfield(oldPlotStruct.figure.properties.StyleProperties,'XAxis')
                props.XAxis=oldPlotStruct.figure.properties.StyleProperties.XAxis;
            end
        end

        function props=getResidualDistributionDefinitionProps(oldPlotStruct)
            props=SimBiology.internal.plotting.sbioplot.definition.ResidualDistributionDefinitionProps();
        end

        function props=getBoxPlotDefinitionProps(oldPlotStruct)
            props=SimBiology.internal.plotting.sbioplot.definition.BoxPlotDefinitionProps();
        end

        function props=getConfidenceIntervalDefinitionProps(oldPlotStruct)
            props=SimBiology.internal.plotting.sbioplot.definition.ConfidenceIntervalDefinitionProps();

            if isfield(oldPlotStruct.figure.properties.StyleProperties,'SupportsProfileLikelihood')
                props.SupportsProfileLikelihood=oldPlotStruct.figure.properties.StyleProperties.SupportsProfileLikelihood;
            end
            if isfield(oldPlotStruct.figure.properties.StyleProperties,'ProfileLikelihood')
                props.ProfileLikelihood=oldPlotStruct.figure.properties.StyleProperties.ProfileLikelihood;
            end
            if isfield(oldPlotStruct.figure.properties.StyleProperties,'Layout')
                props.Layout=oldPlotStruct.figure.properties.StyleProperties.Layout;
            end
        end

        function props=getTimeLineDefinitionProps(oldPlotStruct)
            props=SimBiology.internal.plotting.sbioplot.definition.TimeLineDefinitionProps();
            SimBiology.web.internal.projectupdater.configureCategoryDefinitionProps(oldPlotStruct,props);
        end

        function props=getXYLineDefinitionProps(oldPlotStruct)
            props=SimBiology.internal.plotting.sbioplot.definition.XYLineDefinitionProps();
            SimBiology.web.internal.projectupdater.configureCategoryDefinitionProps(oldPlotStruct,props);
        end

        function props=getAnyDefinitionProps(~)
            props=SimBiology.internal.plotting.sbioplot.definition.DefinitionProps();
        end

        function configureCategoryDefinitionProps(oldPlotStruct,props)

            if isfield(oldPlotStruct.figure.properties,'UnitConversion')
                props.UnitConversion=oldPlotStruct.figure.properties.UnitConversion;
            end


            if isfield(oldPlotStruct.definition,'matchGroupsAcrossDataSources')
                props.MatchGroupsAcrossDataSources=oldPlotStruct.definition.matchGroupsAcrossDataSources;
            end

            if isfield(oldPlotStruct.definition,'autoAddAllStatesToLog')
                props.AutoAddAllStatesToLog=oldPlotStruct.definition.autoAddAllStatesToLog;
            else
                props.AutoAddAllStatesToLog=false;
            end


            oldCategories=oldPlotStruct.figure.properties.StyleProperties.Categories;
            if~isempty(oldCategories)
                props.Categories=arrayfun(@(oldCategory)SimBiology.web.internal.projectupdater.getCategory(oldCategory,oldPlotStruct),oldCategories);
            end
        end

        function category=getCategory(oldCategory,oldPlotStruct)
            category=SimBiology.internal.plotting.categorization.CategoryDefinition;

            category.categoryVariable=SimBiology.web.internal.projectupdater.getCategoryVariable(oldCategory,oldPlotStruct);
            category.style=oldCategory.style;
            category.isCategorical=strcmp(oldCategory.groupingType,'categorical');
            if~category.isCategorical
                category.numBins=oldCategory.numBins;
            end
            if~isempty(oldCategory.data)
                category.binSettings=arrayfun(@(oldBin)SimBiology.web.internal.projectupdater.getBinSettings(category,oldBin,oldPlotStruct),oldCategory.data);
            end
        end

        function categoryVariable=getCategoryVariable(oldCategory,oldPlotStruct)
            import SimBiology.internal.plotting.categorization.*;

            categoryVariable=SimBiology.internal.plotting.categorization.CategoryVariable;

            oldCategoryVariable=oldCategory.groupingVariable;


            if ischar(oldCategoryVariable)
                categoryVariable.type=oldCategoryVariable;
                categoryVariable.subtype=[];
                categoryVariable.name=oldCategoryVariable;


            else

                categoryVariable.name=oldCategoryVariable.categoryVariable;


                categoryVariable.dataSource=SimBiology.internal.plotting.data.DataSource(oldCategoryVariable.dataSource);


                if isempty(oldCategoryVariable.dataSource.programName)

                    categoryVariable.type=CategoryVariable.COVARIATE;


                    if strcmp(oldCategory.groupingType,'categorical')
                        categoryVariable.subtype=CategoryVariable.CATEGORICAL;
                    else
                        categoryVariable.subtype=CategoryVariable.CONTINUOUS;
                    end


                else

                    categoryVariable.type=CategoryVariable.PARAM;


                    categoryVariable.subtype=CategoryVariable.CATEGORICAL;
                end
            end
        end

        function binSettings=getBinSettings(category,oldBin,oldPlotStruct)
            binSettings=SimBiology.internal.plotting.categorization.BinSettings;

            binSettings.color=oldBin.color;
            if isempty(oldBin.linewidth)
                oldBin.linewidth=SimBiology.internal.plotting.categorization.BinSettings.MIN_WIDTH;
            end
            binSettings.linespec=struct('linestyle',oldBin.linestyle,...
            'linewidth',oldBin.linewidth,...
            'marker',oldBin.marker);
            binSettings.show=oldBin.show;


            oldBinValue=oldBin.value;
            if iscell(oldBinValue)
                oldBinValue=oldBinValue{1};
            end
            if category.isResponse
                binSettings.value=SimBiology.web.internal.projectupdater.getResponseBinValue(oldBinValue,oldPlotStruct);
            elseif category.isResponseSet
                binSettings.value=SimBiology.web.internal.projectupdater.getResponseSetBinValue(oldBinValue,oldPlotStruct,oldBin);
            elseif category.isGroup
                binSettings.value=SimBiology.web.internal.projectupdater.getGroupBinValue(oldBinValue,oldPlotStruct);
            elseif category.isContinuousCovariate
                binSettings.value=SimBiology.web.internal.projectupdater.getRangeBinValue(oldBinValue,oldPlotStruct);
            else
                binSettings.value=SimBiology.web.internal.projectupdater.getCategoricalBinValue(oldBinValue,oldPlotStruct);
            end

        end

        function binValue=getResponseBinValue(oldBinValue,oldPlotStruct)
            binValue=SimBiology.internal.plotting.categorization.binvalue.ResponseBinValue;

            binValue.value=SimBiology.internal.plotting.sbioplot.Response;
            set(binValue.value,'independentVar',oldBinValue.x,'dependentVar',oldBinValue.y);

            if isfield(oldBinValue,'dataSource')
                binValue.dataSource=SimBiology.internal.plotting.data.DataSource(oldBinValue.dataSource);

            else
                binValue.dataSource=SimBiology.internal.plotting.data.DataSource(oldPlotStruct.definition.dataSources.dataSource);
            end
        end

        function binValue=getResponseSetBinValue(oldBinValue,oldPlotStruct,oldBin)
            binValue=SimBiology.internal.plotting.categorization.binvalue.ResponseSetBinValue;

            binValue.value=oldBin.label;

            if~isempty(oldBinValue)
                binValue.responseBinValues=arrayfun(@(val)SimBiology.web.internal.projectupdater.getResponseBinValue(val,oldPlotStruct),oldBinValue);
            end
        end

        function binValue=getGroupBinValue(oldBinValue,oldPlotStruct)
            binValue=SimBiology.internal.plotting.categorization.binvalue.GroupBinValue;

            if isstruct(oldBinValue)
                binValue.value=oldBinValue.value;
                binValue.dataSource=SimBiology.internal.plotting.data.DataSource(oldBinValue.dataSource);
            else
                binValue.value=oldBinValue;

                binValue.dataSource=SimBiology.internal.plotting.data.DataSource(oldPlotStruct.definition.dataSources.dataSource);
            end
        end

        function binValue=getRangeBinValue(oldBinValue,oldPlotStruct)
            binValue=SimBiology.internal.plotting.categorization.binvalue.RangeBinValue;


            if ischar(oldBinValue)&&strcmp(oldBinValue,'NotApplicable')
                binValue.isNA=true;
            end
        end

        function binValue=getCategoricalBinValue(oldBinValue,oldPlotStruct)
            binValue=SimBiology.internal.plotting.categorization.binvalue.CategoricalBinValue;
            binValue.value=oldBinValue;


            if strcmp(oldBinValue,'NotApplicable')
                binValue.isNA=true;
            end
        end

        function value=convertBooleanToOnOff(bool)
            if(bool)
                value='on';
            else
                value='off';
            end
        end

        function value=convertBooleanToScale(bool)
            if(bool)
                value='log';
            else
                value='linear';
            end
        end

        function plotDefinition=updatePercentilePlotDefinitionProperties(plotDefinition)
            fieldsToMove={'InterpolationMethod','Timepoints','RawDataPercentage'};


            for f=1:numel(fieldsToMove)
                oldPercentileValues.(fieldsToMove{f})=plotDefinition.props.PercentilesOptions.(fieldsToMove{f});
                oldMeanValues.(fieldsToMove{f})=plotDefinition.props.MeanOptions.(fieldsToMove{f});
            end


            oldPercentileValues.RawDataPercentage=str2double(oldPercentileValues.RawDataPercentage);
            oldMeanValues.RawDataPercentage=str2double(oldMeanValues.RawDataPercentage);


            plotDefinition.props.PercentileOptions=rmfield(plotDefinition.props.PercentilesOptions,fieldsToMove);
            plotDefinition.props.MeanOptions=rmfield(plotDefinition.props.MeanOptions,fieldsToMove);
            plotDefinition.props.DataOptions=[];
            plotDefinition=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition(plotDefinition);


            responseCategory=plotDefinition.props.Categories.getResponseCategory();
            responses=[responseCategory.binSettings.value];

            for p=numel(plotDefinition.plotArguments):-1:1

                dataOptions(p)=SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionPropsDataOptions();
                dataOptions(p).DataSource=plotDefinition.plotArguments(p).dataSource;





                idx=arrayfun(@(r)r.dataSource.isEqualByKey(dataOptions(p).DataSource),responses);
                displayTypes={responses(idx).displayType};


                if ismember(SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionProps.MEAN,displayTypes)
                    oldValuesStruct=oldMeanValues;
                else
                    oldValuesStruct=oldPercentileValues;
                end


                dataOptions(p).InterpolationSettings.InterpolationMethod=oldValuesStruct.InterpolationMethod;
                dataOptions(p).InterpolationSettings.Timepoints=oldValuesStruct.Timepoints;
                dataOptions(p).RawDataPercentage=oldValuesStruct.RawDataPercentage;


                if dataOptions(p).RawDataPercentage==0&&...
                    ismember(SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionProps.RAWDATA,displayTypes)
                    dataOptions(p).RawDataPercentage=100;
                end


                responses=responses(~idx);
            end


            plotDefinition.props.DataOptions=dataOptions;


            plotDefinition=plotDefinition.getStruct();
        end
    end
end



function version=findProjectVersion(sbioprojectObj,projectStruct)
    version=sbioprojectObj.getProjectVersion();
    if isempty(version)&&isstruct(projectStruct.ProjectDescription)&&isfield(projectStruct.ProjectDescription,'version')

        version=projectStruct.ProjectDescription.version;
    end
end



function projectStruct=updateExternalDataSimData(projectStruct)
    externalData=projectStruct.ExternalData.data;
    for i=1:numel(externalData)
        if strcmp(externalData(i).dataInfo.type,'SimData')

            if iscell(externalData(i).dataInfo.columnInfo)
                expressions=cellfun(@(x)x.expression,externalData(i).dataInfo.columnInfo,'UniformOutput',false);
            else
                expressions=arrayfun(@(x)x.expression,externalData(i).dataInfo.columnInfo,'UniformOutput',false);
            end

            if any(cellfun(@(x)~isempty(x),expressions))

                externalDataStruct=loadMATFile(projectStruct.ExternalData.matfile);
                simdata=externalDataStruct.(externalData(i).matfileVariableName);


                if isfield(externalDataStruct,externalData(i).matfileDerivedVariableName)
                    externalDataStruct=rmfield(externalDataStruct,externalData(i).matfileDerivedVariableName);
                end

                if isa(simdata,'SimData')
                    warningMap=containers.Map;
                    for j=1:numel(expressions)
                        if~isempty(expressions{j})
                            expression=externalData(i).dataInfo.columnInfo{j};
                            [simdata,warningStruct,obsName]=addObservableToSimDataHelper(simdata,expression);
                            warningMap(obsName)=warningStruct;
                        end
                    end


                    input=struct;
                    input.next=simdata;
                    input.name=externalData(i).name;
                    input.multiCmptModel=false;


                    dataInfo=SimBiology.web.datahandler('getExternalDataInfo',input);
                    for k=1:numel(dataInfo.columnInfo)
                        if warningMap.isKey(dataInfo.columnInfo(k).name)
                            dataInfo.columnInfo(k).errorMsgs=warningMap(dataInfo.columnInfo(k).name);
                        end
                    end


                    exclusionStore=struct;
                    exclusionStore.expressionExclusions=[];
                    exclusionStore.manualExclusions=[];

                    dataInfo.exclusionStore=exclusionStore;
                    dataInfo.exclusions=[];
                    dataInfo.group=[];


                    externalDataStruct.(externalData(i).matfileVariableName)=simdata;
                    save(projectStruct.ExternalData.matfile,'-struct','externalDataStruct');


                    projectStruct.ExternalData.data(i).dataInfo=dataInfo;
                end
            end
        end
    end
end


function projectStruct=convertStatsLastRunToSimData(program,projectStruct)


    [runInfo,idx]=getProgramLastRun(program,projectStruct);

    if~isempty(runInfo)

        datastatsStep=program.steps{cellfun(@(x)strcmp(x.type,'DataStatistics'),program.steps)};
        if~isempty(datastatsStep)

            simdata=findProgramSourceData(datastatsStep.dataName,projectStruct);
            if~isempty(simdata)&&isa(simdata,'SimData')

                observablesStep=program.steps{cellfun(@(x)strcmp(x.type,'Calculate Observables'),program.steps)};
                observables=observablesStep.statistics;
                warningMap=containers.Map;
                for i=1:numel(observables)
                    [simdata,warningStruct,obsName]=addObservableToSimDataHelper(simdata,observables(i));
                    warningMap(obsName)=warningStruct;
                end


                stats=struct;
                stats.results=simdata;
                programData=struct(runInfo.matfileVariableName,stats);
                save(runInfo.matfileName,'-struct','programData');


                input=struct;
                input.next=simdata;
                input.name='results';
                input.multiCmptModel=ismultiCompartmentModel(program);


                dataInfo=SimBiology.web.datahandler('getExternalDataInfo',input);
                for i=1:numel(dataInfo.columnInfo)
                    if warningMap.isKey(dataInfo.columnInfo(i).name)
                        dataInfo.columnInfo(i).errorMsgs=warningMap(dataInfo.columnInfo(i).name);
                    end
                end



                runInfo.dataInfo.size='';


                runInfo.dataInfo=dataInfo;


                projectStruct.ProgramData.data(idx)=runInfo;
            end
        end
    end
end


function out=findProgramSourceData(dataName,projectStruct)
    out='';



    if contains(dataName,'.')
        s=strsplit(dataName,'.');
        if numel(s)==3
            programName=s{1};
            runName=s{2};
            varName=s{3};


            programdata=projectStruct.ProgramData.data;
            for i=1:numel(programdata)

                if strcmp(programName,programdata(i).programName)&&strcmp(runName,programdata(i).name)


                    for j=1:numel(programdata(i).dataInfo)
                        if strcmp(programdata(i).dataInfo(j).name,varName)


                            dataStruct=loadMATFile(programdata(i).matfileName);
                            if isfield(dataStruct,programdata(i).matfileVariableName)
                                pd=dataStruct.(programdata(i).matfileVariableName);
                                if isfield(pd,varName)
                                    out=pd.(varName);
                                    return;
                                end
                            end
                        end
                    end
                end
            end
        end
    else

        externaldata=projectStruct.ExternalData.data;
        for i=1:numel(externaldata)
            if strcmp(externaldata(i).name,dataName)
                dataStruct=loadMATFile(projectStruct.ExternalData.matfile);

                if isfield(dataStruct,externaldata(i).matfileVariableName)
                    out=dataStruct.(externaldata(i).matfileVariableName);
                    return;
                end
            end
        end
    end
end


function projectStruct=convertStatsSavedRunToSimData(program,projectStruct)

    data=projectStruct.ProgramData.data;
    for j=1:numel(data)
        if~strcmp(data(j).name,'LastRun')&&strcmp(data(j).programName,program.programName)
            runInfo=data(j);


            if~isempty(runInfo)

                stats=loadMATFile(runInfo.matfileName);
                if isfield(stats,runInfo.matfileVariableName)
                    stats=stats.(runInfo.matfileVariableName);
                    statsTable=stats.stats;


                    columns=statsTable.Properties.VariableNames;
                    for i=1:numel(columns)
                        if iscell(statsTable.(columns{i}))
                            statsTable.(columns{i})=cell2mat(statsTable.(columns{i}));
                        end
                    end


                    simdata=SimData.constructFromTable(statsTable,'','');


                    input=struct;
                    input.next=simdata;
                    input.name='results';
                    input.multiCmptModel=ismultiCompartmentModel(program);


                    dataInfo=SimBiology.web.datahandler('getExternalDataInfo',input);
                    runInfo.dataInfo=dataInfo;


                    stats=struct;
                    stats.results=simdata;
                    programData=struct(runInfo.matfileVariableName,stats);
                    save(runInfo.matfileName,'-struct','programData');


                    projectStruct.ProgramData.data(j)=runInfo;
                end
            end
        end
    end
end


function program=updateStatisticsToObservables(program)

    stepNames=cellfun(@(x)x.name,program.steps,'UniformOutput',false);
    idx=find(strcmp(stepNames,'Calculate Statistics'),1);


    if~isempty(idx)

        step=program.steps{idx};
        step.name='Calculate Observables';
        step.type='Calculate Observables';

        step.internal.argType='calculateObservables';


        stats=step.statistics;
        if~isempty(stats)

            model=getProgramModel(program);
            observables=repmat(getObservableRowTemplate(),1,numel(stats));
            for j=1:numel(stats)
                observables(j).ID=stats(j).ID;
                observables(j).matlabError=stats(j).matlabError;
                observables(j).use=stats(j).use;
                observables(j).name=stats(j).name;
                observables(j).expression=stats(j).value;


                if~isempty(model)
                    obsObj=addObservableToModel(model,stats(j).name,stats(j).value,'');
                    if~isempty(obsObj)
                        observables(j).name=obsObj.Name;
                        observables(j).expression=obsObj.Expression;
                        observables(j).sessionID=obsObj.SessionID;
                        observables(j).UUID=obsObj.UUID;
                    end
                end
            end


            step.statistics=observables;
        end


        program.steps{idx}=step;
    end
end


function model=getProgramModel(program)
    model=[];


    stepNames=cellfun(@(x)x.name,program.steps,'UniformOutput',false);
    idx=find(strcmp(stepNames,'Model'),1);

    if~isempty(idx)
        model=SimBiology.web.modelhandler('getModelFromSessionID',program.steps{idx}.model);
    end
end


function projectStruct=addObservablesToLastRun(program,programIdx,projectStruct)
    stepNames=cellfun(@(x)x.name,program.steps,'UniformOutput',false);
    idx=find(strcmp(stepNames,'Calculate Observables'),1);


    observables={};
    if~isempty(idx)
        observables=program.steps{idx}.statistics;
    end



    [runInfo,idx]=getProgramLastRun(program,projectStruct);
    [runInfo,expressions]=addObservableToSavedSimData(program,runInfo,observables);


    if isempty(runInfo)
        return
    end

    projectStruct.ProgramData.data(idx)=runInfo;



    stepNames=cellfun(@(x)x.name,program.steps,'UniformOutput',false);
    idx=find(strcmp(stepNames,'Calculate Observables'),1);


    model=getProgramModel(program);
    if~isempty(model)
        observables=repmat(getObservableRowTemplate(),1,numel(expressions));

        for i=1:numel(expressions)
            obsObj=addObservableToModel(model,expressions(i).name,expressions(i).expression,expressions(i).units);
            observables(i).name=obsObj.Name;
            observables(i).expression=obsObj.Expression;
            observables(i).sessionID=obsObj.SessionID;
            observables(i).UUID=obsObj.UUID;
            observables(i).units=obsObj.Units;
        end


        if~isempty(idx)
            step=program.steps{idx};


            if~isempty(step.statistics)
                for i=1:numel(observables)
                    step.statistics(end+1)=observables(i);
                end
            else
                step.statistics=observables;
            end


            step.enabled=~isempty(step.statistics);

            program.steps{idx}=step;
        end
    end


    projectStruct.Programs{programIdx}=program;
end


function[runInfo,expressions]=addObservableToSavedSimData(program,runInfo,observables)
    expressions=[];

    if~isempty(runInfo)
        programData=[];

        if iscell(runInfo.dataInfo)
            statsIdx=find(strcmp(cellfun(@(x)x.name,runInfo.dataInfo,'UniformOutput',false),'stats'),1);
        else
            statsIdx=find(strcmp(arrayfun(@(x)x.name,runInfo.dataInfo,'UniformOutput',false),'stats'),1);
        end

        if~isempty(statsIdx)
            if isempty(programData)

                programData=loadMATFile(runInfo.matfileName);
            end



            if isempty(observables)
                observables=runInfo.dataInfo{statsIdx}.columnInfo;
            end

            runInfo.dataInfo(statsIdx)=[];


            if isfield(programData.data,'stats')
                programData.data=rmfield(programData.data,'stats');
            end
        end


        if iscell(runInfo.dataInfo)
            simDataIndices=find(strcmp(cellfun(@(x)x.type,runInfo.dataInfo,'UniformOutput',false),'SimData'),1);
        else
            simDataIndices=find(strcmp(arrayfun(@(x)x.type,runInfo.dataInfo,'UniformOutput',false),'SimData'),1);
        end



        if~isempty(simDataIndices)



            for i=1:numel(runInfo.dataInfo)
                if iscell(runInfo.dataInfo)
                    if strcmpi(runInfo.dataInfo{i}.type,'SimData')
                        runInfo.dataInfo{i}.isMultiRun=(runInfo.dataInfo{i}.rows>1);
                    end
                else

                    runInfo.dataInfo(i).isMultiRun=(runInfo.dataInfo(i).rows>1);
                end
            end

            for m=1:numel(simDataIndices)
                simDataIdx=simDataIndices(m);

                if iscell(runInfo.dataInfo)
                    simdataInfo=runInfo.dataInfo{simDataIdx};
                else
                    simdataInfo=runInfo.dataInfo(simDataIdx);
                end


                if any(cellfun(@(x)~isempty(x),{simdataInfo.columnInfo.expression}))||~isempty(observables)


                    if isempty(programData)

                        programData=loadMATFile(runInfo.matfileName);
                    end

                    if isfield(programData,'deriveddata')
                        programData=rmfield(programData,'deriveddata');
                    end


                    if isfield(programData.data,'results')
                        simdata=programData.data.results;


                        simdataInfo.isMultiRun=(numel(simdata)>1);

                        warningMap=containers.Map;
                        if isa(simdata,'SimData')

                            expressions={simdataInfo.columnInfo.expression};
                            expressions=simdataInfo.columnInfo(cellfun(@(x)~isempty(x),expressions));
                            for i=1:numel(expressions)
                                [simdata,warningStruct,obsName]=addObservableToSimDataHelper(simdata,expressions(i));
                                warningMap(obsName)=warningStruct;
                            end


                            for i=1:numel(observables)
                                [simdata,warningStruct,obsName]=addObservableToSimDataHelper(simdata,observables(i));
                                warningMap(obsName)=warningStruct;
                            end


                            input=struct;
                            input.next=simdata;
                            input.name='results';
                            input.multiCmptModel=ismultiCompartmentModel(program);


                            dataInfo=SimBiology.web.datahandler('getExternalDataInfo',input);
                            for i=1:numel(dataInfo.columnInfo)
                                if warningMap.isKey(dataInfo.columnInfo(i).name)
                                    dataInfo.columnInfo(i).errorMsgs=warningMap(dataInfo.columnInfo(i).name);
                                end
                            end







                            if iscell(runInfo.dataInfo)
                                origDataInfo=runInfo.dataInfo{simDataIdx};
                            else
                                origDataInfo=runInfo.dataInfo(simDataIdx);
                            end

                            if isfield(origDataInfo,'numGroups')
                                dataInfo.numGroups=origDataInfo.numGroups;
                            end


                            if iscell(runInfo.dataInfo)
                                for i=1:numel(runInfo.dataInfo)
                                    runInfo.dataInfo{i}.size=sprintf('%sx%s',runInfo.dataInfo{i}.rows,runInfo.dataInfo{i}.columns);
                                    runInfo.dataInfo{i}.unitsConverted='none';
                                end
                            else
                                for i=1:numel(runInfo.dataInfo)
                                    runInfo.dataInfo(i).size=sprintf('%sx%s',runInfo.dataInfo(i).rows,runInfo.dataInfo(i).columns);
                                    runInfo.dataInfo(i).unitsConverted='none';
                                end
                            end

                            if iscell(runInfo.dataInfo)
                                runInfo.dataInfo{simDataIdx}=dataInfo;
                            else
                                runInfo.dataInfo(simDataIdx)=dataInfo;
                            end


                            programData.data.results=simdata;


                            save(runInfo.matfileName,'-struct','programData');
                        end
                    end
                end
            end
        end
    end
end


function[simdata,warningStruct,obsName]=addObservableToSimDataHelper(simdata,observable)
    simdataNames=SimBiology.web.datahandler('getSimDataNames',simdata);

    obsName=getUniqueNameWithIndex(simdataNames,observable.name);
    try
        [simdata,warnings]=simdata.addobservable(obsName,observable.expression,'Units',observable.units,'IssueWarnings',false);




        warningStruct=SimBiology.web.datahandler('getWarningForColumnName',obsName,warnings);
        if~isempty(warningStruct.message)
            warningStruct.type='expression';
        end
    catch ex
        warningStruct=struct('message',SimBiology.web.internal.errortranslator(ex),'severity','error','type','expression');
    end
end


function out=ismultiCompartmentModel(program)
    out=false;
    model=getProgramModel(program);
    if~isempty(model)
        out=numel(model.Compartments)>1;
    end
end


function[lastRun,i]=getProgramLastRun(program,projectStruct)
    lastRun=[];

    data=projectStruct.ProgramData.data;
    for i=1:numel(data)
        if iscell(data)
            if strcmp(data{i}.name,'LastRun')&&strcmp(data{i}.programName,program.programName)
                lastRun=data{i};
                return;
            end
        else
            if strcmp(data(i).name,'LastRun')&&strcmp(data(i).programName,program.programName)
                lastRun=data(i);
                return;
            end
        end
    end
end


function obs=addObservableToModel(model,name,expression,units)
    obs=[];
    try
        obs=sbioselect(model,'Type','observable','Name',name);
        if isempty(obs)
            obs=model.addobservable(name,expression,'Units',units);
        else


            if~strcmp(obs.Expression,expression)
                name=getUniqueNameWithIndex({model.Observables.name},'obs1');
                obs=model.addobservable(name,expression);
            end
        end
    catch
    end
end






function out=loadMATFile(matFileName)
    out=[];


    if exist(matFileName,'file')

        w=warning('off','all');


        out=load(matFileName);


        warning(w);
    end
end


function out=getObservableRowTemplate()
    out=struct;
    out.ID=-1;
    out.sessionID=-1;
    out.UUID=-1;
    out.use=true;
    out.name="";
    out.equal="=";
    out.expression="";
    out.matlabError="";
    out.message=[];
    out.type="observable";
    out.units="";
    out.validunits=true;
end


function out=getUniqueNameWithIndex(names,newName)

    if~ismember(newName,names)
        out=newName;
        return;
    end

    index=1;
    out=sprintf('%s_%d',newName,index);

    while any(ismember(names,out))
        index=index+1;
        out=sprintf('%s_%d',newName,index);
    end
end