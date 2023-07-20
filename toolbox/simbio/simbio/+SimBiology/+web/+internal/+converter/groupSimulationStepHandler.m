function out=groupSimulationStepHandler(action,varargin)

    switch(action)
    case 'getGroupSimulationDataStep'
        out=getGroupSimulationDataStep(varargin{:});
    case 'getGroupSimulationStep'
        out=getGroupSimulationStep(varargin{:});
    end

end

function step=getGroupSimulationStep(node)

    step=getGroupSimulationStructTemplate;
    step.runInParallel=getAttribute(node.GroupSettings,'Distributed');

end

function dataStep=getGroupSimulationDataStep(node,externalDataInfo,projectVersion)


    externalDataNames={};
    if~isempty(externalDataInfo.data)
        externalDataNames={externalDataInfo.data.name};
    end


    dataStep=struct;
    dataName=getAttribute(node.GroupSettings,'DataSet');


    dataStep.dataMATFile=externalDataInfo.matfile;
    dataStep.dataMATFileVariableName=dataName;
    dataStep.dataName=dataName;
    dataStep.enabled=true;
    dataStep.name='DataFit';
    dataStep.type='DataFit';
    dataStep.version=1;
    dataStep.dataUnits={};



    if~any(ismember(externalDataNames,dataName))
        dataStep.dataMATFileVariableName='';
        dataStep.dataName='';
    end


    selectedData=[];
    for i=1:numel(externalDataInfo.data)
        if strcmp(externalDataInfo.data(i).name,dataStep.dataName)
            selectedData=externalDataInfo.data(i);
            dataStep.dataUnits={externalDataInfo.data(i).dataInfo.columnInfo.units};
            break;
        end
    end


    dataStep.internal=getInternalStructTemplate();
    dataStep.internal.argtype='data';
    dataStep.internal.id=1;
    dataStep.internal.isSetup=true;


    switch(projectVersion)
    case{'5','5.1'}
        dataStep.fitDefinitions=getDataMapInfoOldProjects(node,selectedData);
    otherwise
        dataStep.fitDefinitions=getDataMapInfo(node,projectVersion);
    end

end

function dataMapInfo=getDataMapInfo(node,projectVersion)


    groupSettings=node.GroupSettings;
    classifications=getArrayValues(groupSettings,'Description',projectVersion);
    componentNames=getArrayValues(groupSettings,'ColumnNames',projectVersion);
    columnNames=getArrayValues(groupSettings,'DataSetColumNames',projectVersion);
    groupColumn=startsWith(classifications,'Group');
    indepColumn=startsWith(classifications,'Independent');
    depColumns=startsWith(classifications,'Dependent');
    doseColumns=startsWith(classifications,'Dose');


    totalRows=2+sum(depColumns)+sum(doseColumns);
    dataMapInfo=getFitDefinitionStructTemplate;
    dataMapInfo=repmat(dataMapInfo,totalRows,1);


    dataMapInfo(1).classification='group';
    dataMapInfo(1).property=columnNames(groupColumn);
    dataMapInfo(1).columnSpan=[1,1,1,3];


    dataMapInfo(2).classification='independent';
    dataMapInfo(2).property=columnNames(indepColumn);
    dataMapInfo(2).columnSpan=[1,1,1,3];


    responseColumnNames=columnNames(depColumns);
    responseComponentNames=componentNames(depColumns);
    for i=1:numel(responseColumnNames)
        index=2+i;
        dataMapInfo(index).classification='response';
        dataMapInfo(index).property=responseColumnNames{i};
        dataMapInfo(index).value=responseComponentNames{i};
        dataMapInfo(index).valueType='speciesParameter';


        children=getFitDefinitionStructTemplate;
        children=repmat(children,2,1);
        properties={'Column','Component'};
        valueType={'rawdata','speciesParameter'};

        for j=1:numel(children)
            children(j).isChild=true;
            children(j).property=properties{j};
            children(j).valueType=valueType{j};
        end


        children(1).value=dataMapInfo(index).property;
        children(2).value=dataMapInfo(index).value;


        dataMapInfo(index).children=children;
    end


    doseColumnNames=columnNames(doseColumns);
    doseComponentNames=componentNames(doseColumns);
    doseClassifications=classifications(doseColumns);
    for i=1:numel(doseColumnNames)
        index=numel(responseColumnNames)+2+i;
        dataMapInfo(index).classification='dose from data';
        dataMapInfo(index).property=doseColumnNames{i};
        dataMapInfo(index).value=doseComponentNames{i};
        dataMapInfo(index).valueType='species';


        children=getFitDefinitionStructTemplate;
        children=repmat(children,4,1);
        properties={'Column','Target','Rate','Time Lag Parameter'};
        valueType={'rawdata','species','rawDataParameter','parameter'};

        for j=1:numel(children)
            children(j).isChild=true;
            children(j).property=properties{j};
            children(j).valueType=valueType{j};
        end


        children(1).value=doseColumnNames{i};
        children(2).value=doseComponentNames{i};
        children(3).value='Instant';
        children(4).value='';


        field=doseClassifications{i};
        field=['Rate',field(5:end)];
        fieldIndex=strcmp(classifications,field);
        if any(fieldIndex)
            children(3).value=columnNames{fieldIndex};
        end


        dataMapInfo(index).children=children;
    end

