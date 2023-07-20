function out=plotHandler(action,varargin)

    switch(action)
    case 'buildPlotObject'
        out=buildPlotObject(varargin{:});
    end

end

function plots=buildPlotObject(projectConverter,node,modelSessionID,results,externalDataInfo,projectVersion)

    plots=[];


    model=getModelFromSessionID(modelSessionID);


    programName=getAttribute(node,'Name');


    plotNode=getField(node,'Plot');
    plotNode=getField(plotNode,'Plots');


    programType=getAttribute(node,'Category');


    resultName='LastRun';
    resultObj=getResultObject('LastRun',results);
    generatePlots=false;
    generatedPlotsNode=getField(node,'Plot');


    experimentalDataName='';
    groupSettings=getField(node,'GroupSettings');
    if~isempty(groupSettings)
        experimentalDataName=getField(groupSettings,'DataSetAttribute');
    end

    experimentalDataIndVarName='';
    if~isempty(experimentalDataName)

        numCols=getField(groupSettings,'ColumnNamesCountAttribute');
        for c=1:numCols
            description=getField(groupSettings,['Description',num2str(c),'Attribute']);
            if strcmp(description,'Independent')
                experimentalDataIndVarName=getField(groupSettings,['DataSetColumNames',num2str(c),'Attribute']);
                break;
            end
        end

        if isempty(experimentalDataIndVarName)

            for i=1:numel(externalDataInfo.data)
                if strcmp(externalDataInfo.data(i).name,experimentalDataName)
                    selectedData=externalDataInfo.data(i);
                    for c=1:numel(selectedData.dataInfo.columnInfo)
                        if strcmp(selectedData.dataInfo.columnInfo(c).classification,'independent')
                            experimentalDataIndVarName=selectedData.dataInfo.columnInfo(c).name;
                        end
                    end
                    break;
                end
            end
        end
    end

    if~isempty(generatedPlotsNode)
        generatePlots=getAttribute(generatedPlotsNode,'GeneratePlotsAfterRun');
        if isempty(generatePlots)
            generatePlots=false;
        end
    end

    if generatePlots&&~isempty(plotNode)&&~isempty(resultObj)

        plots=getPlotObjectForRun(projectConverter,getField(plotNode,'Settings'),programName,model,resultName,resultObj,programType,projectVersion);
    end


    livePlotNode=getField(node,'SimulationViewer');
    if~isempty(livePlotNode)
        try
            livePlots=getLivePlotObjectForRun(projectConverter,livePlotNode,programName,model,programType,experimentalDataName,experimentalDataIndVarName);
            plots=vertcat(plots,livePlots);
        catch ex
            projectConverter.addError(sprintf('Unable to create live plots for task name: %s ',programName),ex);
        end
    end


    dataNodes=getField(node,'Data');
    dataNodes=getField(dataNodes,'Data');

    for i=numel(dataNodes):-1:1
        plotNode=getField(dataNodes(i),'PlotList');

        if~isempty(plotNode)
            resultName=getAttribute(dataNodes(i),'Name');




            if~strcmp(resultName,'current')
                resultObj=getResultObject(resultName,results);

                if~isempty(resultObj)
                    p=getPlotObjectForRun(projectConverter,getPlotTypeRows(plotNode(1)),programName,model,resultName,resultObj,programType,projectVersion);
                    plots=vertcat(plots,p);%#ok<AGROW>
                end
            end
        end
    end

end

function rows=getPlotTypeRows(plotNode)

    plotNode=getField(plotNode,'Plot');
    rows={};

    for i=1:length(plotNode)
        layers=getField(plotNode(i),'Layer');
        for j=1:length(layers)
            rows{end+1}=getField(layers(j),'PlotTypeRow');%#ok<AGROW>
        end
    end

    rows=[rows{:}];

end

