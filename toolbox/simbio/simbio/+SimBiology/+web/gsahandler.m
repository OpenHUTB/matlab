function out=gsahandler(action,varargin)











    out={action};

    switch(action)
    case 'convertTableToDoubleForPreview'
        out=convertTableToDoubleForPreview(varargin{:});
    case 'getData'
        out=getData(varargin{:});
    case 'verifyClassifierExpressions'
        out=verifyClassifierExpressions(varargin{:});
    case 'verifyOutputTimes'
        out=verifyOutputTimes(varargin{:});
    end

end

function out=verifyClassifierExpressions(input)

    model=getModelFromSessionID(input.model);
    classifiers=input.classifiers;
    messagesTemplate=struct('IsError',false,'Messages',{});
    out.messages=repmat(messagesTemplate,1,numel(classifiers));
    for i=1:numel(classifiers)
        out.messages(i)=SimBiology.web.internal.validateMPGSAClassifiers(model,classifiers(i));
        if isempty(out.messages(i).IsError)
            out.messages(i).IsError=false;
        end
    end

end

function out=verifyOutputTimes(input)

    model=getModelFromSessionID(input.model);
    value=input.newValue;
    cs=getconfigset(model);
    csNames=get(cs,{'Name'});
    csName=findUniqueName(csNames,'cs');






    transaction=SimBiology.Transaction.create(model);%#ok<NASGU>
    cs1=addconfigset(model,csName);
    isValid=true;

    try
        value=eval(value);
        set(cs1.SolverOptions,'OutputTimes',value);
    catch
        isValid=false;
    end

    out.newValue=input.newValue;
    out.oldValue=input.oldValue;
    out.isValid=isValid;

end

function out=convertTableToDoubleForPreview(data)

    dataout=[];
    headers={};
    datasize=0;

    switch class(data)
    case 'SimBiology.gsa.Sobol'
        [dataout,headers,datasize]=convertTableToDoubleForSobolResults(data);
    case{'SimBiology.gsa.MPGSA'}
        [dataout,headers,datasize]=convertTableToDoubleForMPGSAResults(data);
    case 'SimBiology.gsa.ElementaryEffects'
        [dataout,headers,datasize]=convertTableToDoubleForElementaryEffectsResults(data);
    end

    out.dataout=dataout;
    out.headers=headers;
    out.datasize=datasize;
    out.warnings={};

end

function[dataout,headers,datasize]=convertTableToDoubleForSobolResults(results)


    info=getSobolInfo(results);


    time=results.Time;
    variance=results.Variance;
    varianceNames=info.varianceNames;
    varianceCount=numel(varianceNames);

    sobolIndices=results.SobolIndices;
    if~isempty(info.vectorIndex)
        sobolIndices=sobolIndices(info.vectorIndex);
        sobolCount=numel(sobolIndices);
        numColumns=1+varianceCount+2*sobolCount;
        datasize=numel(time);
    else
        varianceNames=info.scalarVarianceNames;
        varianceCount=numel(varianceNames);
        sobolIndices=sobolIndices(info.scalarIndex);
        sobolCount=numel(sobolIndices);
        numColumns=varianceCount+2*sobolCount;
        datasize=1;
    end


    dataout=cell(1,numColumns);
    headers=cell(1,numColumns);
    idx=0;

    if~isempty(info.vectorIndex)

        headers{1}='Time';
        dataout{1}=time;
        idx=1;
    end


    for i=1:varianceCount
        data=variance.(varianceNames{i});
        if isempty(info.vectorIndex)
            data=data(1);
        end

        headers{idx+1}=['Variance ',varianceNames{i}];
        dataout{idx+1}=data;
        idx=idx+1;
    end

    for i=1:sobolCount
        next=['[I: ',sobolIndices(i).Parameter,', O: ',sobolIndices(i).Observable,']'];
        headers{i+idx}=[next,' First Order'];
        dataout{i+idx}=sobolIndices(i).FirstOrder;
        idx=idx+1;

        headers{i+idx}=[next,' Total Order'];
        dataout{i+idx}=sobolIndices(i).TotalOrder;
    end

end