end

function dataMapInfo=getDataMapInfoOldProjects(node,selectedData)

    dataColumnNames=[];
    dataClassification=[];

    if~isempty(selectedData)
        dataColumnNames={selectedData.dataInfo.columnInfo.name};
        dataClassification={selectedData.dataInfo.columnInfo.classification};
    end


    groupSettings=node.GroupSettings;
    columnNamesCount=getAttribute(groupSettings,'ColumnNamesCount');
    classifications=cell(1,columnNamesCount);
    componentNames=cell(1,columnNamesCount);

    for i=1:columnNamesCount
        classifications{i}=getAttribute(groupSettings,sprintf('Description%d',(i-1)));
        componentNames{i}=getAttribute(groupSettings,sprintf('ColumnNames%d',(i-1)));
    end


    depColumns=startsWith(classifications,'Response');
    doseColumns=startsWith(classifications,'Dose');


    totalRows=2+sum(depColumns)+sum(doseColumns);
    dataMapInfo=getFitDefinitionStructTemplate;
    dataMapInfo=repmat(dataMapInfo,totalRows,1);


    dataMapInfo(1).classification='group';
    dataMapInfo(1).property=dataColumnNames{strcmp(dataClassification,'group')};
    dataMapInfo(1).columnSpan=[1,1,1,3];


    dataMapInfo(2).classification='independent';
    dataMapInfo(2).property=dataColumnNames{strcmp(dataClassification,'independent')};
    dataMapInfo(2).columnSpan=[1,1,1,3];


    dependentColumns=dataColumnNames(strcmp(dataClassification,'dependent'));
    count=3;
    for i=1:columnNamesCount
        description=getAttribute(groupSettings,sprintf('Description%d',(i-1)));
        if startsWith(description,'Response')
            componentName=getAttribute(groupSettings,sprintf('ColumnNames%d',(i-1)));

            if startsWith(description,'Response Variable')
                num=strsplit(description,'Response Variable');
            elseif startsWith(description,'Response')
                num=strsplit(description,'Response');
            end

            if numel(num)>1
                num=str2double(num{2});
            end

            if isnan(num)||isempty(num)
                num=1;
            end


            if numel(dependentColumns)>=num
                columnName=dependentColumns{num};
            else
                columnName='';
            end


            dataMapInfo(count).classification='response';
            dataMapInfo(count).property=columnName;
            dataMapInfo(count).value=componentName;
            dataMapInfo(count).valueType='speciesParameter';


            children=getFitDefinitionStructTemplate;
            children=repmat(children,2,1);
            properties={'Column','Component'};
            valueType={'rawdata','speciesParameter'};

            for j=1:numel(children)
                children(j).isChild=true;
                children(j).property=properties{j};
                children(j).valueType=valueType{j};
            end


            children(1).value=dataMapInfo(count).property;
            children(2).value=dataMapInfo(count).value;


            dataMapInfo(count).children=children;
            count=count+1;
        end
    end


    doseColumnNames=dataColumnNames(startsWith(dataClassification,'dose'));
    for i=1:columnNamesCount
        description=getAttribute(groupSettings,sprintf('Description%d',(i-1)));
        if startsWith(description,'Dose')
            componentName=getAttribute(groupSettings,sprintf('ColumnNames%d',(i-1)));

            if startsWith(description,'Dose Variable')
                num=strsplit(description,'Dose Variable');
            elseif startsWith(description,'Dose')
                num=strsplit(description,'Dose');
            end

            if numel(num)>1
                num=str2double(num{2});
            end

            if isnan(num)||isempty(num)
                num=1;
            end


            if numel(doseColumnNames)>=num
                columnName=doseColumnNames{num};
            else
                columnName='';
            end


            dataMapInfo(count).classification='dose from data';
            dataMapInfo(count).property=columnName;
            dataMapInfo(count).value=componentName;
            dataMapInfo(count).valueType='species';


            children=getFitDefinitionStructTemplate;
            children=repmat(children,4,1);
            properties={'Column','Target','Rate','Time Lag Parameter'};
            valueType={'rawdata','species','rawDataParameter','parameter'};

            for j=1:numel(children)
                children(j).isChild=true;
                children(j).property=properties{j};
                children(j).valueType=valueType{j};
            end


            children(1).value=columnName;
            children(2).value=componentName;
            children(3).value='Instant';
            children(4).value='';

            rateColumnName='';
            if any(strcmp(dataClassification,sprintf('rate%d',num)))
                rateColumnName=dataColumnNames{strcmp(dataClassification,sprintf('rate%d',num))};
            end

            if~isempty(rateColumnName)
                children(3).value=rateColumnName;
            end


            dataMapInfo(count).children=children;
            count=count+1;
        end
    end