function plots=getLivePlotObjectForRun(obj,plotNode,programName,model,programType,experimentalDataName,experimentalDataIndVarName)

    plots=[];


    if isempty(plotNode)||strcmp(programType,'Fit Data')
        return;
    end


    if~getAttribute(plotNode,'IsLivePlotsShowing')
        return;
    end


    axisPanels=getField(plotNode,'AxisPanel');
    plots=getPlotStructTemplate;
    plots=repmat(plots,numel(axisPanels),1);
    invalidIndices=[];

    for i=1:numel(axisPanels)

        axesType=getAttribute(axisPanels(i),'AxesType');
        if~(strcmp(axesType,'line')||strcmp(axesType,'trellis'))
            invalidIndices(end+1)=i;%#ok<AGROW>
            continue;
        end

        plots(i).axes.plotStyle='time';
        plots(i).axes.properties.Style='time';
        plots(i).axes.properties.Title=getAttribute(axisPanels(i),'AxesName');
        plots(i).axes.properties.XLabel='';
        plots(i).axes.properties.YLabel='';

        if strcmp(getAttribute(axisPanels(i),'YLimMode'),'auto')
            plots(i).axes.properties.YMax=10;
            plots(i).axes.properties.YMin=0;
        else
            plots(i).axes.properties.YMax=getAttribute(axisPanels(i),'YRulerMax');
            plots(i).axes.properties.YMin=getAttribute(axisPanels(i),'YRulerMin');
        end

        if strcmp(getAttribute(axisPanels(i),'XLimMode'),'auto')
            plots(i).axes.properties.XMin=0;
            plots(i).axes.properties.XMax=10;
        else
            plots(i).axes.properties.XMin=getAttribute(axisPanels(i),'XRulerMin');
            plots(i).axes.properties.XMax=getAttribute(axisPanels(i),'XRulerMax');
        end

        plots(i).axes.properties.XScale=~getAttribute(axisPanels(i),'XLinear');
        plots(i).axes.properties.YScale=~getAttribute(axisPanels(i),'YLinear');
        plots(i).axes.properties.XGrid=getAttribute(axisPanels(i),'Grid');
        plots(i).axes.properties.YGrid=getAttribute(axisPanels(i),'Grid');


        dataFolderName='LastRun';
        variableName='results';
        dataSource=getDataSourceStructTemplate;
        dataSource.dataName=dataFolderName;
        dataSource.groupVariableName='<GROUP>';
        dataSource.independentVariableName='time';
        dataSource.programName=programName;
        dataSource.variableName=variableName;

        dataSources=[];
        xValues={};
        yValues={};
        numCols=0;


        if strcmp(axesType,'line')
            lines=getField(axisPanels(i),'Line');
            plotIdx=true(1,numel(lines));
            for j=1:numel(lines)
                plotIdx(j)=getAttribute(lines(j),'Plot');
            end

            lines=lines(plotIdx);

            if~isempty(lines)
                dataSources=repmat(dataSource,numel(lines),1);
                yValues=repmat({''},numel(lines),1);
                xValues=repmat({'time'},numel(lines),1);

                for j=1:numel(lines)
                    externalDataSetName=getAttribute(lines(j),'DataSetName');

                    if isempty(externalDataSetName)

                        yValues{j}=getAttribute(lines(j),'PartiallyQualifiedName');
                        yValues(j)=resolveStateNames(model,yValues(j));
                    else
                        xValues{j}=getAttribute(lines(j),'XColumn');
                        yValues{j}=getAttribute(lines(j),'YColumn');

                        dataSources(j).dataName=externalDataSetName;
                        dataSources(j).programName='';
                        dataSources(j).variableName='';
                        dataSources(j).independentVariableName=xValues{j};
                    end
                end
            end

        elseif~isempty(experimentalDataName)&&~isempty(experimentalDataIndVarName)
            experimentalDataSource=getDataSourceStructTemplate;
            experimentalDataSource.dataName=experimentalDataName;
            experimentalDataSource.independentVariableName=experimentalDataIndVarName;

            stateYValues={};
            dataColYValues={};
            while true
                stateName=getField(axisPanels(i),['ResponseNames',num2str(numCols),'Attribute']);
                dataColName=getField(axisPanels(i),['DataColumnNames',num2str(numCols),'Attribute']);

                if isempty(stateName)||isempty(dataColName)
                    break;
                else
                    numCols=numCols+1;
                end

                stateYValues(numCols,1)=resolveStateNames(model,{stateName});%#ok<AGROW> 
                dataColYValues{numCols,1}=dataColName;%#ok<AGROW> 
            end
            if numCols>0
                dataSources=vertcat(repmat(dataSource,numCols,1),...
                repmat(experimentalDataSource,numCols,1));
                xValues=vertcat(repmat({'time'},numCols,1),...
                repmat({experimentalDataIndVarName},numCols,1));
                yValues=vertcat(stateYValues,dataColYValues);
            end
        end

        if~isempty(dataSources)
            switch(programType)
            case 'Scan'
                plots(i)=getScanOneAxesTimePlot(plots(i),dataSources,xValues,yValues);
            case 'Group Simulation'
                plots(i)=getScanTrellisTimePlot(plots(i),dataSources,xValues,yValues);

                responseSetCategory=getFigureStyleCategoriesStructTemplate;
                responseSetCategory.groupingVariable='<RESPONSE_SET>';


                if strcmp(axesType,'line')
                    responseSetCategory.style='Vertical';
                else
                    responseSetCategory.style='Color';
                end


                responseSetData=repmat(getFigureStyleCategoriesDataStructTemplate(),1,numCols);
                colorOrder=SimBiology.internal.plotting.categorization.BinSettings.COLOR_ORDER();
                for s=1:numCols
                    responseSetData(s).label=['Set ',num2str(s)];
                    responseBins(2)=struct('x',{experimentalDataIndVarName},...
                    'y',dataColYValues(s),...
                    'dataSource',{experimentalDataSource});
                    responseBins(1)=struct('x',{'time'},...
                    'y',stateYValues(s),...
                    'dataSource',{dataSource});
                    responseSetData(s).value=responseBins;
                    responseSetData(s).color=colorOrder{s};
                end
                responseSetCategory.data=responseSetData;
                plots(i).figure.properties.StyleProperties.Categories=horzcat(responseSetCategory,...
                plots(i).figure.properties.StyleProperties.Categories);
            otherwise
                plots(i)=getSimTimePlot(plots(i),dataSources,xValues,yValues);
            end
        end
    end


    plots(invalidIndices)=[];

    if isempty(plots)
        plots=[];
    end


    for i=1:numel(plots)
        plots(i).name=sprintf('Plot%d: %s.%s',obj.getPlotIndex(),programName,'LastRun');
    end

end