function[dataout,headers,datasize]=convertTableToDoubleForMPGSAResults(results)


    rawdata=results.PValues;
    classifiers=rawdata.Properties.VariableDescriptions;
    parameters=results.ParameterSamples.Properties.VariableDescriptions;
    datasize=numel(parameters);


    classifierCount=size(classifiers,1);
    numColumns=1+classifierCount;
    dataout=cell(1,numColumns);
    headers=cell(1,numColumns);


    headers{1}='Parameter';
    dataout{1}=parameters;

    for i=1:classifierCount
        headers{i+1}=classifiers{i};
        dataout{i+1}=rawdata{:,i};
    end

end

function[dataout,headers,datasize]=convertTableToDoubleForElementaryEffectsResults(results)


    info=getElementaryEffectsInfo(results);


    time=results.Time;
    resultsData=results.Results;

    if~isempty(info.vectorIndex)
        resultsData=resultsData(info.vectorIndex);
        resultsCount=numel(resultsData);
        numColumns=1+2*resultsCount;
        datasize=numel(time);
    else
        resultsData=resultsData(info.scalarIndex);
        resultsCount=numel(resultsData);
        numColumns=2*resultsCount;
        datasize=1;
    end


    dataout=cell(1,numColumns);
    headers=cell(1,numColumns);


    idx=0;
    if~isempty(info.vectorIndex)
        headers{1}='Time';
        dataout{1}=time;
        idx=1;
    end

    for i=1:resultsCount
        next=['[I: ',resultsData(i).Parameter,', O: ',resultsData(i).Observable,']'];
        headers{i+idx}=[next,' Mean'];
        dataout{i+idx}=resultsData(i).Mean;
        idx=idx+1;

        headers{i+idx}=[next,' Standard Deviation'];
        dataout{i+idx}=resultsData(i).StandardDeviation;
    end

end

function out=getData(inputs)

    data=inputs{1};
    derivedData=inputs{2};%#ok<NASGU>
    variables=inputs{3};


    results=data;

    switch class(results)
    case 'SimBiology.gsa.Sobol'
        tables=getDataForSobolResults(results);
    case{'SimBiology.gsa.MPGSA'}
        tables=getDataForMPGSAResults(results);
    case 'SimBiology.gsa.ElementaryEffects'
        tables=getDataForElementaryEffectsResults(results);
    end



    for i=1:numel(tables)
        tables(i).tablePosition=struct('x','','y','');
        tables(i).tableSize=struct('width','','height','');
    end



    tableMetaData=struct;
    tableMetaData.dataType='gsadata';


    tableStruct=struct;
    tableStruct.tableMetaData=tableMetaData;
    tableStruct.tables=tables;
    variables(end).data=tableStruct;
    out=variables;

end

function tables=getDataForSobolResults(results)

    tables=[];


    sobolInfo=getSobolInfo(results);

    if~isempty(sobolInfo.vectorIndex)
        tables=getDataForTimeDependentSobolResults(sobolInfo,results);
    end

    if~isempty(sobolInfo.scalarIndex)
        table=getDataForScalarSobolResults(sobolInfo,results);
        tables=[tables,table];
    end

    table=buildSimulationInformationTable(results);
    tables=[tables,table];

end

function out=getSobolInfo(results)

    variance=results.Variance;
    sobolIndices=results.SobolIndices;
    names={};
    snames={};


    sobolCount=0;
    sobolVectorIdx=[];
    for i=1:numel(sobolIndices)
        if numel(sobolIndices(i).FirstOrder)>1
            sobolCount=sobolCount+1;
            sobolVectorIdx=[sobolVectorIdx,i];%#ok<*AGROW>
            names{end+1}=sobolIndices(i).Observable;
        else
            snames{end+1}=sobolIndices(i).Observable;
        end
    end


    names=unique(names);
    names=intersect(variance.Properties.VariableNames,names);


    snames=unique(snames);
    snames=intersect(variance.Properties.VariableNames,snames);


    [~,sobolScalarIdx]=setdiff(1:numel(sobolIndices),sobolVectorIdx);


    out.vectorIndex=sobolVectorIdx;
    out.scalarIndex=sobolScalarIdx;
    out.varianceNames=names;
    out.scalarVarianceNames=snames;

end

