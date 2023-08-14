function out=generateSamplesStepHandler(action,varargin)

    switch(action)
    case 'getParameterSetTemplate'
        out=getParameterSetTemplate;
    case 'populateGenerateSamplesTables'
        out=populateGenerateSamplesTables(varargin{:});
    case 'populateDataSetInfoTable'
        out=populateDataSetInfoTable(varargin{:});
    end

end

function genSamplesStep=populateGenerateSamplesTables(projectConverter,taskNode,genSamplesStep,modelSessionID)


    genSamplesStep.enabled=true;
    genSamplesStep.internal.outputArguments={'samples'};


    scanNode=getField(taskNode,'ScanTable');
    runInParallel=getAttribute(scanNode,'Distributed');
    if isempty(runInParallel)
        runInParallel=false;
    end

    genSamplesStep.runInParallel=runInParallel;


    rows=getField(scanNode,'Row');
    rows=rows(1:end-1);


    template=getScanRowTemplate;
    scanObjs=repmat(template,numel(rows),1);

    for i=1:numel(rows)
        scanObjs(i).Name=getAttribute(rows(i),'Name');
        scanObjs(i).LastSelectedOption=getAttribute(rows(i),'LastSelectedOption');
        scanObjs(i).Linear=getAttribute(rows(i),'Linear');
        scanObjs(i).Max=getAttribute(rows(i),'Max');
        scanObjs(i).Min=getAttribute(rows(i),'Min');
        scanObjs(i).ValuesToScan=getAttribute(rows(i),'ValuesToScan');
        scanObjs(i).NumSteps=getAttribute(rows(i),'NumSteps');
        scanObjs(i).IndividualValue=getAttribute(rows(i),'IndividualValue');
        scanObjs(i).Iterations=getAttribute(rows(i),'Iterations');
        scanObjs(i).Run=getAttribute(rows(i),'Run');
        scanObjs(i).Value=getAttribute(rows(i),'Value');
        scanObjs(i).DoseProperty=getAttribute(rows(i),'DoseProperty');

        switch scanObjs(i).LastSelectedOption
        case 6
            scanObjs(i).typeName='Range Of Values';
        case 7
            scanObjs(i).typeName='Percentage Range';
        case 8
            scanObjs(i).typeName='Individual Values';
        case 9
            scanObjs(i).typeName='MATLAB Code';
        otherwise
            scanObjs(i).typeName='Range Of Values';
        end
    end

    scanType=getAttribute(scanNode,'TypeOfScan');
    numIterations=getAttribute(scanNode,'NumberOfIterations_MonteCarlo');
    parameterCombination=getAttribute(scanNode,'CoVary',false);

    if parameterCombination
        parameterCombination='elementwise';
    else
        parameterCombination='cartesian';
    end


    genSamplesStep.parameterSets=getParameterSetTemplate;


    genSamplesStep.parameterSets.parameterCombination=parameterCombination;
    genSamplesStep.parameterSets.userDefinedNumSamples=numIterations;
    genSamplesStep.parameterSets.samplingType='latin hypercube sampling with covariance matrix';


    switch(scanType)
    case 'latin hypercube sample with a normal distribution'

        genSamplesStep.parameterSets.quantityScanType='values from a distribution';
        genSamplesStep.parameterSets.samplingType='latin hypercube sampling with covariance matrix';
        genSamplesStep.parameterSets.parameterCombination='elementwise';
    case 'multivariate normal distribution'

        genSamplesStep.parameterSets.quantityScanType='values from a distribution';
        genSamplesStep.parameterSets.samplingType='random sampling with covariance matrix';
        genSamplesStep.parameterSets.parameterCombination='elementwise';
    end



    [userDefinedTableData,~]=getUserDefinedScanTableData(scanObjs,modelSessionID);
    genSamplesStep.parameterSets.parameterSetData.USERDEFINED=userDefinedTableData;



    distributionTableData=getLatinHypercubeTableData(userDefinedTableData,scanObjs);
    genSamplesStep.parameterSets.parameterSetData.DISTRIBUTION=distributionTableData;







    if numel(rows)>0
        numRows=numel(rows);
        pvPairList=cell(1,numRows);
        model=getModelFromSessionID(modelSessionID);



        for i=1:numRows
            scanTableRow=rows(i);



            numCovariates=getAttribute(scanTableRow,'DependencyNamesCount');
            name=getAttribute(scanTableRow,'Name');
            modelObj=getObject(model,name);

            if isempty(modelObj)
                pvPairList{i}={};
                continue;
            end

            pvPairs=struct('stateName',{{}},'values',{{}});

            if~isempty(numCovariates)
                for j=1:numCovariates
                    prop=getAttribute(scanTableRow,sprintf('DependencyNames%d',j-1));
                    modelObj=getObject(model,prop);

                    if~isempty(modelObj)
                        if strcmp(modelObj.Type,'repeatdose')
                            pqn=[modelObj.Name,'.',getAttribute(rows(i),sprintf('DependencyProperties%d',j-1))];
                        else
                            pqn=modelObj.PartiallyQualifiedNameReally;
                        end
                    end

                    pvPairs.stateName{end+1}=pqn;
                    pvPairs.values{end+1}=getAttribute(scanTableRow,sprintf('DependencyValues%d',j-1));
                end
            end

            pvPairList{i}=pvPairs;
        end




        tableData=struct('ID',-1,'isChild',false,'name','');
        tableData=repmat(tableData,numRows,1);
        rowNames={distributionTableData.name};

        for i=1:numRows
            tableData(i).name=rowNames{i};

            for j=1:numRows
                propName=sprintf('param%d',j-1);

                if~isempty(pvPairList{i})&&any(ismember(pvPairList{i}.stateName,rowNames{j}))
                    idx=ismember(pvPairList{i}.stateName,rowNames{j});
                    values=[pvPairList{i}.values{idx}];



                    tableData(i).(propName)=values(1);
                else
                    tableData(i).(propName)=0;
                end
            end
        end



        try
            for i=1:numRows
                propName=sprintf('param%d',i-1);
                sigmaValue=tableData(i).(propName);
                rowName=tableData(i).name;


                if sigmaValue==0
                    sigmaValue=1;
                end

                rowIdx=strcmp(rowNames,rowName);
                if any(rowIdx)
                    idx=find(rowIdx,1);
                    rowNames{idx}=true;



                    distributionTableData(idx).children(3).value=sqrt(sigmaValue);
                end
            end
        catch
            taskName=getAttribute(taskNode,'Name');
            warningMessage=sprintf('Unable to update sigma values in the task %s. The covariance matrix might be incorrect.',taskName);
            projectConverter.addWarning(warningMessage);
        end


        genSamplesStep.parameterSets.parameterSetData.DISTRIBUTION=distributionTableData;

        isCovMatrixValid=getAttribute(scanNode,'CovarianceMatrixValid');


        covariateInfo=struct('paramNames',{{tableData.name}},'tableData',{tableData},'isValid',{isCovMatrixValid});
        genSamplesStep.parameterSets.parameterSetData.COVARIANCEMATRIX=covariateInfo;
    end