function plots=getPlotObjectForRun(projectConverter,plotNodes,programName,model,resultName,resultObj,programType,projectVersion)

    plots=[];
    if isempty(plotNodes)
        return;
    end

    plots=getPlotStructTemplate;
    plots=repmat(plots,numel(plotNodes),1);
    validPlots=true(numel(plotNodes),1);

    for i=1:numel(plotNodes)
        try

            axesPropNode=getArgumentNode(plotNodes(i),'axesStyle');

            if~isempty(axesPropNode)
                axesProperties=getArrayValues(axesPropNode,'Value',projectVersion);
                plots(i).axes.properties.Style='time';

                for j=1:2:numel(axesProperties)
                    switch axesProperties{j}
                    case 'Title'
                        plots(i).axes.properties.Title=axesProperties{j+1};
                    case 'XLabel'
                        plots(i).axes.properties.XLabel=axesProperties{j+1};
                    case 'YLabel'
                        plots(i).axes.properties.YLabel=axesProperties{j+1};
                    case 'YMax'
                        plots(i).axes.properties.YMax=axesProperties{j+1};
                    case 'YMin'
                        plots(i).axes.properties.YMin=axesProperties{j+1};
                    case 'XMin'
                        plots(i).axes.properties.XMin=axesProperties{j+1};
                    case 'XMax'
                        plots(i).axes.properties.XMax=axesProperties{j+1};
                    case 'XScale'
                        plots(i).axes.properties.XScale=strcmp(axesProperties{j+1},'log');
                    case 'YScale'
                        plots(i).axes.properties.YScale=strcmp(axesProperties{j+1},'log');
                    case 'Grid'
                        plots(i).axes.properties.XGrid=strcmp(axesProperties{j+1},'on');
                        plots(i).axes.properties.YGrid=strcmp(axesProperties{j+1},'on');
                    end
                end
            end


            type=getAttribute(plotNodes(i),'Name');
            switch type
            case 'Time'
                plots(i)=getTimePlot(plots(i),plotNodes(i),model,resultName,programName,programType,projectVersion);
            case 'XY'
                plots(i)=getXYPlot(plots(i),plotNodes(i),model,resultName,programName,programType,projectVersion);
            case 'Sensitivity Matrix Subplot'

                if~strcmp(programType,'Scan with Sensitivities')
                    plots(i)=getSensitivityMatrixPlot(plots(i),plotNodes(i),model,resultName,programName,projectVersion);
                else
                    projectConverter.addWarning(sprintf('Plot Type: %s for the task: %s, was not imported because it is not supported in SimBiology Model Analyzer.',type,programName));
                    validPlots(i)=false;
                end
            case 'Sum'
                projectConverter.addWarning(sprintf('Sum Plot for the task: %s, was not imported because it is not supported in SimBiology Model Analyzer.',programName));
                validPlots(i)=false;
            case 'Group Simulation'
                projectConverter.addWarning(sprintf('Group Simulation Plot for the task: %s, was not imported because it is not supported in SimBiology Model Analyzer.',programName));
                validPlots(i)=false;
            case 'Fit'

                fitTypeNode=getArgumentNode(plotNodes(i),'fitType');
                if strcmp(projectVersion,'4.1')
                    fitType=getAttribute(fitTypeNode,'Value');
                    fitType=fitType(2:end-1);
                else
                    fitType=getAttribute(fitTypeNode,'Value0');
                end

                if strcmp(fitType,'population')
                    if numel(resultObj.dataInfo)==3
                        plots(i)=getPopulationFitPlot(plots(i),plotNodes(i),resultName,programName,projectVersion);
                    else
                        validPlots(i)=false;
                        projectConverter.addWarning(sprintf('Population Plot for task %s was not imported because only mixed effects fits support Population plots.',programName));
                    end
                else
                    plots(i)=getIndividualFitPlot(plots(i),plotNodes(i),resultName,programName,projectVersion);
                end
            case 'Observation versus Prediction'
                plots(i)=getActualVsPredictedPlot(plots(i),resultName,programName);
            case 'Box Plot'
                plots(i)=getBoxPlot(plots(i),resultName,programName);
            case 'Residuals'
                plots(i)=getResidualsPlot(plots(i),plotNodes(i),resultName,programName,projectVersion);
            case 'Residual Distribution'
                plots(i)=getResidualDistributionsPlot(plots(i),resultName,programName);
            case 'Fit Summary'
                projectConverter.addWarning(sprintf('Plot Type: %s for the task: %s, was not imported because it is not supported in SimBiology Model Analyzer. Drag and drop the fit results into a DataSheet to see the Fit Summary.',type,programName));
                validPlots(i)=false;
            otherwise
                projectConverter.addWarning(sprintf('Plot Type: %s for the task: %s, was not imported because it is not supported in SimBiology Model Analyzer.',type,programName));
                validPlots(i)=false;
            end
        catch ex
            projectConverter.addError(sprintf('Unable to load plots for program: %s',programName),ex);
            validPlots(i)=false;
        end
    end


    plots=plots(validPlots);


    for i=1:numel(plots)
        plots(i).name=sprintf('Plot%d: %s.%s',projectConverter.getPlotIndex(),programName,resultName);
    end

end

function plotObj=getTimePlot(plotObj,plotNode,model,resultName,programName,programType,projectVersion)



    argNode=getArgumentNode(plotNode,'y');


    yValues=getArrayValues(argNode,'Value',projectVersion);



    if numel(yValues)==1&&strcmp(yValues{1},'<all>')
        plotObj.definition.autoAddAllStatesToLog=true;
        yValues=getStateNames(model);
    end

    xValues=repmat({'time'},size(yValues));


    [dataSource,dataSourceArg]=getDataSourceStructFromPlotNode(plotNode,resultName,programName,projectVersion);
    if strcmpi(dataSourceArg,'Simulation Results')||strcmpi(dataSourceArg,'SimData Population')||strcmpi(dataSourceArg,'SimData Individual')

        yValues=resolveStateNames(model,yValues);
        variableName='results';
    else
        variableName='';
    end

    switch programType
    case{'Scan','Fit Data','Parameter Fit'}
        if strcmpi(programType,'Scan')
            variableName='results';
        else

            variableNameNode=getArgumentNode(plotNode,'tobj');


            if isempty(variableNameNode)
                variableName='simdataI';
            else

                if strcmp(projectVersion,'4.1')
                    variableName=getAttribute(variableNameNode,'Value');
                    variableName=variableName(2:end-1);
                else
                    variableName=getAttribute(variableNameNode,'Value0');
                end

                if strcmp(variableName,'SimData Individual')
                    variableName='simdataI';
                else
                    variableName='simdataP';
                end
            end
        end

        dataSource.variableName=variableName;
        dataSources=repmat(dataSource,size(yValues));


        plotStyleNode=getArgumentNode(plotNode,'plotStyle');


        if isempty(plotStyleNode)
            plotStyle='one axes';
        else

            if strcmp(projectVersion,'4.1')
                plotStyle=getAttribute(plotStyleNode,'Value');
                plotStyle=plotStyle(2:end-1);
            else
                plotStyle=getAttribute(plotStyleNode,'Value0');
            end
        end



        switch plotStyle
        case{'trellis';'subplot'}

            plotObj=getScanTrellisTimePlot(plotObj,dataSources,xValues,yValues);
        case 'one axes'

            plotObj=getScanOneAxesTimePlot(plotObj,dataSources,xValues,yValues);
        end
    otherwise
        dataSource.variableName=variableName;
        dataSources=repmat(dataSource,size(yValues));
        plotObj=getSimTimePlot(plotObj,dataSources,xValues,yValues);
    end

