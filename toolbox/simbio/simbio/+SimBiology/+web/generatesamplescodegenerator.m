function[stepCall,stepCode,stepCleanup,step,argList]=generatesamplescodegenerator(step,model,argList,support)












    stepCall='% Generate samples.';
    stepCall=appendCode(stepCall,'args = runGenerateSamples(args);');
    stepCode=readTemplate('runGenerateSamples.txt');
    stepCleanup={};


    [stepCode,paramCode,argList]=generateScanArguments(stepCode,step,model,argList,support);
    step.paramCode=paramCode;

end

function[stepCode,paramCode,argList]=generateScanArguments(stepCode,step,model,argList,support)

    code='';
    pdCount=1;
    allNames={};
    psNames={};
    doseCount=1;
    paramCode='';

    sets=step.parameterSets;
    for i=1:length(sets)
        set=sets(i);
        if(set.use)
            data=set.parameterSetData;


            sampleCount=length(allNames)+1;
            varName=['samples',num2str(sampleCount)];
            allNamesLength=length(allNames);

            switch(set.scanType)
            case 'Quantity'
                [code,allNames,pdCount,paramCode,doseCount,argList]=defineQuantityCode(code,set,model,pdCount,varName,allNames,paramCode,doseCount,argList,support);
            case 'Dose'
                [code,allNames,argList]=defineDoseCode(code,set,varName,allNames,argList);
            case 'Variant'
                [code,allNames]=variantsOption(code,set,varName,allNames);
            case 'dataset'
                [code,allNames,argList]=datasetOption(code,data,varName,allNames,argList);
            end

            if(length(allNames)~=allNamesLength)
                psNames{end+1}=set.name;
            end
        end
    end


    code=appendCode(code,'');
    code=appendCode(code,'% Configure RandomSeed to a unique value.');
    for i=1:length(allNames)
        if i==1
            code=appendCode(code,'seeds = typecast(now, ''uint32'');');
            code=appendCode(code,[allNames{i},'.RandomSeed = seeds(1);']);
        else
            code=appendCode(code,[allNames{i},'.RandomSeed = rng;']);
        end
        code=appendCode(code,['generate(',allNames{i},');']);

        if i<length(allNames)
            code=appendCode(code,'');
        end
    end


    if isempty(allNames)
        name='';
    elseif length(allNames)==1
        name=allNames{1};
    else
        [code,name]=defineCombinationCode(code,step.combinations,psNames,allNames);
    end


    code=code(3:end);
    paramCode=paramCode(2:end);


    stepCode=strrep(stepCode,'$(DEFINE_SCAN_ARGS)',code);




    icode=generateSampleCodeArguments(psNames,allNames,name);
    stepCode=strrep(stepCode,'$(SAMPLE_ARGS)',icode);

end

function[code,allNames,pdCount,paramCode,doseCount,argList]=defineQuantityCode(code,set,model,pdCount,varName,allNames,paramCode,doseCount,argList,support)

    switch(set.quantityScanType)
    case 'user defined values'
        [code,allNames,paramCode,doseCount,argList]=userDefinedOption(code,set,model,varName,allNames,paramCode,doseCount,argList,support);
    case{'values from a distribution'}
        if any(strcmp(set.samplingType,{'latin hypercube sampling with covariance matrix','random sampling with covariance matrix'}))
            [code,allNames,paramCode,doseCount,argList]=multivariateOption(code,set,model,varName,allNames,paramCode,doseCount,argList,support);
        else
            [code,allNames,pdCount,paramCode,doseCount,argList]=samplingOption(code,set,model,pdCount,varName,allNames,paramCode,doseCount,argList,support);
        end
    otherwise
        [code,allNames,argList]=datasetOption(code,set,varName,allNames,argList);
    end

end

function[code,allNames,argList]=defineDoseCode(code,set,varName,allNames,argList)

    switch(set.doseScanType)
    case 'doses in model'
        [code,allNames]=dosesOption(code,set,varName,allNames);
    otherwise
        [code,allNames,argList]=datasetOption(code,set,varName,allNames,argList);
    end

end