end

function[data,totalIterations]=getUserDefinedScanTableData(rows,modelSessionID)

    template=getUserDefinedRowTemplate;
    data=repmat(template,numel(rows),1);
    totalIterations=1;


    model=getModelFromSessionID(modelSessionID);

    for i=1:numel(rows)
        data(i).use=rows(i).Run;
        data(i).name=rows(i).Name;
        data(i).pqn=rows(i).Name;
        data(i).syncId=i-1;



        if isempty(model)
            data(i).property=rows(i).DoseProperty;
        end

        modelComponent=getObject(model,rows(i).Name);
        if~isempty(modelComponent)
            data(i).name=getPartiallyQualifiedNameReally(modelComponent);
            data(i).pqn=data(i).name;
            data(i).modelValue=getModelValue(modelComponent);
            data(i).type=modelComponent.Type;
            data(i).sessionID=modelComponent.SessionID;
            data(i).UUID=modelComponent.UUID;

            if~isempty(rows(i).DoseProperty)&&strcmp(modelComponent.Type,'repeatdose')
                data(i).name=sprintf('%s.%s',data(i).name,rows(i).DoseProperty);
                data(i).property=rows(i).DoseProperty;
            end
        end


        children=getScanUserDefinedTableChildren;

        typeIdx=findChildRow(children,'Type');
        children(typeIdx).value=rows(i).typeName;


        spacingRowIdx=findChildRow(children,'Spacing');
        if rows(i).Linear
            children(spacingRowIdx).value='linear';
        else
            children(spacingRowIdx).value='log';
        end


        minRowIdx=findChildRow(children,'Min');
        maxRowIdx=findChildRow(children,'Max');

        children(minRowIdx).value=rows(i).Min;
        children(maxRowIdx).value=rows(i).Max;

        if rows(i).LastSelectedOption~=6
            children(minRowIdx).value=0;
            children(maxRowIdx).value=10;
        end


        minPercentRowIdx=findChildRow(children,'Min %');
        maxPercentRowIdx=findChildRow(children,'Max %');

        children(minPercentRowIdx).value=rows(i).Min;
        children(maxPercentRowIdx).value=rows(i).Max;

        if rows(i).LastSelectedOption~=7
            children(minPercentRowIdx).value=-10;
            children(maxPercentRowIdx).value=10;
        else
            if children(minPercentRowIdx).value~=0
                children(minPercentRowIdx).value=-children(minPercentRowIdx).value;
            end
        end


        numStepsIdx=findChildRow(children,'# Of Steps');
        children(numStepsIdx).value=rows(i).NumSteps;


        codeIdx=findChildRow(children,'Code');
        children(codeIdx).value=rows(i).ValuesToScan;
        children(codeIdx).numIterations=rows(i).Iterations;


        valuesIdx=findChildRow(children,'Values');
        children(valuesIdx).value=rows(i).IndividualValue;
        children(valuesIdx).numIterations=rows(i).Iterations;



        individualValues=rows(i).IndividualValue;

        if~isempty(individualValues)
            if isnumeric(individualValues)
                individualValues=num2str(individualValues);
            end

            if~startsWith(individualValues,'[')
                individualValues=sprintf('[%s',individualValues);
            end

            if~endsWith(individualValues,']')
                individualValues=sprintf('%s]',individualValues);
            end
        end


        children(valuesIdx).value=individualValues;



        children(1).visible=true;


        prop=data(i).property;
        if isempty(prop)
            prop=data(i).type;
        end

        switch rows(i).typeName
        case 'Range Of Values'
            children(2).visible=true;
            children(6).visible=true;
            children(7).visible=true;
            children(10).visible=true;
            iterations=children(10).value;
        case 'Percentage Range'
            children(2).visible=true;
            children(3).visible=true;
            children(4).visible=true;
            children(5).visible=true;
            children(10).visible=true;
            iterations=children(10).value;
        case 'Individual Values'
            children(8).visible=true;
            result=SimBiology.web.scanhandler('verifyScanValues',struct('code',children(8).value,'property',prop,'rowID',-1));
            iterations=result{2}.numIterations;
            message=result{2}.message;

            if~isempty(message)
                children(8).message={struct('id','SCAN_INVALID_USER_DEFINED_VALUE','message',message,'type','error')};
            end
        case 'MATLAB Code'
            children(9).visible=true;
            result=SimBiology.web.scanhandler('verifyScanValues',struct('code',children(9).value,'property',prop,'rowID',-1));
            iterations=result{2}.numIterations;
            message=result{2}.message;

            if~isempty(message)
                children(9).message={struct('id','SCAN_INVALID_USER_DEFINED_VALUE','message',message,'type','error')};
            end
        end

        data(i).children=children;


        if iterations>0
            totalIterations=iterations*totalIterations;
        end
    end

