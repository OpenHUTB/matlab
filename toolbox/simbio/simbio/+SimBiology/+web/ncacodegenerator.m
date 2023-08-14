function[stepCall,stepCode,stepCleanup]=ncacodegenerator(step,steps)











    dataType=step.dataType;
    switch(dataType)
    case 'externalTableData'
        [stepCall,stepCode,stepCleanup]=generateNCACode(step);
    case 'programData'

        [stepCall,stepCode,stepCleanup]=generateNCAProgramDataCode(step,steps);
    case 'savedProgramData'


        [stepCall,stepCode,stepCleanup]=generateNCASavedProgramDataCode(step,steps);
    case 'savedProgramDataNoSetup'


        [stepCall,stepCode,stepCleanup]=generateNCASavedProgramDataNoSetupCode(step,steps);
    case 'externalSimData'


        [stepCall,stepCode,stepCleanup]=generateNCAExternalSimDataCode(step,steps);
    end

    stepCode=appendCode('',stepCode);

end

function[stepCall,stepCode,stepCleanup]=generateNCAProgramDataCode(step,steps)

    stepCall='% Run non-compartmental analysis.';
    stepCall=appendCode(stepCall,'args = runNCA(args);');


    responses=step.responses;
    responseNames={};
    for i=1:length(responses)
        if responses(i).use
            responseNames{end+1}=responses(i).name;%#ok<AGROW>
        end
    end
    responses=createCommaSeparatedQuotedList(responseNames);
    responses=['{',responses,'}'];


    stepCode=readTemplate('runNCASimData.txt');
    stepCode=strrep(stepCode,'$(CONCENTRATION_COLUMN_NAME)',responses);




    doseStep=getStepByType(steps,'Dose');
    fieldName='modelStep';
    if doseStep.enabled
        fieldName='doseStep';
    end


    dataArgs='data.simdata = args.output.results;';
    dataArgs=appendCode(dataArgs,['data.dose    = args.input.doses.',fieldName,';']);
    stepCode=strrep(stepCode,'$(DATA_ARGS)',dataArgs);


    stepCleanup={};

end

function[stepCall,stepCode,stepCleanup]=generateNCASavedProgramDataCode(step,steps)


    dataStep=getStepByType(steps,'DataNCA');
    programInfo=load(dataStep.dataMATFile,'programInfo');


    programInfo=programInfo.programInfo;
    tableCode='data.dose                          = [];';

    if isfield(programInfo,'dose')
        doseInfo=programInfo.dose;
        value=[];

        if isfield(doseInfo,'doseStep')


            value=doseInfo.doseStep;
        elseif isfield(doseInfo,'modelStep')


            value=doseInfo.modelStep;
        end

        if numel(value)==1
            tableCode=getCodeForTable(value);
        end
    end


    stepCall='% Run non-compartmental analysis.';
    stepCall=appendCode(stepCall,'args = runNCA(args);');


    responses=step.responses;
    responseNames={};
    for i=1:length(responses)
        if responses(i).use
            responseNames{end+1}=responses(i).name;%#ok<AGROW>
        end
    end
    responses=createCommaSeparatedQuotedList(responseNames);
    responses=['{',responses,'}'];


    calcObservables=getStepByType(steps,'Calculate Observables');
    dataArg='args.input.data';
    if~isempty(calcObservables)&&calcObservables.enabled
        dataArg='args.output.results';
    end


    stepCode=readTemplate('runNCASimData.txt');
    stepCode=strrep(stepCode,'$(CONCENTRATION_COLUMN_NAME)',responses);


    dataArgs=['data.simdata                       = ',dataArg,';'];
    dataArgs=appendCode(dataArgs,tableCode);
    stepCode=strrep(stepCode,'$(DATA_ARGS)',dataArgs);


    stepCleanup={};

end