function[code,name]=defineCombinationCode(code,combinations,psNames,sampleNames)

    if iscell(combinations)
        combinations=[combinations{:}];
    end

    code=appendCode(code,'');

    for i=1:length(combinations)
        name1=combinations(i).prop1;
        name2=combinations(i).prop2;
        sample1=sampleNames(strcmp(name1,psNames));
        sample2=sampleNames(strcmp(name2,psNames));

        if isempty(sample1)
            sample1={name1};
        end

        if isempty(sample2)
            sample2={name2};
        end

        name=combinations(i).name;
        type=combinations(i).product;

        code=appendCode(code,[name,' = add(copy(',sample1{1},'), ''',type,''', ',sample2{1},');']);
    end

end

function[code,allNames,paramCode,doseCount,argList]=userDefinedOption(code,set,model,varName,allNames,paramCode,doseCount,argList,support)

    tableData=set.parameterSetData.USERDEFINED;
    if isempty(tableData)
        return;
    end

    if iscell(tableData)
        tableData=[tableData{:}];
    end

    tableData=tableData([tableData.use]);
    tableData=tableData([tableData.sessionID]~=-1);



    [tableData,paramCode,doseCount,argList]=parseTableDataForRepeatDoses(model,tableData,paramCode,doseCount,argList,support);
    tableData=tableData([tableData.sessionID]~=-1);

    if~isempty(tableData)

        code=appendCode(code,'');
        code=appendCode(code,[varName,' = SimBiology.Scenarios();']);
        allNames{end+1}=varName;%#ok<*AGROW>

        for j=1:length(tableData)
            next=generateUserDefinedCode(tableData(j));
            code=appendCode(code,['add(',varName,', ''',set.parameterCombination,''', ',next,');']);
        end
    end

end

function code=generateUserDefinedCode(data)

    children=data.children;
    if iscell(children)
        children=[children{:}];
    end

    props={children.name};

    switch(children(strcmp('Type',props)).value)
    case 'Range Of Values'
        spacing=children(strcmp('Spacing',props)).value;
        minValue=getNumericValue(children(strcmp('Min',props)).value);
        maxValue=getNumericValue(children(strcmp('Max',props)).value);
        numSteps=getNumericValue(children(strcmp('# Of Steps',props)).value);
        values=generateRangeCode(spacing,minValue,maxValue,numSteps);
    case 'Percentage Range'
        spacing=children(strcmp('Spacing',props)).value;
        minValue=getNumericValue(children(strcmp('Min %',props)).value);
        maxValue=getNumericValue(children(strcmp('Max %',props)).value);
        numSteps=getNumericValue(children(strcmp('# Of Steps',props)).value);

        value=children(strcmp('Value',props)).value;
        if ischar(value)
            if strcmp(value,'Current Value')
                value=data.modelValue;
            else
                value=str2double(value);
            end
        end

        minValue=value+((minValue/100)*value);
        maxValue=value+((maxValue/100)*value);
        if(minValue==0)&&(maxValue==0)
            maxValue=1;
        end
        values=generateRangeCode(spacing,minValue,maxValue,numSteps);
    case 'Individual Values'
        values=children(strcmp('Values',props)).value;
        if~strcmp(values(1),'[')
            values=['[',values,']'];
        end
    case 'MATLAB Code'
        values=children(strcmp('Code',props)).value;
    end

    code=['''',data.name,''', ',values];

end

function cmd=generateRangeCode(spacing,min,max,numValues)

    if strcmp(spacing,'linear')
        cmd=['linspace(',num2str(min),',',num2str(max),',',num2str(numValues),')'];
    else
        cmd=['logspace(log10(',num2str(min),'), log10(',num2str(max),'),',num2str(numValues),')'];
    end

end

function tableData=getSamplingTableData(set)

    tableData=set.parameterSetData.DISTRIBUTION;
    if isempty(tableData)
        return;
    end

    if iscell(tableData)
        tableData=[tableData{:}];
    end

    tableData=tableData([tableData.use]);
    tableData=tableData([tableData.sessionID]~=-1);

end

function[code,allNames,pdCount,paramCode,doseCount,argList]=samplingOption(code,set,model,pdCount,varName,allNames,paramCode,doseCount,argList,support)

    tableData=getSamplingTableData(set);



    [tableData,paramCode,doseCount,argList]=parseTableDataForRepeatDoses(model,tableData,paramCode,doseCount,argList,support);
    tableData=tableData([tableData.sessionID]~=-1);

    if~isempty(tableData)
        startCount=pdCount;
        nameIdx=varName(8:end);



        code=appendCode(code,'');
        code=appendCode(code,[varName,' = SimBiology.Scenarios();']);
        allNames{end+1}=varName;


        for j=1:length(tableData)
            [next,pdCount]=generateProbabilityDistributionCode(tableData(j),varName,pdCount);
            code=appendCode(code,next);
        end


        [code,optionsIncluded,optionsName]=generateSamplingOptionCode(code,set,nameIdx);



        next=generateSamplingCode(set,tableData,varName,startCount,optionsIncluded,optionsName);
        code=appendCode(code,next);
    end

end

function[code,optionsIncluded,optionsName]=generateSamplingOptionCode(code,set,nameIdx)

    [code,optionsIncluded,optionsName]=SimBiology.web.scenarioscodegenerationutil('generateSamplingOptionCode',code,set,set.samplingType,nameIdx);

end

function code=generateSamplingCode(set,tableData,varName,startCount,optionsIncluded,optionsName)


    samplingTypes={'latin hypercube sampling with rank correlation matrix',...
    'sobol sampling with rank correlation matrix',...
    'halton sampling with rank correlation matrix',...
    'copula sampling with rank correlation matrix',...
    'random sampling with rank correlation matrix'};

    samplingMethods={'lhs','sobol','halton','copula','random'};
    samplingIndex=strcmp(set.samplingType,samplingTypes);



    if any(samplingIndex)
        samplingMethod=samplingMethods{samplingIndex};
    else
        samplingMethod='random';
    end


    if length(tableData)>1
        names=createCommaSeparatedQuotedList({tableData.name});
        names=['{',names,'}'];
    else
        names=sprintf('''%s''',tableData.name);
    end


    corrMatrix=generateCovariateMatrix(set.parameterSetData.CORRELATIONMATRIX.paramNames,set.parameterSetData.CORRELATIONMATRIX.tableData);
    corrMatrix=mat2str(corrMatrix);


    numIterations=num2str(set.userDefinedNumSamples);


    args='';
    for i=1:length(tableData)
        args=[args,'pd',num2str(startCount),' '];
        startCount=startCount+1;
    end
    args=args(1:end-1);


    if length(tableData)>1
        args=['[',deblank(args),']'];
    end


    code=['add(',varName,', ''elementwise'', ',...
    names,', ',args,', ''Number'', ',numIterations,', ''SamplingMethod'', ''',samplingMethod,''''];

    if optionsIncluded
        code=[code,', ''SamplingOptions'', ',optionsName,''];
    end

    if isempty(corrMatrix)
        code=[code,');'];
    else
        code=[code,', ''RankCorrelation'', ',corrMatrix,');'];
    end

end

function[code,pdCount]=generateProbabilityDistributionCode(data,varName,pdCount)

    [code,pdCount]=SimBiology.web.scenarioscodegenerationutil('generateProbabilityDistributionCode',data,varName,pdCount);

end

function[code,allNames,paramCode,doseCount,argList]=multivariateOption(code,set,model,varName,allNames,paramCode,doseCount,argList,support)

    tableData=getSamplingTableData(set);



    [tableData,paramCode,doseCount,argList]=parseTableDataForRepeatDoses(model,tableData,paramCode,doseCount,argList,support);
    tableData=tableData([tableData.sessionID]~=-1);


    if~isempty(tableData)

        covMatrix=generateCovariateMatrix(set.parameterSetData.COVARIANCEMATRIX.paramNames,set.parameterSetData.COVARIANCEMATRIX.tableData);
        covMatrix=mat2str(covMatrix);



        code=appendCode(code,'');
        code=appendCode(code,[varName,' = SimBiology.Scenarios();']);
        allNames{end+1}=varName;


        stateNames='';
        meanValues='';
        for j=1:length(tableData)

            stateNames=[stateNames,'''',tableData(j).pqn,''', '];
            meanValues=[meanValues,num2str(getChildPropertyValueFromName(tableData(j).children,'mu')),' '];
        end

        stateNames=stateNames(1:end-2);
        meanValues=deblank(meanValues);
        if length(tableData)>1
            meanValues=['[',meanValues,']'];
        end


        samplingTypes={'latin hypercube sampling with covariance matrix',...
        'random sampling with covariance matrix'};

        samplingMethods={'lhs','random'};
        samplingMethod=samplingMethods{strcmp(set.samplingType,samplingTypes)};


        next=['add(',varName,', ''elementwise'', {',stateNames,'}, ''normal'', ''Mean'', ',meanValues,...
        ', ''Covariance'', ',covMatrix,', ''Number'', ',num2str(set.userDefinedNumSamples)...
        ,', ''SamplingMethod'', ''',samplingMethod,''');'];
        code=appendCode(code,next);
    end

end

function[code,allNames]=dosesOption(code,set,varName,allNames)

    tableData=set.parameterSetData.DOSES;
    if iscell(tableData)
        tableData=[tableData{:}];
    end

    if isempty(tableData)
        return;
    end


    tableData=tableData([tableData.use]);


    sessionID=[tableData.sessionID];
    tableData=tableData(sessionID~=-1);
    doses={tableData.name};

    if~isempty(doses)


        code=appendCode(code,'');
        code=appendCode(code,[varName,' = SimBiology.Scenarios();']);
        allNames{end+1}=varName;

        names='';
        for j=1:length(doses)
            dname=['d',num2str(j)];
            numBlanks=length(varName)-length(dname);
            blankStr='';
            if numBlanks>0
                blankStr=blanks(numBlanks);
            end

            names=[names,dname,'; '];
            code=appendCode(code,[dname,blankStr,' = sbioselect(args.input.model, ''Type'', {''repeatdose'', ''scheduledose''}, ''Name'', ''',doses{j},''');']);
        end

        names=names(1:end-2);
        if length(doses)>1
            names=['[',names,']'];
        end

        code=appendCode(code,['add(',varName,', ''cartesian'', ''',set.name,''', ',names,');']);
    end

end

function[code,allNames]=variantsOption(code,set,varName,allNames)

    tabledata=set.parameterSetData.VARIANTS;
    if iscell(tabledata)
        tabledata=[tabledata{:}];
    end

    if isempty(tabledata)
        return;
    end


    tabledata=tabledata([tabledata.use]);


    sessionID=[tabledata.sessionID];
    tabledata=tabledata(sessionID~=-1);
    variants={tabledata.name};

    if~isempty(variants)


        code=appendCode(code,'');
        code=appendCode(code,[varName,' = SimBiology.Scenarios();']);
        allNames{end+1}=varName;

        names='';
        for j=1:length(variants)
            vname=['v',num2str(j)];
            numBlanks=length(varName)-length(vname);
            blankStr='';
            if numBlanks>0
                blankStr=blanks(numBlanks);
            end

            names=[names,vname,'; '];
            code=appendCode(code,[vname,blankStr,' = sbioselect(args.input.model, ''Type'', ''variant'', ''Name'', ''',variants{j},''');']);
        end

        names=names(1:end-2);
        if length(variants)>1
            names=['[',names,']'];
        end

        code=appendCode(code,['add(',varName,', ''cartesian'', ''',set.name,''', ',names,');']);
    end

end

function[code,allNames,argList]=datasetOption(code,set,varName,allNames,argList)

    if strcmp(set.scanType,'Quantity')
        data=set.parameterSetData.QUANTITYDATASET;
    else
        data=set.parameterSetData.DOSEDATASET;
    end

    groups=data.selectedGroups;
    tableData=data.tableData;

    if iscell(tableData)
        tableData=[tableData{:}];
    end

    tableData=tableData([tableData.use]);


    variableData=SimBiology.web.codegenerationutil('loadTableData',data.dataMATFile,data.dataMATFileVariableName,data.matfileDerivedVariableName);
    if~isa(variableData,'SimData')&&isfield(data,'exclusions')
        variableData(data.exclusions,:)=[];
    end

    dataSourceInfo=struct;
    dataSourceInfo.programName='';
    dataSourceInfo.dataName=data.selectedDataName;
    dataSourceInfo.variableName='';
    dataSourceInfo.groupVariableName=data.groupColumn;
    dataSourceInfo.independentVariableName=data.independentColumn;
    dataSourceInfo.associatedDataSource=[];



    code=appendCode(code,'');
    code=appendCode(code,[varName,' = SimBiology.Scenarios();']);
    allNames{end+1}=varName;


    if strcmp(set.scanType,'Quantity')
        [code,argList]=datasetQuantityOption(code,varName,set.name,variableData,dataSourceInfo,groups,data.groupColumn,tableData,argList);
    else
        for i=1:length(tableData)
            dataColumn=tableData(i).externalDataColumn;
            if length(tableData)>1
                index=i;
            else
                index='';
            end
            [code,argList]=datasetDoseOption(code,varName,set.name,variableData,dataSourceInfo,groups,data.groupColumn,data.independentColumn,dataColumn,tableData(i),index,argList);
        end
    end

end

function[code,argList]=datasetQuantityOption(code,varName,setName,variableData,dataSourceInfo,groups,groupColumn,tableData,argList)

    groupData=variableData.(groupColumn);

    values=zeros(length(tableData),length(groups));
    for i=1:length(tableData)
        dataColumn=tableData(i).externalDataColumn;
        data=variableData.(dataColumn);
        if isnumeric(groups)
            for g=1:length(groups)
                next=data(groupData==groups(g));
                values(i,g)=next(1);
            end
        else
            for g=1:length(groups)
                next=data(strcmp(groupData,groups(g)));
                values(i,g)=next(1);
            end
        end
    end


    groupBins=getGroupBinsFromDataset(variableData,groups);

    for g=length(groupBins):-1:1
        name=groupBins(g).value;
        variants(g)=sbiovariant(name);
        set(variants(g),'UserData',struct('dataSource',dataSourceInfo,'group',groupBins(g)));
        for i=1:length(tableData)
            variants(g).addcontent({tableData(i).type,tableData(i).componentName,SimBiology.web.codegenerationutil('getValueProperty',tableData(i).type),values(i,g)});
        end
    end
    variants=variants';


    args=argList{3};
    stepStruct=struct;
    if isfield(args,'generateSamplesStep')
        stepStruct=args.generateSamplesStep;
    else
        args.generateSamplesStep=stepStruct;
    end

    allNames=fieldnames(stepStruct);
    if isempty(allNames)
        variantsArrayName='variants1';
    else
        variantsArrayName=findUniqueName(fieldnames(stepStruct),'variants');
    end

    args.generateSamplesStep.(variantsArrayName)=variants;
    argList{3}=args;


    code=appendCode(code,['add(',varName,', ''elementwise'', ''',setName,''', args.input.variants.generateSamplesStep.',variantsArrayName,');']);

end

function[code,argList]=datasetDoseOption(code,varName,setName,variableData,dataSourceInfo,groups,groupColumn,independentColumn,dataColumn,tableData,index,argList)

    gd=groupedData(variableData);


    rate=getChildPropertyValueFromDescription(tableData.children,'Rate');
    rateType=getChildPropertyTypeFromDescription(tableData.children,'Rate');
    rateColumn='';
    durationParameter='';

    if~isempty(rate)
        if strcmp(rateType,'rawdata')
            rateColumn=rate;
        elseif strcmp(rateType,'parameter')
            durationParameter=rate;
        end
    end


    gd.Properties.GroupVariableName=groupColumn;
    gd.Properties.IndependentVariableName=independentColumn;


    d=sbiodose('schedule');
    d.TargetName=tableData.value;
    d.AmountUnits=getChildPropertyValueFromDescription(tableData.children,'Amount Units');
    d.DurationParameterName=durationParameter;
    d.LagParameterName=getChildPropertyValueFromDescription(tableData.children,'Lag Parameter Name');
    d.RateUnits=getChildPropertyValueFromDescription(tableData.children,'Rate Units');
    d.TimeUnits=getChildPropertyValueFromDescription(tableData.children,'Time Units');


    doses=createDoses(gd,dataColumn,rateColumn,d,groups);


    groupBins=getGroupBinsFromDataset(gd,groups);
    for i=1:length(doses)
        set(doses(i),'Name',[tableData.externalDataName,'.',dataColumn,' (',groupBins(i).value,')']);
        set(doses(i),'UserData',struct('dataSource',dataSourceInfo,'group',groupBins(i)));
    end


    doseArgs=argList{4};
    stepStruct=struct;
    if isfield(doseArgs,'generateSamplesStep')
        stepStruct=doseArgs.generateSamplesStep;
    else
        doseArgs.generateSamplesStep=stepStruct;
    end

    allNames=fieldnames(stepStruct);
    if isempty(allNames)
        doseName='dose1';
    else
        doseName=findUniqueName(fieldnames(stepStruct),'dose');
    end

    doseArgs.generateSamplesStep.(doseName)=doses;
    argList{4}=doseArgs;


    entryName=setName;
    if~isempty(index)
        entryName=[entryName,'-',num2str(index)];
    end
    code=appendCode(code,['add(',varName,', ''elementwise'', ''',entryName,''', args.input.doses.generateSamplesStep.',doseName,');']);

end

function groupBins=getGroupBinsFromDataset(groupedData,groups)
    if isnumeric(groups)
        groups=arrayfun(@(g)num2str(g),groups,'UniformOutput',false);
    end

    dataInterface=SimBiology.internal.plotting.data.SBioDataInterface.createSBioDataInterface(groupedData,SimBiology.internal.plotting.data.DataSource.empty,[]);
    allGroupBins=dataInterface.getGroups();




    groupBins(numel(groups),1)=SimBiology.internal.plotting.categorization.binvalue.GroupBinValue;
    for i=1:numel(groups)
        for j=1:numel(allGroupBins)
            if allGroupBins(j).isEqual(groups{i})
                groupBins(i)=allGroupBins(j);
                break;
            end
        end
    end

    delete(dataInterface);

end

function code=generateSampleCodeArguments(psNames,allNames,name)


    if length(allNames)>1
        maxLength=length('samples');
        for i=1:length(psNames)
            if(length(psNames{i})>maxLength)
                maxLength=length(psNames{i});
            end
        end

        code=['args.output.',psNames{1},blanks(maxLength-length(psNames{1})),' = ',allNames{1},';'];

        for i=2:length(psNames)
            next=['args.output.',psNames{i},blanks(maxLength-length(psNames{i})),' = ',allNames{i},';'];
            code=appendCode(code,next);
        end

        code=appendCode(code,['args.output.samples',blanks(maxLength-length('samples')),' = ',name,';']);
    else
        code=['args.output.samples = ',name,';'];
    end

    code=appendCode(code,'');

end

function[tableData,paramCode,doseCount,argList]=parseTableDataForRepeatDoses(model,tableData,paramCode,doseCount,argList,support)

    for i=1:length(tableData)
        next=tableData(i);
        if strcmp(next.type,'repeatdose')
            dose=sbioselect(model,'Type','repeatdose','Name',next.pqn);
            value=dose.(next.property);
            argList=updateArgListForRepeatDose(argList,dose,support);
            if isnumeric(value)

                doseUnit=getDoseUnit(next.property);
                doseVar=['dose',num2str(doseCount)];
                valueVar=['value',num2str(doseCount)];
                unitVar=['unit',num2str(doseCount)];
                paramVar=['param',num2str(doseCount)];
                cleanupVar=['cleanupDose',num2str(doseCount)];
                newParam=[next.pqn,' ',next.property];
                pvpair=[doseVar,'.',next.property];


                allParams=model.Parameters;
                if~isempty(allParams)
                    allParamNames=get(allParams,{'Name'});
                    newParam=SimBiology.web.codegenerationutil('findUniqueName',allParamNames,newParam);
                end


                maxLength=max(length(cleanupVar),length(pvpair));
                doseVarPad=[doseVar,blanks(maxLength-length(doseVar))];
                valueVarPad=[valueVar,blanks(maxLength-length(valueVar))];
                unitVarPad=[unitVar,blanks(maxLength-length(unitVar))];
                paramVarPad=[paramVar,blanks(maxLength-length(paramVar))];
                cleanupVarPad=[cleanupVar,blanks(maxLength-length(cleanupVar))];

                code=[doseVarPad,' = sbioselect(model, ''Type'', ''repeatdose'', ''Name'', ''',next.pqn,''');'];
                code=appendCode(code,[valueVarPad,' = ',doseVar,'.',next.property,';']);

                if~isempty(doseUnit)
                    code=appendCode(code,[unitVarPad,' = ',doseVar,'.',doseUnit,';']);
                else
                    code=appendCode(code,[unitVarPad,' = '''';']);
                end

                code=appendCode(code,[paramVarPad,' = addparameter(model, ''',newParam,''', ''ValueUnits'', ',unitVar,');']);
                code=appendCode(code,[cleanupVarPad,' = onCleanup(@() restoreDose(',paramVar,', ',doseVar,', ''',next.property,''', ',valueVar,'));']);
                code=appendCode(code,[pvpair,' = ''',newParam,''';']);

                paramCode=appendCode(paramCode,code);

                tableData(i).name=[newParam];
                tableData(i).pqn=[newParam];
                tableData(i).value=value;

                doseCount=doseCount+1;
            else

                param=resolveparameter(dose,model,value);
                if~isempty(param)
                    tableData(i).modelValue=param.Value;
                    tableData(i).name=param.Name;
                    tableData(i).pqn=param.Name;
                    tableData(i).sessionID=param.SessionID;
                    tableData(i).type=param.Type;
                else
                    tableData(i).sessionID=-1;
                end
            end
        end
    end

end

function argList=updateArgListForRepeatDose(argList,dose,support)

    if support.output
        doseArg=argList{end-1};
    else
        doseArg=argList{end};
    end

    if~any(dose==doseArg.modelStep)
        doseArg.modelStep=[doseArg.modelStep,dose];
    end

    if support.output
        argList{end-1}.modelStep=doseArg.modelStep;
    else
        argList{end}.modelStep=doseArg.modelStep;
    end

end

function out=getDoseUnit(prop)

    switch lower(prop)
    case{'starttime','interval'}
        out='TimeUnits';
    case 'amount'
        out='AmountUnits';
    case 'rate'
        out='RateUnits';
    otherwise
        out='';
    end

end

function out=getChildPropertyValueFromName(children,property)

    out='';
    for i=1:length(children)
        if strcmp(children(i).name,property)
            out=children(i).value;
            break;
        end
    end

end

function out=getChildPropertyValueFromDescription(children,property)

    out='';
    for i=1:length(children)
        if strcmp(children(i).description,property)
            out=children(i).value;
            break;
        end
    end

end

function out=getChildPropertyTypeFromDescription(children,property)

    out='';
    for i=1:length(children)
        if strcmp(children(i).description,property)
            out=children(i).type;
            break;
        end
    end

end

function name=findUniqueName(allNames,nameIn)

    index=1;
    newName=[nameIn,num2str(index)];
    while any(strcmp(allNames,newName))
        index=index+1;
        newName=[nameIn,num2str(index)];
    end
    name=newName;

end

function covMatrix=generateCovariateMatrix(names,covInfo)

    covMatrix=SimBiology.web.codegenerationutil('generateCovarianceMatrix',names,covInfo);

end

function value=getNumericValue(value)

    if~isnumeric(value)
        value=str2double(value);
    end

end

function value=getDistributionValue(value)

    if isnumeric(value)
        value=num2str(value);
    end

end

function content=readTemplate(name)

    content=SimBiology.web.codegenerationutil('readTemplate',name);

end

function code=appendCode(code,newCode)

    code=SimBiology.web.codegenerationutil('appendCode',code,newCode);

end

function code=createCommaSeparatedQuotedList(list)

    code=SimBiology.web.codegenerationutil('createCommaSeparatedQuotedList',list);

end

function out=getValuePropertyForState(state)

    out=SimBiology.web.codegenerationutil('getValuePropertyForState',state);
end