end

function data=getLatinHypercubeTableData(userDefinedTableData,scanObjs)

    template=getLatinHyperCubeRowTemplate;
    data=repmat(template,numel(userDefinedTableData),1);

    for i=1:numel(userDefinedTableData)
        data(i).use=userDefinedTableData(i).use;
        data(i).sessionID=userDefinedTableData(i).sessionID;
        data(i).UUID=userDefinedTableData(i).UUID;
        data(i).modelValue=userDefinedTableData(i).modelValue;
        data(i).name=userDefinedTableData(i).name;
        data(i).pqn=userDefinedTableData(i).pqn;
        data(i).syncId=userDefinedTableData(i).syncId;
        data(i).type=userDefinedTableData(i).type;
        data(i).isParameterized=userDefinedTableData(i).isParameterized;
        data(i).paramSessionID=userDefinedTableData(i).paramSessionID;
        data(i).paramUUID=userDefinedTableData(i).paramUUID;
        data(i).property=userDefinedTableData(i).property;
        data(i).children=getLatinHypercubeChildren();


        data(i).children(2).value=scanObjs(i).Value;
    end

end

function children=getScanUserDefinedTableChildren

    childNames={'Type','Spacing','Value','Min %','Max %','Min','Max','Values','Code','# Of Steps'};

    template=getUserDefinedChildTemplate;
    children=repmat(template,numel(childNames),1);


    for i=1:numel(children)
        children(i).name=childNames{i};
    end


    children(1).value='Percentage Range';
    children(3).value='Current Value';
    children(4).value=-10;
    children(5).value=10;
    children(6).value=0;
    children(7).value=10;
    children(10).value=10;