end

function plotObj=getSimTimePlot(plotObj,dataSources,xValues,yValues)


    plotObj.axes=buildTimeAxesObj(plotObj.axes,dataSources,xValues,yValues,'');


    plotObj.definition.dataSources=plotObj.axes.plotArguments;


    figureCategories=getFigureStyleCategoriesStructTemplate();
    figureCategories.groupingVariable='<RESPONSE>';
    figureCategories.numBins=numel(yValues);
    figureCategories.style='Color';


    data=getFigureStyleCategoriesDataStructTemplate();
    data=repmat(data,1,figureCategories.numBins);

    for i=1:numel(data)
        data(i).ID=i-1;
        data(i).color=getColor(i);
        data(i).label=yValues{i};
        data(i).value=struct('dataSource',dataSources(i),'x',xValues{i},'y',yValues{i});
        data(i).linestyle=getLineStyle(i);
        data(i).marker=getMarker(i);
        data(i).markersize=getMarkerSize(i);
        data(i).info=[struct('FieldName','<DATASOURCE>','Value',dataSources(i)),...
        struct('FieldName','<RESPONSE>','Value',yValues{i}),...
        struct('FieldName','<UNITS>','Value',[]),...
        struct('FieldName','<INDEPENDENTVARIABLE>','Value',xValues{i}),...
        struct('FieldName','<INDEPENDENTVARIABLEUNITS>','Value',[])];
    end


    figureCategories.data=data;


    plotObj.figure.properties.StyleProperties.Categories=figureCategories;


    plotObj.figure.properties.LinkedX=true;

end

function plotObj=getScanTrellisTimePlot(plotObj,dataSources,xValues,yValues)


    plotObj.axes=buildTimeAxesObj(plotObj.axes,dataSources,xValues,yValues,'');


    plotObj.definition.dataSources=plotObj.axes.plotArguments;


    figureCategories=repmat(getFigureStyleCategoriesStructTemplate,1,2);

    figureCategories(1)=getFigureStyleCategoriesStructTemplate;
    figureCategories(1).groupingVariable='<RESPONSE>';
    figureCategories(1).numBins=numel(yValues);
    figureCategories(1).style='Line Style';


    data=getFigureStyleCategoriesDataStructTemplate;
    data=repmat(data,[1,figureCategories(1).numBins]);

    for i=1:numel(data)
        data(i).ID=i-1;
        data(i).color=getColor(i);
        data(i).label=yValues{i};
        data(i).value=struct('dataSource',dataSources(i),'x',xValues{i},'y',yValues{i});
        data(i).linestyle=getLineStyle(i);
        data(i).linewidth=getLineWidth(i);
        data(i).marker=getMarker(i);
        data(i).markersize=getMarkerSize(i);
        data(i).info=[struct('FieldName','<DATASOURCE>','Value',dataSources(i)),...
        struct('FieldName','<RESPONSE>','Value',yValues{i}),...
        struct('FieldName','<UNITS>','Value',[]),...
        struct('FieldName','<INDEPENDENTVARIABLE>','Value',xValues{i}),...
        struct('FieldName','<INDEPENDENTVARIABLEUNITS>','Value',[])];
    end


    figureCategories(1).data=data;


    figureCategories(2).groupingVariable='<GROUP>';
    figureCategories(2).numBins=1;
    figureCategories(2).style='Grid';



    data=getFigureStyleCategoriesDataStructTemplate();
    data.color=getColor(1);
    data.label=sprintf('%d',1);
    data.value=struct('dataSource',dataSources(1),'value',sprintf('%d',1));
    data.linestyle=getLineStyle(1);
    data.linewidth=getLineWidth(1);
    data.marker=getMarker(1);
    data.markersize=getMarkerSize(1);
    data.info=[struct('FieldName','<DATASOURCE>','Value',dataSources(1)),...
    struct('FieldName','<GROUP>','Value',data.label)];


    figureCategories(2).data=data;


    plotObj.figure.properties.StyleProperties.Categories=figureCategories;


    plotObj.figure.properties.LinkedX=true;


    plotObj.figure.properties.YLabel=plotObj.axes.properties.YLabel;
    plotObj.figure.properties.XLabel=plotObj.axes.properties.XLabel;
    plotObj.figure.properties.Title=plotObj.axes.properties.Title;

end

function plotObj=getScanOneAxesTimePlot(plotObj,dataSources,xValues,yValues)

    numYValues=numel(yValues);


    plotObj.axes=buildTimeAxesObj(plotObj.axes,dataSources,xValues,yValues,'');


    plotObj.definition.dataSources=plotObj.axes.plotArguments;


    figureCategories=repmat(getFigureStyleCategoriesStructTemplate,1,2);


    figureCategories(1)=getFigureStyleCategoriesStructTemplate;
    figureCategories(1).groupingVariable='<RESPONSE>';
    figureCategories(1).numBins=numYValues;
    figureCategories(1).style='Line Style';


    data=getFigureStyleCategoriesDataStructTemplate();
    data=repmat(data,[1,figureCategories(1).numBins]);

    for i=1:numel(data)
        data(i).ID=i-1;
        data(i).color=getColor(i);
        data(i).label=yValues{i};
        data(i).value=struct('dataSource',dataSources(i),'x',xValues{i},'y',yValues{i});
        data(i).linestyle=getLineStyle(i);
        data(i).linewidth=getLineWidth(i);
        data(i).marker='none';
        data(i).markersize=getMarkerSize(i);
        data(i).info=[struct('FieldName','<DATASOURCE>','Value',dataSources(1)),...
        struct('FieldName','<RESPONSE>','Value',yValues{i}),...
        struct('FieldName','<UNITS>','Value',[])...
        ,struct('FieldName','<INDEPENDENTVARIABLE>','Value',xValues{i}),...
        struct('FieldName','<INDEPENDENTVARIABLEUNITS>','Value',[])];
    end


    figureCategories(1).data=data;


    figureCategories(2).groupingVariable='<GROUP>';
    figureCategories(2).numBins=1;
    figureCategories(2).style='Color';


    data=getFigureStyleCategoriesDataStructTemplate();
    data.color=getColor(1);
    data.label=sprintf('%d',1);
    data.value=struct('dataSource',dataSources(1),'value',sprintf('%d',1));
    data.linestyle=getLineStyle(1);
    data.linewidth=getLineWidth(1);
    data.marker='none';
    data.markersize=getMarkerSize(1);
    data.info=[struct('FieldName','<DATASOURCE>','Value',dataSources(1)),...
    struct('FieldName','<GROUP>','Value',data.label)];


    figureCategories(2).data=data;


    plotObj.figure.properties.StyleProperties.Categories=figureCategories;