function[stepCall,stepCode,stepCleanup]=generateNCASavedProgramDataNoSetupCode(step,steps)


    stepCall='% Run non-compartmental analysis.';
    stepCall=appendCode(stepCall,'args = runNCA(args);');


    responses=step.responses;
    responseNames={};
    for i=1:length(responses)
        if responses(i).use
            responseNames{end+1}=responses(i).name;%#ok<AGROW>
        end
    end
    responses=createCommaSeparatedQuotedList(responseNames);
    responses=['{',responses,'}'];


    stepCode=readTemplate('runNCASimData.txt');
    stepCode=strrep(stepCode,'$(CONCENTRATION_COLUMN_NAME)',responses);


    calcObservables=getStepByType(steps,'Calculate Observables');
    dataArg='args.input.data';
    if~isempty(calcObservables)&&calcObservables.enabled
        dataArg='args.output.results';
    end


    tableCode=buildDoseTableCode(step);
    dataArgs=['data.simdata                    = ',dataArg,';'];
    dataArgs=appendCode(dataArgs,tableCode);
    stepCode=strrep(stepCode,'$(DATA_ARGS)',dataArgs);


    stepCleanup={};

end

function[stepCall,stepCode,stepCleanup]=generateNCAExternalSimDataCode(step,steps)


    stepCall='% Run non-compartmental analysis.';
    stepCall=appendCode(stepCall,'args = runNCA(args);');


    responses=step.responses;
    responseNames={};
    for i=1:length(responses)
        if responses(i).use
            responseNames{end+1}=responses(i).name;%#ok<AGROW>
        end
    end
    responses=createCommaSeparatedQuotedList(responseNames);
    responses=['{',responses,'}'];


    stepCode=readTemplate('runNCASimData.txt');
    stepCode=strrep(stepCode,'$(CONCENTRATION_COLUMN_NAME)',responses);


    calcObservables=getStepByType(steps,'Calculate Observables');
    dataArg='args.input.data';
    if~isempty(calcObservables)&&calcObservables.enabled
        dataArg='args.output.results';
    end


    tableCode=buildDoseTableCode(step);
    dataArgs=['data.simdata                       = ',dataArg,';'];
    dataArgs=appendCode(dataArgs,tableCode);
    stepCode=strrep(stepCode,'$(DATA_ARGS)',dataArgs);


    stepCleanup={};

end