end

function children=getLatinHypercubeChildren

    childNames={'Distribution','mu','sigma'};
    childValues={'Normal',0,1};
    children=getLatinHyperCubeChildTemplate;
    children=repmat(children,numel(childNames),1);

    for i=1:numel(children)
        children(i).name=childNames{i};
        children(i).value=childValues{i};
    end

end

function data=populateDataSetInfoTable(taskNode,data,modelSessionID,externalDataInfo,projectVersion)

    data.enabled=true;
    data.internal.outputArguments={'samples'};


    groupSettings=getField(taskNode,'GroupSettings');


    data.runInParallel=getAttribute(groupSettings,'Distributed');
    if isempty(data.runInParallel)
        data.runInParallel=false;
    end

    dataName=getAttribute(groupSettings,'DataSet');
    columnNamesCount=getAttribute(groupSettings,'ColumnNamesCount');


    data.parameterSets=getParameterSetTemplate();
    data.parameterSets.scanType='Dose';



    if~isempty(dataName)
        data.parameterSets.doseScanType=dataName;
    else
        data.parameterSets.doseScanType='doses in model';
    end

    modelObj=getModelFromSessionID(modelSessionID);
    tableData=[];



    selectedData=[];
    for j=1:numel(externalDataInfo.data)
        if strcmp(externalDataInfo.data(j).name,dataName)
            selectedData=externalDataInfo.data(j);
            break;
        end
    end



    selectedGroups={};
    selectedGroupCount=getAttribute(groupSettings,'SelectedGroupsCount');
    if isempty(selectedGroupCount)
        if~isempty(selectedData)
            columnClassification={selectedData.dataInfo.columnInfo.classification};
            grpIndex=find(strcmp(columnClassification,"group"),1);
            if~isempty(grpIndex)
                groupColumnInfo=selectedData.dataInfo.columnInfo(grpIndex);
                if strcmpi(groupColumnInfo.groupingType,'range')
                    grpRange=groupColumnInfo.groupingValue;


                    selectedGroups=grpRange(1):grpRange(3):grpRange(2);
                else
                    selectedGroups=groupColumnInfo.groupingValue;
                end
            end
        end
    else
        selectedGroups=cell(selectedGroupCount,1);
        for j=1:selectedGroupCount
            selectedGroupAttr=sprintf('SelectedGroups%d',j-1);
            selectedGroups{j}=getAttribute(groupSettings,selectedGroupAttr);
        end
    end

    dataColumnNames=[];
    dataClassification=[];
    selectedDataName='';

    if~isempty(selectedData)
        selectedDataName=selectedData.name;
        dataColumnNames={selectedData.dataInfo.columnInfo.name};
        dataClassification={selectedData.dataInfo.columnInfo.classification};
    end

    for i=1:columnNamesCount
        componentName=getAttribute(groupSettings,sprintf('ColumnNames%d',(i-1)));
        columnName=getAttribute(groupSettings,sprintf('DataSetColumNames%d',(i-1)));
        description=getAttribute(groupSettings,sprintf('Description%d',(i-1)));


        if isempty(columnName)
            dependentCols=dataColumnNames(strcmp(dataClassification,'dependent'));

            if numel(dependentCols)>=i
                columnName=dependentCols{i};
            elseif~isempty(dependentCols)
                columnName=dependentCols{numel(dependentCols)};
            end
        end

        switch projectVersion
        case{'5','5.1'}
            if startsWith(description,'Response')



                responseNum=[];



                if startsWith(description,'Response Variable')
                    responseNum=strsplit(description,'Response Variable');
                elseif startsWith(description,'Response')
                    responseNum=strsplit(description,'Response');
                end

                if numel(responseNum)>1
                    responseNum=str2double(responseNum{2});
                end

                if isnan(responseNum)||isempty(responseNum)
                    responseNum=1;
                end


                dependentColumns=dataColumnNames(strcmp(dataClassification,'dependent'));


                if numel(dependentColumns)>=responseNum
                    columnName=dependentColumns{responseNum};
                end

                description='Dependent';
            elseif startsWith(description,'Dose')
                doseNum=[];

                if startsWith(description,'Dose Variable')
                    doseNum=strsplit(description,'Dose Variable');
                elseif startsWith(description,'Dose')
                    doseNum=strsplit(description,'Dose');
                end


                if numel(doseNum)>1
                    doseNum=str2double(doseNum{2});
                end

                if isnan(doseNum)||isempty(doseNum)
                    doseNum=1;
                end



                if any(strcmp(dataClassification,sprintf('dose%d',doseNum)))
                    columnName=dataColumnNames{strcmp(dataClassification,sprintf('dose%d',doseNum))};
                end

                description='Dose';
            end
        end

        if~(startsWith(description,'Dose'))
            continue;
        end

        row=getGroupSimulationTableData;
        row.name=sprintf('%s',columnName);


        row.externalDataColumn=columnName;
        row.externalDataName=dataName;
        row.qualifiedName=sprintf('%s.%s',dataName,columnName);


        if startsWith(description,'Dependent')

            row.children(1).visible=true;


            row.children(1).value=componentName;

            obj=getObject(modelObj,componentName);
            if~isempty(obj)
                row.children(2).value=obj.PartiallyQualifiedNameReally;
                row.children(2).sessionID=obj.sessionID;
                row.children(2).UUID=obj.UUID;
            end
        elseif startsWith(description,'Dose')
            row.value='dose';


            row.value=componentName;
            obj=getObject(modelObj,componentName);
            if~isempty(obj)
                row.value=obj.PartiallyQualifiedNameReally;
                row.sessionID=obj.sessionID;
                row.UUID=obj.UUID;
            end



            switch projectVersion
            case{'5','5.1'}
                rateColumn=getRateColumnNamePre16b(doseNum,dataColumnNames,dataClassification);
            otherwise
                rateColumn=getRateColumnName(groupSettings,description);
            end

            if~isempty(rateColumn)
                row.children(3).visible=true;
                row.children(3).isUsed=true;
                row.children(3).type='rawdata';
                row.children(3).value=sprintf('%s',rateColumn);
            else
                row.children(3).value='Instant';
            end


            row.children(end).visible=true;
        end



        children=row.children(1:end-1);
        visibleChildren=children([children.visible]);
        hiddenChildren=children(~[children.visible]);


        row.children=vertcat(visibleChildren,hiddenChildren,row.children(end));

        if isempty(tableData)
            tableData=row;
        else
            tableData(end+1)=row;%#ok<AGROW>
        end
    end

    data.parameterSets.parameterSetData.DOSEDATASET.selectedDataName=selectedDataName;
    data.parameterSets.parameterSetData.DOSEDATASET.selectedGroups=selectedGroups;
    data.parameterSets.parameterSetData.DOSEDATASET.tableData=tableData;