end

function axes=buildTimeAxesObj(axes,dataSources,xValues,yValues,groupName)


    axes.plotStyle='time';
    axes.properties.Style='time';


    axes.plotArguments=getPlotArgumentsStruct(dataSources,xValues,yValues);


    lines=getLineStructTemplate;
    lines=repmat(lines,numel(yValues),1);


    for i=1:numel(lines)

        lines(i).group=groupName;


        lines(i).x=xValues{i};
        lines(i).y=yValues{i};


        lines(i).dataSource=dataSources(i);

        lines(i).properties.Color=getColor(i);
        lines(i).properties.DisplayName=sprintf('%s: %s',createDataSourceName(dataSources(i)),yValues{i});
    end


    axes.allLines=lines;

end

function plotArguments=getPlotArgumentsStruct(dataSources,xValues,yValues)


    dataSourceLabels=arrayfun(@(x)createDataSourceName(x),dataSources,'UniformOutput',false);
    [uniqueDataSourceLabels,idx]=unique(dataSourceLabels,'stable');
    uniqueDataSources=dataSources(idx);
    plotArgumentsTemplate=struct('dataSource',{[]},'x',{{}},'y',{{}});
    plotArguments=repmat(plotArgumentsTemplate,numel(uniqueDataSources),1);

    for i=1:numel(plotArguments)
        plotArguments(i).dataSource=uniqueDataSources(i);
    end


    numYValues=numel(yValues);
    for j=1:numYValues
        for i=1:numel(plotArguments)
            if strcmp(uniqueDataSourceLabels{i},dataSourceLabels{j})
                plotArguments(i).x=[plotArguments(i).x,xValues(j)];
                plotArguments(i).y=[plotArguments(i).y,yValues(j)];
                break;
            end
        end
    end

end

function plotObj=getXYPlot(plotObj,plotNode,model,resultName,programName,programType,projectVersion)

    switch programType
    case{'Scan','Fit Data','Parameter Fit'}
        useGroupCategory=true;
        if strcmpi(programType,'Scan')
            variableName='results';
        else

            variableNameNode=getArgumentNode(plotNode,'tobj');


            if isempty(variableNameNode)
                variableName='simdataI';
            else

                if strcmp(projectVersion,'4.1')
                    variableName=getAttribute(variableNameNode,'Value');
                    variableName=variableName(2:end-1);
                else
                    variableName=getAttribute(variableNameNode,'Value0');
                end

                if strcmp(variableName,'SimData Individual')
                    variableName='simdataI';
                else
                    variableName='simdataP';
                end
            end
        end
    otherwise
        variableName='results';
        useGroupCategory=false;
    end


    plotObj=getCategorizedXYPlot(plotObj,plotNode,model,resultName,programName,projectVersion,variableName,useGroupCategory);

end

function plotObj=getCategorizedXYPlot(plotObj,plotNode,model,resultName,programName,projectVersion,variableName,useGroupCategory)


    plotObj.axes=buildXYAxesObj(plotObj.axes,plotNode,model,resultName,programName,projectVersion,variableName);


    plotObj.definition.dataSources=plotObj.axes.plotArguments;
    plotStyleNode=getArgumentNode(plotNode,'plotStyle');


    if strcmp(projectVersion,'4.1')
        plotStyle=getAttribute(plotStyleNode,'Value');
        plotStyle=plotStyle(2:end-1);
    else
        plotStyle=getAttribute(plotStyleNode,'Value0');
    end


    data=getFigureStyleCategoriesDataStructTemplate;
    data(1).color=getColor(1);
    data(1).label='1';
    data(1).linestyle=getLineStyle(1);
    data(1).linewidth=getLineWidth(1);
    data(1).marker='none';
    data(1).markersize=getMarkerSize(1);
    data(1).value={struct('dataSource',plotObj.axes.plotArguments.dataSource,...
    'x',plotObj.axes.plotArguments.x{1},...
    'y',plotObj.axes.plotArguments.y{1})};
    data(1).info={struct('FieldName',{'<DATASOURCE>',...
    '<RESPONSE>',...
    '<UNITS>',...
    '<INDEPENDENTVARIABLE>',...
    '<INDEPENDENTVARIABLEUNITS>'},...
    'Value',{plotObj.axes.plotArguments.dataSource,...
    plotObj.axes.plotArguments.y{1},...
    '',...
    plotObj.axes.plotArguments.x{1},...
    ''})};


    figureCategories=getFigureStyleCategoriesStructTemplate;
    figureCategories.groupingVariable='<RESPONSE>';
    figureCategories.numBins=1;
    figureCategories.data=data;
    figureCategories.style='Line Style';

    if(useGroupCategory)
        data=getFigureStyleCategoriesDataStructTemplate;
        data(1).color=getColor(1);
        data(1).label=sprintf('%d',1);
        data(1).value=struct('dataSource',plotObj.definition.dataSources.dataSource,'value',sprintf('%d',1));
        data(1).linestyle=getLineStyle(1);
        data(1).linewidth=getLineWidth(1);
        data(1).marker='none';
        data(1).markersize=getMarkerSize(1);
        data(1).info=[struct('FieldName','<DATASOURCE>','Value',plotObj.definition.dataSources.dataSource),...
        struct('FieldName','<GROUP>','Value',data.label)];


        figureCategories(2)=getFigureStyleCategoriesStructTemplate;
        figureCategories(2).groupingVariable='<GROUP>';
        figureCategories(2).numBins=1;
        figureCategories(2).data=data;

        if strcmp(plotStyle,'trellis')
            figureCategories(2).style='Grid';
        else
            figureCategories(2).style='Color';
        end
    end


    plotObj.figure.properties.StyleProperties.Categories=figureCategories;