function table=getDataForTimeDependentSobolResults(sobolInfo,results)


    time=results.Time;
    variance=results.Variance;
    sobolIndices=results.SobolIndices;
    sobolIndices=sobolIndices(sobolInfo.vectorIndex);
    sobolCount=numel(sobolIndices);
    varianceNames=sobolInfo.varianceNames;
    varianceCount=numel(varianceNames);


    numColumns=1+varianceCount+2*sobolCount;



    columnHeadings1={{''},repmat({''},1,varianceCount),repmat({'Sobol Indices'},1,2*sobolCount)};
    columnHeadings1=[columnHeadings1{:}];
    spans1=-1*ones(1,numColumns);
    spans1(2)=varianceCount;
    spans1(2+varianceCount)=2*sobolCount;


    spans2=-1*ones(1,numColumns);
    spans2(2)=varianceCount;
    sobolIndicesNames=cell(1,2*sobolCount);
    count=1;

    for i=1:sobolCount
        nextName=['[Input: ',sobolIndices(i).Parameter,', Output: ',sobolIndices(i).Observable,']'];
        sobolIndicesNames{count}=nextName;
        sobolIndicesNames{count+1}=nextName;
        spans2(1+varianceCount+count)=2;
        count=count+2;
    end

    columnHeadings2={{''},repmat({'Variance'},1,varianceCount),sobolIndicesNames};
    columnHeadings2=[columnHeadings2{:}];


    columnInfo=cell(1,numColumns);
    columnInfo{1}=createColumn('Time',time,'double','',true);

    for i=1:varianceCount
        name=varianceNames{i};
        data=variance.(name);
        columnInfo{i+1}=createColumn(name,data,'double','',true);
    end

    idx=1+varianceCount;
    for i=1:sobolCount
        columnInfo{i+idx}=createColumn('First Order',sobolIndices(i).FirstOrder,'double','',false);
        idx=idx+1;
        columnInfo{i+idx}=createColumn('Total Order',sobolIndices(i).TotalOrder,'double','',false);
    end

    additionalRows=struct;
    additionalRows(1).columnNames=columnHeadings1;
    additionalRows(1).spans=spans1;
    additionalRows(2).columnNames=columnHeadings2;
    additionalRows(2).spans=spans2;


    table=getTableDefinition;
    table.name='Sobol Indices Time Dependent Responses';
    table.additionalRows=additionalRows;
    table.columnInfo=[columnInfo{:}];

end

function table=getDataForScalarSobolResults(sobolInfo,results)


    variance=results.Variance;
    sobolIndices=results.SobolIndices;
    sobolIndices=sobolIndices(sobolInfo.scalarIndex);
    sobolCount=numel(sobolIndices);

    varianceNames=sobolInfo.scalarVarianceNames;
    varianceCount=numel(varianceNames);


    numColumns=varianceCount+2*sobolCount;



    columnHeadings1={repmat({''},1,varianceCount),repmat({'Sobol Indices'},1,2*sobolCount)};
    columnHeadings1=[columnHeadings1{:}];
    spans1=-1*ones(1,numColumns);
    spans1(1)=varianceCount;
    spans1(1+varianceCount)=2*sobolCount;


    spans2=-1*ones(1,numColumns);
    spans2(1)=varianceCount;
    sobolIndicesNames=cell(1,2*sobolCount);
    count=1;

    for i=1:sobolCount
        nextName=['[Input: ',sobolIndices(i).Parameter,', Output: ',sobolIndices(i).Observable,']'];
        sobolIndicesNames{count}=nextName;
        sobolIndicesNames{count+1}=nextName;
        spans2(varianceCount+count)=2;
        count=count+2;
    end

    columnHeadings2={repmat({'Variance'},1,varianceCount),sobolIndicesNames};
    columnHeadings2=[columnHeadings2{:}];


    columnInfo=cell(1,numColumns);

    for i=1:varianceCount
        name=varianceNames{i};
        data=variance.(name);
        columnInfo{i}=createColumn(name,data(1),'double','',true);
    end

    idx=varianceCount;
    for i=1:sobolCount
        columnInfo{i+idx}=createColumn('First Order',sobolIndices(i).FirstOrder,'double','',false);
        idx=idx+1;
        columnInfo{i+idx}=createColumn('Total Order',sobolIndices(i).TotalOrder,'double','',false);
    end

    additionalRows=struct;
    additionalRows(1).columnNames=columnHeadings1;
    additionalRows(1).spans=spans1;
    additionalRows(2).columnNames=columnHeadings2;
    additionalRows(2).spans=spans2;


    table=getTableDefinition;
    table.name='Sobol Indices Scalar Responses';
    table.additionalRows=additionalRows;
    table.columnInfo=[columnInfo{:}];