end

function out=getGroupSimulationTableData

    out=getGroupSimulationTableRowTemplate;
    description={'Amount Units','Lag Parameter Name','Rate','Rate Units','Time Units',''};
    isOptional=[true,true,true,true,true,false];
    parentType={{'dose'},{'dose'},{'dose'},{'dose'},{'dose'},{'dose'}};
    children=getScanDataSetChildStructTemplate;
    children=repmat(children,numel(description),1);

    for i=1:numel(description)
        children(i).description=description{i};
        children(i).isOptional=isOptional(i);
        children(i).parentType=parentType{i};
    end

    children(end).columnSpan=[1,1,1,3];
    children(end).isUsed=true;
    children(end).isSelectPropRow=true;

    out.children=children;

end

function rateColumnName=getRateColumnName(groupSettings,doseName)

    rateColumnName='';
    index=strsplit(doseName,'Dose');
    index=str2double(index{2});
    rateDescriptionValue=sprintf('Rate%d',index);
    columnNamesCount=getAttribute(groupSettings,'ColumnNamesCount');

    for i=1:columnNamesCount
        idx=i-1;
        descrProp=sprintf('Description%d',idx);
        descrValue=getAttribute(groupSettings,descrProp);

        if strcmp(descrValue,rateDescriptionValue)
            columnNameProp=sprintf('DataSetColumNames%d',idx);
            rateColumnName=getAttribute(groupSettings,columnNameProp);
            return;
        end
    end