end

function[dataSource,dataSourceArg]=getDataSourceStructFromPlotNode(plotNode,resultName,programName,projectVersion)


    dataSourceNode=getArgumentNode(plotNode,'tobj');
    dataSourceArg=getArrayValues(dataSourceNode,'Value',projectVersion);
    dataSourceArg=dataSourceArg{1};
    dataSource=getDataSourceStructTemplate;

    if strcmpi(dataSourceArg,'Simulation Results')||strcmpi(dataSourceArg,'SimData Population')||strcmpi(dataSourceArg,'SimData Individual')
        dataSource=getDataSourceStructTemplate;
        dataSource.dataName=resultName;
        dataSource.groupVariableName='<GROUP>';
        dataSource.independentVariableName='time';
        dataSource.programName=programName;
        dataSource.variableName='results';
    else
        dataSource.dataName=dataSourceArg;
        dataSource.groupVariableName='<GROUP>';
        dataSource.independentVariableName='time';
        dataSource.programName='';
        dataSource.variableName='';
    end

end

function dataSourceName=createDataSourceName(sourceInfo)
    if isempty(sourceInfo.programName)
        dataSourceName=sourceInfo.dataName;
    else
        dataSourceName=[sourceInfo.programName,':',sourceInfo.dataName,':',sourceInfo.variableName];
    end

end

function axes=buildXYAxesObj(axes,plotNode,model,resultName,programName,projectVersion,variableName)



    [dataSource,dataSourceArg]=getDataSourceStructFromPlotNode(plotNode,resultName,programName,projectVersion);


    axes.plotArguments.dataSource=dataSource;


    axes.plotStyle='xy';
    axes.properties.Style='xy';


    xNode=getArgumentNode(plotNode,'x');


    yNode=getArgumentNode(plotNode,'y');


    xValues=getArrayValues(xNode,'Value',projectVersion);
    yValues=getArrayValues(yNode,'Value',projectVersion);

    if~isempty(xValues)&&~isempty(yValues)
        if strcmp(xValues{1},'<all>')
            xValues=getStateNames(model);
            xValues=xValues{1};
        end

        if strcmp(yValues{1},'<all>')
            yValues=getStateNames(model);
            yValues=yValues{end};
        end

        if strcmpi(dataSourceArg,'Simulation Results')||strcmpi(dataSourceArg,'SimData Population')||strcmpi(dataSourceArg,'SimData Individual')

            xValues=resolveStateNames(model,xValues);
            yValues=resolveStateNames(model,yValues);
            axes.plotArguments.dataSource.variableName=variableName;
        end




        xValues=xValues{1};
        yValues=yValues{1};


        axes.plotArguments.x={xValues};
        axes.plotArguments.y={yValues};

        lines=getLineStructTemplate;


        lines.group='1';


        lines.dataSource=dataSource;

        lines.x=xValues;
        lines.y=yValues;

        lines.properties.Color=getColor(1);
        lines.properties.DisplayName=sprintf('%s vs %s',xValues,yValues);


        axes.allLines=lines;
    end

end

function plotObj=getSensitivityMatrixPlot(plotObj,plotNode,model,resultName,programName,projectVersion)



    plotObj.axes.plotStyle='sensitivity';
    plotObj.axes.properties.Style='sensitivity';
    plotObj.axes.properties.Title='Sensitivity - Time Integral';


    plotObj.axes.allLines={};



    dataSource=getDataSourceStructTemplate();
    dataSource.dataName=resultName;
    dataSource.groupVariableName='';
    dataSource.independentVariableName='';
    dataSource.programName=programName;
    dataSource.variableName='results';


    plotObj.axes.plotArguments.dataSource=dataSource;


    inputNode=getArgumentNode(plotNode,'input');
    outputNode=getArgumentNode(plotNode,'output');
    inputs=getArrayValues(inputNode,'Value',projectVersion);
    outputs=getArrayValues(outputNode,'Value',projectVersion);

    axesStyleProps=struct('inputs','','outputs','');
    if~isempty(inputs)
        if strcmp(inputs{1},'<all>')
            axesStyleProps.inputs=[];
        else
            inputs=resolveStateNames(model,inputs);
            axesStyleProps.inputs=inputs;
        end
    end

    if~isempty(outputs)
        if strcmp(outputs{1},'<all>')
            axesStyleProps.outputs=[];
        else
            outputs=resolveStateNames(model,outputs);
            axesStyleProps.outputs=outputs;
        end
    end


    plotObj.axes.properties.StyleProperties=axesStyleProps;

end