end

function tables=getDataForMPGSAResults(results)

    tables=buildMPGSATable(results,results.KolmogorovSmirnovStatistics,'Kolmogorov Smirnov Statistics');
    tables(2)=buildMPGSATable(results,results.PValues,'PValues');
    tables(3)=buildSimulationInformationTable(results);

end

function table=buildMPGSATable(results,rawdata,tableName)


    classifiers=rawdata.Properties.VariableDescriptions;
    parameters=results.ParameterSamples.Properties.VariableDescriptions;


    classifierCount=size(classifiers,1);
    numColumns=1+classifierCount;



    columnHeadings1={{''},repmat({'Classifier'},1,classifierCount)};
    columnHeadings1=[columnHeadings1{:}];
    spans1=-1*ones(1,numColumns);
    spans1(2)=classifierCount;


    columnInfo=cell(1,numColumns);
    columnInfo{1}=createColumn('Parameter',parameters,'string','',true);

    for i=1:classifierCount
        name=classifiers{i};
        data=rawdata{:,i};
        columnInfo{i+1}=createColumn(name,data,'double','',false);
    end

    additionalRows=struct;
    additionalRows(1).columnNames=columnHeadings1;
    additionalRows(1).spans=spans1;


    table=getTableDefinition;
    table.name=tableName;
    table.additionalRows=additionalRows;
    table.columnInfo=[columnInfo{:}];

end

function tables=getDataForElementaryEffectsResults(results)

    tables=[];


    info=getElementaryEffectsInfo(results);

    if~isempty(info.vectorIndex)
        tables=getDataForTimeDependentElementaryEffectsResults(info,results);
    end

    if~isempty(info.scalarIndex)
        table=getDataForScalarElementaryEffectsResults(info,results);
        tables=[tables,table];
    end

    table=buildSimulationInformationTable(results);
    tables=[tables,table];

end

function out=getElementaryEffectsInfo(results)

    resultsData=results.Results;


    count=0;
    vectorIdx=[];

    for i=1:numel(resultsData)
        if numel(resultsData(i).Mean)>1
            count=count+1;
            vectorIdx=[vectorIdx,i];
        end
    end


    [~,scalarIdx]=setdiff(1:numel(resultsData),vectorIdx);


    out.vectorIndex=vectorIdx;
    out.scalarIndex=scalarIdx;

end

function tables=getDataForTimeDependentElementaryEffectsResults(info,results)


    time=results.Time;
    resultsData=results.Results;
    resultsData=resultsData(info.vectorIndex);


    resultsCount=numel(resultsData);
    numColumns=1+2*resultsCount;



    columnHeadings1={{''},repmat({'Results'},1,2*resultsCount)};
    columnHeadings1=[columnHeadings1{:}];
    spans1=-1*ones(1,numColumns);
    spans1(2)=2*resultsCount;


    spans2=-1*ones(1,numColumns);
    resultNames=cell(1,2*resultsCount);
    count=1;

    for i=1:resultsCount
        nextName=['[Input: ',resultsData(i).Parameter,', Output: ',resultsData(i).Observable,']'];
        resultNames{count}=nextName;
        resultNames{count+1}=nextName;

        spans2(1+count)=2;
        count=count+2;
    end

    columnHeadings2={{''},resultNames};
    columnHeadings2=[columnHeadings2{:}];


    columnInfo=cell(1,numColumns);
    columnInfo{1}=createColumn('Time',time,'double','',true);

    idx=1;
    for i=1:resultsCount
        columnInfo{i+idx}=createColumn('Mean',resultsData(i).Mean,'double','',false);
        idx=idx+1;
        columnInfo{i+idx}=createColumn('Standard Deviation',resultsData(i).StandardDeviation,'double','',false);
    end

    additionalRows=struct;
    additionalRows(1).columnNames=columnHeadings1;
    additionalRows(1).spans=spans1;
    additionalRows(2).columnNames=columnHeadings2;
    additionalRows(2).spans=spans2;


    tables=getTableDefinition;
    tables.name='Elementary Effects Time Dependent Responses';
    tables.additionalRows=additionalRows;
    tables.columnInfo=[columnInfo{:}];