function tableCode=buildDoseTableCode(step)


    doseData=step.dose;
    if isempty(doseData)
        tableCode='data.doses                      = [];';
        return;
    end

    time=zeros(length(doseData),1);
    amount=zeros(length(doseData),1);
    rate=zeros(length(doseData),1);
    for i=1:length(doseData)
        if ischar(doseData(i).time)
            time(i)=str2double(doseData(i).time);
        else
            time(i)=doseData(i).time;
        end

        if ischar(doseData(i).amount)
            amount(i)=str2double(doseData(i).amount);
        else
            amount(i)=doseData(i).amount;
        end

        if ischar(doseData(i).rate)
            rate(i)=str2double(doseData(i).rate);
        else
            rate(i)=doseData(i).rate;
        end
    end

    time=mat2str(time);
    amount=mat2str(amount);
    rate=mat2str(rate);

    tableCode=['timeValues                         = ',time,';'];
    tableCode=appendCode(tableCode,['amountValues                       = ',amount,';']);
    tableCode=appendCode(tableCode,['rateValues                         = ',rate,';']);
    tableCode=appendCode(tableCode,'names                              = {''Time'', ''Amount'', ''Rate''};');
    tableCode=appendCode(tableCode,'data.dose                          = table(timeValues, amountValues, rateValues, ''VariableNames'', names);');
    tableCode=appendCode(tableCode,['data.dose.Properties.VariableUnits = {''',step.timeUnits,''', ''',step.amountUnits,''', ''',step.rateUnits,'''};']);

end

function[stepCall,stepCode,stepCleanup]=generateNCACode(step)

    stepCall='% Run non-compartmental analysis.';
    stepCall=appendCode(stepCall,'args = runNCA(args);');


    for i=1:length(step.definition)
        switch(step.definition(i).classification)
        case 'Group'
            groupDataColumn=step.definition(i).column;
        case 'ID'
            idDataColumn=step.definition(i).column;
        case 'Time'
            timeDataColumn=step.definition(i).column;
        case 'Concentration'
            concDataColumn=step.definition(i).column;
        case 'IV Bolus Dose'
            ivdoseDataColumn=step.definition(i).column;
        case 'Extravascular Dose'
            evdoseDataColumn=step.definition(i).column;
        end
    end

    if strcmp(idDataColumn,' ')
        idDataColumn='';
    end

    if strcmp(ivdoseDataColumn,' ')
        ivdoseDataColumn='';
    end

    if strcmp(evdoseDataColumn,' ')
        evdoseDataColumn='';
    end

    loq=step.loq;
    if isnumeric(loq)
        loq=num2str(loq);
    end

    lambdaTimeRange=step.lambdaTimeRange;
    if isempty(lambdaTimeRange)
        lambdaTimeRange='[NaN NaN]';
    end

    partialAUC=step.partialAUC;
    if isempty(partialAUC)
        partialAUC='[]';
    end

    cmaxTimeRange=step.cmaxTimeRange;
    if isempty(cmaxTimeRange)
        cmaxTimeRange='[]';
    end

    sparseSampling=step.sparseSampling;
    if isempty(sparseSampling)
        sparseSampling='false';
    end


    stepCode=readTemplate('runNCA.txt');

    stepCode=strrep(stepCode,'$(GROUPING_COLUMN_NAME)',['''',groupDataColumn,'''']);
    stepCode=strrep(stepCode,'$(ID_COLUMN_NAME)',['''',idDataColumn,'''']);
    stepCode=strrep(stepCode,'$(INDEPENDENT_COLUMN_NAME)',['''',timeDataColumn,'''']);
    stepCode=strrep(stepCode,'$(CONCENTRATION_COLUMN_NAME)',['''',concDataColumn,'''']);
    stepCode=strrep(stepCode,'$(IVDOSE_COLUMN_NAME)',['''',ivdoseDataColumn,'''']);
    stepCode=strrep(stepCode,'$(EVDOSE_COLUMN_NAME)',['''',evdoseDataColumn,'''']);
    stepCode=strrep(stepCode,'$(SPARSE_DATA)',sparseSampling);
    stepCode=strrep(stepCode,'$(LOQ)',loq);
    stepCode=strrep(stepCode,'$(LAMBDA_Z_RANGE)',lambdaTimeRange);
    stepCode=strrep(stepCode,'$(PARTIAL_AREAS)',['{',partialAUC,'}']);
    stepCode=strrep(stepCode,'$(CMAX_RANGES)',['{',cmaxTimeRange,'}']);


    stepCleanup={};

end

function code=getCodeForTable(input)

    table=input.Table;
    props=table.Properties.VariableNames;
    units=table.Properties.VariableUnits;
    needToAddRate=~any(strcmp(table.Properties.VariableNames,'Rate'));


    values='';
    for i=1:numel(props)
        values=[values,mat2str(table.(props{i})),', '];%#ok<AGROW>
    end

    if needToAddRate
        props{end+1}='Rate';
        units{end+1}='';
        value1=table.(props{1});
        value1=zeros(size(value1));
        values=[values,mat2str(value1),', '];
    end

    varNames=['{',createCommaSeparatedQuotedList(props),'};'];
    tableCode=['table(',values,'''VariableNames'', names);'];

    code=['names                              = ',varNames];
    code=appendCode(code,['data.dose                          = ',tableCode]);
    code=appendCode(code,['data.dose.Properties.VariableUnits = {',createCommaSeparatedQuotedList(units),'};']);

end

function code=appendCode(code,newCode)

    code=SimBiology.web.codegenerationutil('appendCode',code,newCode);

end

function out=createCommaSeparatedQuotedList(list)

    out=SimBiology.web.codegenerationutil('createCommaSeparatedQuotedList',list);

end

function step=getStepByType(steps,type)

    step=SimBiology.web.codegenerationutil('getStepByType',steps,type);

end

function content=readTemplate(name)

    content=SimBiology.web.codegenerationutil('readTemplate',name);

end