function plotObj=getIndividualFitPlot(plotObj,plotNode,resultName,programName,projectVersion)

    plotLayoutNode=getArgumentNode(plotNode,'plotStyle');

    if isempty(plotLayoutNode)
        plotLayout='trellis';
    else

        if strcmp(projectVersion,'4.1')
            plotLayout=getAttribute(plotLayoutNode,'Value');
            plotLayout=plotLayout(2:end-1);
        else
            plotLayout=getAttribute(plotLayoutNode,'Value0');
        end
    end


    styleProperties=struct;
    styleProperties.FitType='individual';
    styleProperties.Layout=plotLayout;
    styleProperties.ParameterType='individual';


    plotObj.figure.properties.StyleProperties=styleProperties;


    plotObj.figure.properties.XLabel='time';
    plotObj.figure.properties.Title='Individual Simulation Fit';
    plotObj.figure.properties.LinkedY=true;


    if~isempty(plotObj.axes.properties.Title)
        plotObj.figure.properties.Title=plotObj.axes.properties.Title;
    else
        plotObj.figure.properties.Title=[];
    end

    if~isempty(plotObj.axes.properties.XLabel)
        plotObj.figure.properties.XLabel=plotObj.axes.properties.XLabel;
    else
        plotObj.figure.properties.XLabel=[];
    end

    if~isempty(plotObj.axes.properties.YLabel)
        plotObj.figure.properties.YLabel=plotObj.axes.properties.YLabel;
    else
        plotObj.figure.properties.YLabel=[];
    end


    plotObj.definition.dataType='SimBiology.fit.OptimResults';


    plotObj.axes.properties.Style='fit';
    plotObj.axes.plotStyle='fit';



    dataSource=getDataSourceStructTemplate;
    dataSource.dataName=resultName;
    dataSource.groupVariableName='';
    dataSource.independentVariableName='';
    dataSource.programName=programName;
    dataSource.variableName='results';


    plotObj.definition.dataSources.dataSource=dataSource;

end

function plotObj=getPopulationFitPlot(plotObj,plotNode,resultName,programName,projectVersion)

    plotLayoutNode=getArgumentNode(plotNode,'plotStyle');

    if isempty(plotLayoutNode)
        plotLayout='trellis';
    else

        if strcmp(projectVersion,'4.1')
            plotLayout=getAttribute(plotLayoutNode,'Value');
            plotLayout=plotLayout(2:end-1);
        else
            plotLayout=getAttribute(plotLayoutNode,'Value0');
        end
    end


    styleProperties=struct;
    styleProperties.FitType='population';
    styleProperties.Layout=plotLayout;
    styleProperties.ParameterType='individual';


    plotObj.figure.properties.StyleProperties=styleProperties;


    plotObj.figure.properties.XLabel='time';
    plotObj.figure.properties.Title='Population Simulation Fit';
    plotObj.figure.properties.LinkedY=true;


    if~isempty(plotObj.axes.properties.Title)
        plotObj.figure.properties.Title=plotObj.axes.properties.Title;
    else
        plotObj.figure.properties.Title=[];
    end

    if~isempty(plotObj.axes.properties.XLabel)
        plotObj.figure.properties.XLabel=plotObj.axes.properties.XLabel;
    else
        plotObj.figure.properties.XLabel=[];
    end

    if~isempty(plotObj.axes.properties.YLabel)
        plotObj.figure.properties.YLabel=plotObj.axes.properties.YLabel;
    else
        plotObj.figure.properties.YLabel=[];
    end


    plotObj.definition.dataType='SimBiology.fit.NLMEResults';


    plotObj.axes.properties.Style='fit';
    plotObj.axes.plotStyle='fit';



    dataSource=getDataSourceStructTemplate;
    dataSource.dataName=resultName;
    dataSource.groupVariableName='';
    dataSource.independentVariableName='';
    dataSource.programName=programName;
    dataSource.variableName='results';


    plotObj.definition.dataSources.dataSource=dataSource;

end

function plotObj=getActualVsPredictedPlot(plotObj,resultName,programName)


    plotObj.figure.properties.Title=[];
    plotObj.figure.properties.XLabel='Predicted Value';
    plotObj.figure.properties.YLabel='Observed Value';
    plotObj.figure.properties.LinkedY=true;


    plotObj.definition.dataType='SimBiology.fit.OptimResults';


    plotObj.axes.properties.Style='actual_vs_predicted';
    plotObj.axes.plotStyle='actual_vs_predicted';



    dataSource=getDataSourceStructTemplate;
    dataSource.dataName=resultName;
    dataSource.groupVariableName='';
    dataSource.independentVariableName='';
    dataSource.programName=programName;
    dataSource.variableName='results';


    plotObj.definition.dataSources.dataSource=dataSource;

end

function plotObj=getBoxPlot(plotObj,resultName,programName)


    plotObj.figure.properties.Title=[];
    plotObj.figure.properties.XLabel=[];
    plotObj.figure.properties.YLabel=[];
    plotObj.figure.properties.LinkedY=true;


    plotObj.definition.dataType='SimBiology.fit.OptimResults';


    plotObj.axes.properties.Style='box';
    plotObj.axes.plotStyle='box';



    dataSource=getDataSourceStructTemplate;
    dataSource.dataName=resultName;
    dataSource.groupVariableName='';
    dataSource.independentVariableName='';
    dataSource.programName=programName;
    dataSource.variableName='results';


    plotObj.definition.dataSources.dataSource=dataSource;

end

function plotObj=getResidualsPlot(plotObj,plotNode,resultName,programName,projectVersion)


    plotObj.figure.properties.Title=[];


    xAxisNode=getArgumentNode(plotNode,'xaxis');


    if strcmp(projectVersion,'4.1')
        xAxisValue=getAttribute(xAxisNode,'Value');
        xAxisValue=xAxisValue(2:end-1);
    else
        xAxisValue=getAttribute(xAxisNode,'Value0');
    end


    plotObj.figure.properties.StyleProperties=struct('XAxis',xAxisValue);


    plotObj.figure.properties.LinkedY=true;


    plotObj.definition.dataType='SimBiology.fit.OptimResults';


    plotObj.axes.properties.Style='residuals';
    plotObj.axes.plotStyle='residuals';



    dataSource=getDataSourceStructTemplate;
    dataSource.dataName=resultName;
    dataSource.groupVariableName='';
    dataSource.independentVariableName='';
    dataSource.programName=programName;
    dataSource.variableName='results';


    plotObj.definition.dataSources.dataSource=dataSource;

end

function plotObj=getResidualDistributionsPlot(plotObj,resultName,programName)


    plotObj.figure.properties.Title=[];


    plotObj.definition.dataType='SimBiology.fit.OptimResults';


    plotObj.axes.properties.Style='residual_distribution';
    plotObj.axes.plotStyle='residual_distribution';



    dataSource=getDataSourceStructTemplate;
    dataSource.dataName=resultName;
    dataSource.groupVariableName='';
    dataSource.independentVariableName='';
    dataSource.programName=programName;
    dataSource.variableName='results';


    plotObj.definition.dataSources.dataSource=dataSource;