end

function columnName=getRateColumnNamePre16b(doseNum,dataColumnNames,dataClassification)

    columnName='';

    if any(strcmp(dataClassification,sprintf('rate%d',doseNum)))
        columnName=dataColumnNames{strcmp(dataClassification,sprintf('rate%d',doseNum))};
    end

end

function out=getGroupSimulationTableRowTemplate

    out=struct;
    out.ID=-1;
    out.description='Target Name';
    out.use=true;
    out.expand=false;
    out.name='';
    out.equal='=';
    out.value='quantity';
    out.children='';
    out.isChild=false;
    out.message=[];
    out.type='datasetScanParameter';
    out.columnSpan='';
    out.externalDataColumn='';
    out.externalDataName='';
    out.qualifiedName='';

end

function out=getScanDataSetChildStructTemplate

    out=struct;
    out.ID=-1;
    out.description='';
    out.editable=true;
    out.isUsed=false;
    out.UUID=-1;
    out.use='';
    out.expand=[];
    out.name='';
    out.equal='=';
    out.value='';
    out.visible=false;
    out.children='';
    out.isChild=true;
    out.isOptional=true;
    out.parentId=-1;
    out.parentType='';
    out.message=[];
    out.sessionID=-1;
    out.type='';
    out.columnSpan='';
    out.isSelectPropRow=false;

end

function out=getScanRowTemplate

    out=struct;
    out.Name='';
    out.LastSelectedOption=7;
    out.Linear=true;
    out.Max=10;
    out.Min=10;
    out.ValuesToScan='';
    out.NumSteps=10;
    out.IndividualValue=[];
    out.Iterations=10;
    out.Run=true;
    out.Value=900;
    out.DoseProperty='';

end