end

function tables=getDataForScalarElementaryEffectsResults(info,results)


    resultsData=results.Results;
    resultsData=resultsData(info.scalarIndex);


    resultsCount=numel(resultsData);
    numColumns=2*resultsCount;


    spans1=-1*ones(1,numColumns);
    resultNames=cell(1,2*resultsCount);
    count=1;

    for i=1:resultsCount
        nextName=['[Input: ',resultsData(i).Parameter,', Output: ',resultsData(i).Observable,']'];
        resultNames{count}=nextName;
        resultNames{count+1}=nextName;
        spans1(count)=2;
        count=count+2;
    end

    columnHeadings1=resultNames;


    columnInfo=cell(1,numColumns);

    idx=0;
    for i=1:resultsCount
        columnInfo{i+idx}=createColumn('Mean',resultsData(i).Mean,'double','',false);
        idx=idx+1;
        columnInfo{i+idx}=createColumn('Standard Deviation',resultsData(i).StandardDeviation,'double','',false);
    end

    additionalRows=struct;
    additionalRows(1).columnNames=columnHeadings1;
    additionalRows(1).spans=spans1;


    tables=getTableDefinition;
    tables.name='Elementary Effects Scalar Responses';
    tables.additionalRows=additionalRows;
    tables.columnInfo=[columnInfo{:}];

end

function table=buildSimulationInformationTable(results)

    switch class(results)
    case 'SimBiology.gsa.Sobol'
        tableName='Sobol Indices Sample Information';
        value=all(results.SimulationInfo.ValidSample,2);
    case 'SimBiology.gsa.MPGSA'
        tableName='MPGSA Sample Information';
        value=results.SimulationInfo.ValidSample;
    case 'SimBiology.gsa.ElementaryEffects'
        tableName='Elementary Effects Sample Information';
        numSensInputs=size(results.Results,1);
        value=all(reshape(results.SimulationInfo.ValidSample,numSensInputs+1,[])',2);
    end

    numberOfSims=numel(value);
    successfulSims=sum(value);


    numColumns=2;
    columnInfo=cell(1,numColumns);
    columnInfo{1}=createColumn('Property',{'Number of Samples','Number of Successful Samples'},'string','',true);
    columnInfo{2}=createColumn('Value',[numberOfSims;successfulSims],'double','',false);


    table=getTableDefinition;
    table.name=tableName;
    table.additionalRows=[];
    table.columnInfo=[columnInfo{:}];

end

function out=createColumn(name,data,dataType,propName,isCommon)


    data=SimBiology.web.datahandler('scrubData',data);

    out=getColumnStructDefinition;
    out.classification='';
    out.data=data;
    out.expression='';
    out.name=name;
    out.numRows=numel(out.data);
    out.type=dataType;
    out.units='';
    out.propName=propName;
    out.isCommon=isCommon;

end

function name=findUniqueName(allNames,nameIn)

    name=SimBiology.web.codegenerationutil('findUniqueName',allNames,nameIn);

end

function out=getColumnStructDefinition

    out=struct('classification','','data','','expression','',...
    'name','','numRows','','type','','units','','propName','',...
    'isCommon',false);

end

function out=getModelFromSessionID(sessionID)

    out=SimBiology.web.modelhandler('getModelFromSessionID',sessionID);

end

function out=getTableDefinition

    out=struct('name','','reshapeForComparison',false,...
    'allowSorting',false,'additionalRows',[],'mergeUsingGroups',false,...
    'mergeWithRepetition',false,'tableType','gsadata',...
    'displayType','','columnInfo',getColumnStructDefinition(),...
    'datasheetDisplayIndex',100);
end