end

function out=getResultObject(name,results)

    out=[];

    for i=1:numel(results)
        if~isempty(results{i})
            if strcmp(results{i}.name,name)
                out=results{i};
                return;
            end
        end
    end

end

function out=getColor(idx)

    colors={'#0072BD','#D95319','#EDB120','#7E2F8E','#77AC30','#4DBEEE','#A2142F'};

    while idx>numel(colors)
        idx=idx-numel(colors);
    end

    out=colors{idx};

end

function out=getMarker(idx)

    markers={'o','+','*','.','x','square','diamond','^','v','>','<','pentagram','hexagram'};

    while idx>numel(markers)
        idx=idx-numel(markers);
    end

    out=markers{idx};

end

function out=getLineStyle(idx)

    lineStyles={'-','--',':','-.'};

    while idx>numel(lineStyles)
        idx=idx-numel(lineStyles);
    end

    out=lineStyles{idx};

end

function out=getLineWidth(idx)

    lineStyles={'-','--',':','-.'};
    delta=0.5;
    idx=floor((idx-1)/numel(lineStyles));
    out=num2str(0.5+delta*idx);

end

function out=getMarkerSize(idx)


    out=4+(2*(idx-1));

end

function out=getPartiallyQualifiedName(state)

    out='';
    if~isempty(state)
        out=state.PartiallyQualifiedName;
    end

end

function stateNames=getStateNames(model)


    stateNames={''};

    if isempty(model)
        return;
    end

    cs=getconfigset(model,'default');
    s=cs.RunTimeOptions.StatesToLog;
    stateNames=get(s,'PartiallyQualifiedNameReally');

end

function out=resolveStateNames(model,stateNames)


    if~iscell(stateNames)
        stateNames={stateNames};
    end

    out=stateNames;
    if isempty(model)
        return;
    end

    try


        obj=SimBiology.internal.getObjectFromPQN(model,stateNames);
        out=cellfun(@getPartiallyQualifiedName,obj,'UniformOutput',false);
    catch
    end

end

function out=getArgumentNode(plotNode,name)


    out='';

    argNodes=getField(plotNode,'Argument');

    for i=1:numel(argNodes)
        nameValue=getAttribute(argNodes(i),'Name');
        if strcmp(nameValue,name)
            out=argNodes(i);
            return;
        end
    end

end

function out=getPlotStructTemplate

    out=struct('axes',getPlotAxesStructTemplate,'definition',getDefinitionStructTemplate(),'figure',getFigureStructTemplate(),'name','Plot1');

end

function out=getDefinitionStructTemplate

    out=struct('dataType','','isDataMissing',false,'matchGroupsAcrossDataSources',true,'autoAddAllStatesToLog',false,'dataSources',[]);

end

function out=getDataSourceStructTemplate

    out=struct('dataName','','groupVariableName','','independentVariableName','','programName','','variableName','');

end

function out=getLineStructTemplate
    propertiesStruct=struct('Active',true,'Color','','DisplayName','','LineStyle','-','LineWidth',0.5000,'Marker','none','MarkerEdgeColor','auto',...
    'MarkerFaceColor','none','MarkerInterval',1,'MarkerSize',6,'Selected',false,'Visible',true,'handle',-1);

    dataSourceStruct=struct('dataName','','groupVariableName','','independentVariableName','','programName','','variableName','');

    out=struct('categories','','dataSource',dataSourceStruct,'group','','properties',propertiesStruct,'x','','y','');
    out.categories={};

end

function out=getPlotAxesStructTemplate

    labelsStruct=struct('HorizontalBinLabel','','ShowHorizontal',false,'ShowVertical',false,'VerticalBinLabel','');
    unitsStruct=struct('XUnits',[],'YUnits',[]);

    plotProperties=struct('GridColor','#262626','GridLineStyle','-','Labels',labelsStruct,'Name','Axes1','Selected',false,'Style','',...
    'StyleProperties',struct,'Title','','XGrid',false,'XLabel','','XMax',10,...
    'XMin',0,'XScale',0,'YGrid',false,'YLabel','','YMax',1,'YMin',0,'YScale',0,'Units',unitsStruct);

    out=struct('allLines','','plotArguments',[],'plotStyle','','properties',plotProperties);
    out.allLines={};

end

function out=getFigureStyleCategoriesStructTemplate

    out=struct('data','','groupingType','categorical','groupingVariable','','isCustom',false,'isGroup',false,'numBins',0,...
    'numColumns',0,'style','Grid','use',true);

end

function out=getFigureStyleCategoriesDataStructTemplate

    out=struct('color','','label','','linestyle','','linewidth','','marker','','markersize','4','transparency',1,'message','','undefined',false,'value','','info',[],...
    'show',true,'ID',0);

end

function out=getFigureStructTemplate

    propertiesStruct=struct('AxGrid',-1,'AxGridFull',[],'Column',1,'ColumnFull',1,'Gap',[4;4],'Insets',[10;10;10;10],'LinkedX',true,'LinkedY',false,...
    'Row',1,'RowFull',1,'ShowAxesDescription',true,'StyleProperties',struct,'Title','','XLabel','','YLabel','');


    propertiesStruct.StyleProperties.Categories=[];

    out=struct('properties',propertiesStruct);

end

function out=getArrayValues(argNode,valueProp,projectVersion)

    out=SimBiology.web.internal.converter.utilhandler('getArrayValues',argNode,valueProp,projectVersion);

end

function out=getAttribute(node,attribute,varargin)

    out=SimBiology.web.internal.converter.utilhandler('getAttribute',node,attribute,varargin{:});

end

function out=getField(node,field)

    out=SimBiology.web.internal.converter.utilhandler('getField',node,field);

end

function model=getModelFromSessionID(sessionID)

    model=SimBiology.web.modelhandler('getModelFromSessionID',sessionID);
end