end

function step=getGroupSimulationStructTemplate

    step=struct;
    step.description='';
    step.enabled=true;
    step.internal=[];
    step.name='Group Simulation';
    step.runInParallel=0;
    step.sliders=[];
    step.stopTimeSettings=[];
    step.type='Group Simulation';
    step.version=1;


    step.internal=struct;
    step.internal.activeStep=false;
    step.internal.args=struct;
    step.internal.generatePlots=true;
    step.internal.id=3;
    step.internal.isSetup=false;
    step.internal.outputArguments={'results'};


    step.stopTimeSettings=struct;
    step.stopTimeSettings.dataTimesIncluded=true;
    step.stopTimeSettings.stopTimeIncluded=true;
    step.stopTimeSettings.useStopTime=false;
    step.stopTimeSettings.useDataMax=false;
    step.stopTimeSettings.useData=true;
    step.stopTimeSettings.stopTime=10;
    step.stopTimeSettings.useConfigset=true;

end

function out=getFitDefinitionStructTemplate

    out=struct;
    out.ID=-1;
    out.children='';
    out.classification='';
    out.equal='=';
    out.expand=false;
    out.isChild=false;
    out.message=[];
    out.parentID=-1;
    out.property='Column';
    out.sessionID=-1;
    out.UUID=-1;
    out.type='';
    out.use=true;
    out.value='';
    out.valueType='rawdata';

end

function out=getAttribute(node,attribute,varargin)

    out=SimBiology.web.internal.converter.utilhandler('getAttribute',node,attribute,varargin{:});

end

function out=getArrayValues(node,field,projectVersion)

    out=SimBiology.web.internal.converter.utilhandler('getArrayValues',node,field,projectVersion);
end

function out=getInternalStructTemplate

    out=SimBiology.web.internal.converter.utilhandler('getInternalStructTemplate');
end