function paramSetStruct=getParameterSetTemplate

    paramSetStruct=struct;
    paramSetStruct.parameterSetData='';
    paramSetStruct.scanType='Quantity';
    paramSetStruct.doseScanType='doses in model';
    paramSetStruct.quantityScanType='user defined values';
    paramSetStruct.use=true;
    paramSetStruct.parameterCombination='elementwise';
    paramSetStruct.userDefinedNumSamples=4;
    paramSetStruct.iterationLimit=1000;
    paramSetStruct.samplingType='latin hypercube sampling with rank correlation matrix';

    parameterSetData=struct;


    defaultStruct=struct;
    defaultStruct.tableData={};
    defaultStruct.selectedDataName='';
    defaultStruct.selectedGroups={};


    samplingMatrix=struct;
    samplingMatrix.paramNames={};
    samplingMatrix.tableData=[];
    samplingMatrix.isValid=true;



    parameterSetData.USERDEFINED=[];
    parameterSetData.DISTRIBUTION=[];
    parameterSetData.DOSES=[];
    parameterSetData.DOSEDATASET=defaultStruct;
    parameterSetData.QUANTITYDATASET=defaultStruct;
    parameterSetData.VARIANTS=[];
    parameterSetData.CORRELATIONMATRIX=samplingMatrix;
    parameterSetData.COVARIANCEMATRIX=samplingMatrix;


    paramSetStruct.parameterSetData=parameterSetData;

end

function out=getUserDefinedRowTemplate

    out=struct;
    out.ID=-1;
    out.UUID=-1;
    out.use='';
    out.expand=false;
    out.name='';
    out.equal='';
    out.value='';
    out.modelValue='';
    out.children='';
    out.isChild=false;
    out.message='';
    out.sessionID=-1;
    out.type='';
    out.columnSpan=[1,1,3,1];
    out.syncId=-1;
    out.pqn='';
    out.property='';
    out.isParameterized=false;
    out.paramSessionID=-1;
    out.paramUUID=-1;

end

function out=getUserDefinedChildTemplate

    out=struct;
    out.ID=-1;
    out.use='';
    out.expand='';
    out.name='';
    out.equal='';
    out.value='';
    out.modelValue='';
    out.children='';
    out.isChild=true;
    out.parentID=-1;
    out.message='';
    out.visible=false;
    out.numIterations=0;

end

function out=getLatinHyperCubeRowTemplate

    out=struct;
    out.ID=-1;
    out.UUID=-1;
    out.use='';
    out.expand=false;
    out.name='';
    out.equal='';
    out.value='';
    out.modelValue='';
    out.children='';
    out.isChild=false;
    out.message='';
    out.sessionID=-1;
    out.type='';
    out.columnSpan=[1,1,3,1];
    out.syncId=-1;
    out.pqn='';
    out.property='';
    out.isParameterized=false;
    out.paramSessionID=-1;
    out.paramUUID=-1;
    out.distributionClassName='Normal';
    out.distributionProperties={'mu','sigma'};

end

function out=getLatinHyperCubeChildTemplate

    out=struct;
    out.ID=-1;
    out.use='';
    out.expand='';
    out.name='';
    out.equal='=';
    out.value='';
    out.children='';
    out.isChild=true;
    out.parentID=-1;
    out.message='';
    out.visible=true;

end

function rowIndex=findChildRow(rows,name)

    rowIndex=-1;
    for i=1:numel(rows)
        if strcmp(rows(i).name,name)
            rowIndex=i;
            return;
        end
    end

end

function out=getModelValue(obj)

    if isempty(obj)
        out='';
        return;
    end

    switch obj.Type
    case 'species'
        out=obj.Value;
    case 'parameter'
        out=obj.Value;
    case 'compartment'
        out=obj.Value;
    case{'repeatdose','scheduledose'}
        out=obj.Amount;
    otherwise
        error('Unhandled getValue for %s',obj.Type);
    end

end

function out=getPartiallyQualifiedNameReally(obj)

    if isempty(obj)
        out='';
        return;
    end

    if~isprop(obj,'PartiallyQualifiedNameReally')||isa(obj,'SimBiology.Dose')
        out=obj.Name;
    else
        out=obj.PartiallyQualifiedNameReally;
    end

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

function obj=getObject(model,name)

    obj=SimBiology.web.internal.converter.utilhandler('getObject',model,name);
end
