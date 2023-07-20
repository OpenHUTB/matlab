function[stepCall,stepCode,stepCleanup]=fitcodegenerator(step,steps,model,argList,support)











    switch(step.type)
    case 'Group Simulation'
        [stepCall,stepCode,stepCleanup]=generateGroupSimulationCode(step,steps,model,argList,support);
    case 'Fit'
        if any(strcmp(step.estimationMethod.estimationFunction,{'nlmefit','nlmefitsa'}))
            [stepCall,stepCode,stepCleanup]=generateFitMixedCode(step,steps,model,argList,support);
        else
            [stepCall,stepCode,stepCleanup]=generateFitCode(step,steps,model,argList,support);
        end
    end

end

function[stepCall,stepCode,stepCleanup]=generateGroupSimulationCode(step,steps,model,argList,support)


    modelStep=getStepByType(steps,'Model');
    dataStep=getStepByType(steps,'DataFit');
    variantDoseStep=getStepByType(steps,'Variant and Dose Setup');
    observableStep=getStepByType(steps,'Calculate Observables');


    stepCall='% Run simulation.';
    stepCall=appendCode(stepCall,'args = runSimulation(args);');


    stepCode=readTemplate('runGroupSimulation.txt');
    [stepCode,dataObj]=populateFitDataColumnNames(dataStep,stepCode,argList);%#ok<ASGLU> 
    [stepCode,hasVariants]=populateVariants(step,dataStep,variantDoseStep,stepCode,support);
    [stepCode,hasDoses]=populateDoses(step,dataStep,variantDoseStep,modelStep,stepCode,model);%#ok<ASGLU> 
    stepCode=populateSimulationCode(step,dataStep,modelStep,observableStep,stepCode,model,hasVariants);


    stepCode=strrep(stepCode,'$(TURN_OFF_OBSERVABLE_CODE)','$(REMOVE)');
    stepCode=strrep(stepCode,'$(TURN_ON_OBSERVABLE_CODE)','$(REMOVE)');


    stepCleanup={};
    stepCleanup{end+1}=readTemplate('restoreActiveConfigset.txt');


end

function stepCode=populateSimulationCode(step,dataStep,modelStep,observableStep,stepCode,model,hasVariants)


    data=dataStep.fitDefinitions;
    responses={};

    if iscell(data)
        data=[data{:}];
    end


    data=data([data.use]);

    for i=1:length(data)
        switch(data(i).classification)
        case 'response'
            sessionID=data(i).children(2).sessionID;
            quantity=sbioselect(model,'SessionID',sessionID);
            if~isempty(quantity)
                responses{end+1}=quantity.PartiallyQualifiedNameReally;
            end
        end
    end


    if modelStep.statesToLogUseConfigset
        cs=getconfigset(model,'default');
        statesToLog=cs.RunTimeOptions.StatesToLog;
        for i=1:numel(statesToLog)
            responses{end+1}=statesToLog(i).PartiallyQualifiedNameReally;
        end
    else
        statesToLog=modelStep.statesToLog;
        if iscell(statesToLog)
            statesToLog=[statesToLog{:}];
        end

        for i=1:length(statesToLog)
            next=statesToLog(i);
            if logical(next.use)&&(next.sessionID~=-1)
                sessionID=next.sessionID;
                quantity=sbioselect(model,'SessionID',sessionID);
                if~isempty(quantity)
                    responses{end+1}=quantity.PartiallyQualifiedNameReally;
                end
            end
        end
    end


    if observableStep.sectionEnabled&&~isempty(observableStep.statistics)
        tableData=observableStep.statistics;
        if iscell(tableData)
            tableData=[tableData{:}];
        end


        if~isempty(tableData)
            tableData=tableData([tableData.use]);
            tableData=tableData(cellfun('isempty',{tableData.matlabError}));
        end


        for i=1:numel(tableData)
            responses{end+1}=tableData(i).name;
        end
    end

    responses=unique(responses,'stable');
    cmd=['{',createCommaSeparatedQuotedList(responses),'};'];
    stepCode=strrep(stepCode,'$(RESPONSES)',cmd);


    pvpairs={};
    if hasVariants
        pvpairs{end+1}='Variants';
        pvpairs{end+1}='variantsForSim';
    end

    simulationTime=step.stopTimeSettings;
    if(~simulationTime.dataTimesIncluded)
        pvpairs{end+1}='UseOutputTimes';
        pvpairs{end+1}='false';
    end

    if(simulationTime.stopTimeIncluded)
        if(simulationTime.useStopTime)
            pvpairs{end+1}='StopTime';
            pvpairs{end+1}=num2str(simulationTime.stopTime);
        elseif(simulationTime.useDataMax)
            pvpairs{end+1}='StopTime';
            pvpairs{end+1}='''maxData''';
        end
    else
        pvpairs{end+1}='StopTime';
        pvpairs{end+1}='''none''';
    end

    if step.runInParallel
        pvpairs{end+1}='UseParallel';
        pvpairs{end+1}='true';
    end

    if~modelStep.accelerate
        pvpairs{end+1}='AutoAccelerate';
        pvpairs{end+1}='false';
    end

    cmd='';
    for i=1:2:numel(pvpairs)
        cmd=[cmd,', ''',pvpairs{i},''', ',pvpairs{i+1}];
    end

    if~isempty(pvpairs)
        stepCode=strrep(stepCode,'$(PVPAIRS)',cmd);
    else
        stepCode=strrep(stepCode,'$(PVPAIRS)','$(REMOVE)');
    end

end

function stepCode=populateSimulationCode2(step,dataStep,stepCode,model,hasVariants,hasDoses)


    data=dataStep.fitDefinitions;
    responses={};
    group='';
    time='';

    if iscell(data)
        data=[data{:}];
    end


    data=data([data.use]);

    for i=1:length(data)
        switch(data(i).classification)
        case 'response'
            sessionID=data(i).children(2).sessionID;
            quantity=sbioselect(model,'SessionID',sessionID);
            if~isempty(quantity)
                responses{end+1}=quantity.PartiallyQualifiedNameReally;
            end
        case 'group'
            group=data(i).property;
        case 'independent'
            time=data(i).property;
        end
    end

    cmd=['{',createCommaSeparatedQuotedList(responses),'};'];
    stepCode=strrep(stepCode,'$(RESPONSES)',cmd);


    if(hasVariants&&hasDoses)
        cmd='samples = SimBiology.Scenarios(''variants'', variantsForSim);';
        cmd=appendCode(cmd,'samples.add(''elementwise'', ''doses'', dosesForSim);');
    elseif hasVariants
        cmd='samples = SimBiology.Scenarios(''variants'', variantsForSim);';
    elseif hasDoses
        cmd='samples = SimBiology.Scenarios(''doses'', dosesForSim);';
    end

    cmd=appendCode(cmd,'sf = createSimFunction(model, samples, responseNames, []);');


    simulationTime=step.stopTimeSettings;
    includeDataTimes=simulationTime.dataTimesIncluded;
    includeStopTime=simulationTime.stopTimeIncluded;
    useStopTime=simulationTime.useStopTime;
    simToMaxTime=includeStopTime&&~useStopTime;
    stopTime=simulationTime.stopTime;

    if isnumeric(stopTime)
        stopTime=num2str(stopTime);
    end

    cmd=appendCode(cmd,'');
    cmd=appendCode(cmd,'% Define stop time and output times.');
    if(includeDataTimes||simToMaxTime)
        if isempty(group)

            cmd=appendCode(cmd,['outputTimes = data.',time,';']);
        else
            cmd=appendCode(cmd,['groupIDs    = findgroups(data.',group,');']);
            cmd=appendCode(cmd,['outputTimes = splitapply(@(x){x}, data.',time,', groupIDs);']);
        end
    end

    if(includeStopTime)
        if(useStopTime)

            cmd=appendCode(cmd,['stopTime    = ',stopTime,';']);
        else

            cmd=appendCode(cmd,'stopTime    = cellfun(@max, outputTimes);');
        end
    else
        cmd=appendCode(cmd,'stopTime    = [];');
    end

    if~includeDataTimes
        cmd=appendCode(cmd,'outputTimes = [];');
    end

    stepCode=strrep(stepCode,'$(SCENARIOS)',cmd);


    if step.runInParallel
        cmd='results = sf(samples, stopTime, [], outputTimes, ''UseParallel'', true);';
    else
        cmd='results = sf(samples, stopTime, [], outputTimes);';
    end
    stepCode=strrep(stepCode,'$(SIMULATION)',cmd);

end

function[stepCall,stepCode,stepCleanup]=generateFitCode(step,steps,model,argList,support)


    modelStep=getStepByType(steps,'Model');
    dataStep=getStepByType(steps,'DataFit');
    variantDoseStep=getStepByType(steps,'Variant and Dose Setup');


    stepCall='% Run fit.';
    stepCall=appendCode(stepCall,'args = runFit(args);');


    stepCode=readTemplate('runFit.txt');
    [stepCode,dataObj]=populateFitDataColumnNames(dataStep,stepCode,argList);%#ok<ASGLU> 
    stepCode=populateFitInitialEstimates(step,stepCode);
    [stepCode,hasVariants]=populateVariants(step,dataStep,variantDoseStep,stepCode,support);
    stepCode=populateDoses(step,dataStep,variantDoseStep,modelStep,stepCode,model);
    stepCode=populateResponses(dataStep,stepCode,model);
    stepCode=populateWeight(step,stepCode);
    stepCode=populateFitAlgorithmSettings(step,stepCode);
    stepCode=populateFitProblem(step,stepCode,hasVariants);
    [stepCode,cleanup]=populateObservables(step,steps,stepCode,model);


    stepCleanup={};
    stepCleanup{end+1}=readTemplate('restoreActiveConfigset.txt');

    if~isempty(cleanup)
        for i=1:length(cleanup)
            stepCleanup{end+1}=cleanup{i};%#ok<*AGROW>
        end
    end

end

function[stepCall,stepCode,stepCleanup]=generateFitMixedCode(step,steps,model,argList,support)


    modelStep=getStepByType(steps,'Model');
    dataStep=getStepByType(steps,'DataFit');
    variantDoseStep=getStepByType(steps,'Variant and Dose Setup');


    stepCall='% Run fit.';
    stepCall=appendCode(stepCall,'args = runFit(args);');


    stepCode=readTemplate('runFitMixed.txt');
    [stepCode,dataObj]=populateFitDataColumnNames(dataStep,stepCode,argList);%#ok<ASGLU> 
    stepCode=populateCovariateModel(step,stepCode);
    [stepCode,hasVariants]=populateVariants(step,dataStep,variantDoseStep,stepCode,support);
    stepCode=populateDoses(step,dataStep,variantDoseStep,modelStep,stepCode,model);
    stepCode=populateResponses(dataStep,stepCode,model);
    stepCode=populateFitMixedAlgorithmSettings(step,stepCode);
    stepCode=populateFitProblem(step,stepCode,hasVariants);
    [stepCode,cleanup]=populateObservables(step,steps,stepCode,model);


    stepCleanup={};
    stepCleanup{end+1}=readTemplate('restoreActiveConfigset.txt');

    if~isempty(cleanup)
        for i=1:length(cleanup)
            stepCleanup{end+1}=cleanup{i};
        end
    end

end

function[stepCode,dataObj]=populateFitDataColumnNames(dataStep,stepCode,argList)

    data=dataStep.fitDefinitions;
    group='';
    time='';

    if iscell(data)
        data=[data{:}];
    end


    data=data([data.use]);

    for i=1:length(data)
        column=data(i).property;
        classification=data(i).classification;

        switch(classification)
        case 'group'
            group=column;
        case 'independent'
            time=column;
        end
    end

    stepCode=strrep(stepCode,'$(GROUP_COLUMN)',['''',group,'''']);
    stepCode=strrep(stepCode,'$(TIME_COLUMN)',['''',time,'''']);

    dataObj=groupedData(argList{3});
    dataObj.Properties.GroupVariableName=group;
    dataObj.Properties.IndependentVariableName=time;

end

function stepCode=populateFitInitialEstimates(step,stepCode)

    info=step.estimatedParameterInfo;
    expressions={};
    values={};


    pooled=step.pooled;
    hasCategoryVariable=false;
    if~pooled
        for i=1:length(info)
            category=deblank(info(i).categoryVariable);
            if~isempty(category)
                hasCategoryVariable=true;
                break;
            end
        end
    end

    maxLength=length('InitialValue');
    if(hasCategoryVariable)
        maxLength=length('CategoryVariableName');
    end

    for i=1:length(info)
        expression=info(i).expression;
        if strcmp(expression,'none')
            expressions{i}=info(i).name;
        else
            expressions{i}=[expression,'(',info(i).name,')'];
        end


        pad=blanks(maxLength-length('InitialValue'));
        value=info(i).children(1).value;
        cmd=['estimatedInfoObj(',num2str(i),').InitialValue',pad,' = ',num2str(value),';'];
        values{end+1}=cmd;


        lower=info(i).children(2).value;
        upper=info(i).children(3).value;

        if~isempty(lower)&&~isempty(upper)
            pad=blanks(maxLength-length('Bounds'));
            value=['[',num2str(lower),' ',num2str(upper),']'];
            cmd=['estimatedInfoObj(',num2str(i),').Bounds',pad,' = ',num2str(value),';'];
            values{end+1}=cmd;
        end

        category=deblank(info(i).categoryVariable);
        if strcmp(category,'<POOLED>')
            category='<None>';
        end

        if~isempty(category)&&~pooled
            pad=blanks(maxLength-length('CategoryVariableName'));
            cmd=['estimatedInfoObj(',num2str(i),').CategoryVariableName',pad,' = ''',category,''';'];
            values{end+1}=cmd;
        end
    end


    command=createCommaSeparatedQuotedList(expressions);
    stepCode=strrep(stepCode,'$(ESTIMATE_EXPRESSIONS)',['{',command,'}']);


    if length(values)>=1
        argumentCode=values{1};

        for i=2:length(values)
            argumentCode=appendCode(argumentCode,values{i});
        end
    end

    if~isempty(values)
        stepCode=strrep(stepCode,'$(ESTIMATE_INITIAL_VALUES)',argumentCode);
    else
        stepCode=strrep(stepCode,'$(ESTIMATE_INITIAL_VALUES)','$(REMOVE)');
    end

end

function stepCode=populateCovariateModel(step,stepCode)

    info=step.estimatedParameterInfo;
    expressions={};
    thetas={};
    covariates=step.covariates;

    for i=1:length(info)


        expression=info(i).expression;

        for j=1:length(covariates)
            name=['t',covariates(j).name];
            value=covariates(j).value;
            expression=regexprep(expression,name,value);
        end


        expressions{i}=[info(i).name,' = ',expression];

        children=info(i).children;
        for j=4:length(children)
            thetas{end+1}=['initialEstimate.',children(j).name,' = ',num2str(children(j).value),';'];
        end
    end


    command=createCommaSeparatedQuotedList(expressions);
    stepCode=strrep(stepCode,'$(COVARIATE_MODEL_EXPRESSION)',['{',command,'}']);


    if length(thetas)>=1
        argumentCode=thetas{1};

        for i=2:length(thetas)
            argumentCode=appendCode(argumentCode,thetas{i});
        end
    end

    if~isempty(thetas)
        stepCode=strrep(stepCode,'$(INITIAL_ESTIMATE_STRUCT)',argumentCode);
    else
        stepCode=strrep(stepCode,'$(INITIAL_ESTIMATE_STRUCT)','$(REMOVE)');
    end

end

function[stepCode,hasVariants]=populateVariants(step,dataStep,variantDoseStep,stepCode,support)

    argName='variantsForFit';
    if strcmp(step.type,'Group Simulation')
        argName='variantsForSim';
    end

    hasVariants=true;


    data=dataStep.fitDefinitions;
    if iscell(data)
        data=[data{:}];
    end


    data=data([data.use]);
    data=data(strcmp('variant from data',{data.classification}));
    dataColumns={data.property};


    groupDefinitionTableData=variantDoseStep.groupDefinitions;

    if isempty(groupDefinitionTableData)
        hasVariants=false;
        variantCode='$(REMOVE)';
        stepCode=strrep(stepCode,'$(VARIANTS)',variantCode);
        return;
    end


    fields=fieldnames(groupDefinitionTableData);
    variants=fields(startsWith(fields,'variants'));
    baselineVariants=getHeaderByType(variantDoseStep,'variant','base');
    groupSpecificVariants=getHeaderByType(variantDoseStep,'variant','groupSpecific');
    dataVariants=getHeaderByType(variantDoseStep,'variant','data');


    variantsToRemove={};
    for i=1:numel(groupSpecificVariants)
        variantList={groupDefinitionTableData.(groupSpecificVariants{i})};
        variantList=unique(variantList);

        if isempty(variantList)
            variantsToRemove{end+1}=groupSpecificVariants{i};
        elseif numel(variantList)==1&&isempty(variantList{1})
            variantsToRemove{end+1}=groupSpecificVariants{i};
        end
    end

    for i=1:numel(variantsToRemove)
        idx=strcmp(variantsToRemove{i},variants);
        variants(idx)=[];
        idx=strcmp(variantsToRemove{i},groupSpecificVariants);
        groupSpecificVariants(idx)=[];
    end


    groupSpecificVariantNames={};
    for i=1:numel(groupSpecificVariants)
        next={groupDefinitionTableData.(groupSpecificVariants{i})};
        groupSpecificVariantNames=horzcat(groupSpecificVariantNames,next);
        groupSpecificVariantNames=unique(groupSpecificVariantNames);
    end

    groupSpecificLookup=containers.Map('KeyType','char','ValueType','char');
    groupSpecificCode='';
    count=1;
    for i=1:numel(groupSpecificVariantNames)
        variantName=groupSpecificVariantNames{i};

        if~isempty(variantName)
            variableName=['v',num2str(count)];
            groupSpecificLookup(variantName)=variableName;

            if count==1
                groupSpecificCode='% Get the variants needed from the model.';
            end

            groupSpecificCode=appendCode(groupSpecificCode,[variableName,'  = sbioselect(getvariant(model), ''Name'', ''',variantName,''');']);
            count=count+1;
        end
    end

    if~isempty(groupSpecificCode)
        groupSpecificCode=appendCode(groupSpecificCode,'');
    end


    variantCode='';
    newVariantList={};
    variantLookup=containers.Map('KeyType','char','ValueType','char');

    if(support.hasModelStepSliders)
        variantName='sliders';
        cmd=['sliders = sbioselect(variants, ''Name'', ''',variantName,''');'];

        if isempty(variantCode)
            variantCode='% Get the slider variant.';
        else
            variantCode=appendCode(variantCode,'% Get the slider variant.');
        end

        variantCode=appendCode(variantCode,cmd);
        variantCode=appendCode(variantCode,'');
    end

    for i=1:numel(variants)
        next=variants{i};
        newVariantList{end+1}=['variants',num2str(i)];
        variantLookup(next)=['variants',num2str(i)];

        if any(strcmp(next,baselineVariants))
            variantName=groupDefinitionTableData(1).(next);
            cmd=['variants',num2str(i),' = sbioselect(variants, ''Name'', ''',variantName,''');'];

            if isempty(variantCode)
                variantCode='% Get the baseline variant.';
            else
                variantCode=appendCode(variantCode,'% Get the baseline variant.');
            end

            variantCode=appendCode(variantCode,cmd);
            variantCode=appendCode(variantCode,'');
        elseif any(strcmp(next,groupSpecificVariants))
            variantList={groupDefinitionTableData.(next)};
            variantNames=cell(1,numel(variantList));
            for j=1:numel(variantList)
                if isempty(variantList{j})
                    variantNames{j}='';
                else
                    variantNames{j}=groupSpecificLookup(variantList{j});
                end
            end

            variantList=createSemicolonSeparatedList(variantNames);
            cmd=['variants',num2str(i),' = {',variantList,'};'];

            if isempty(variantCode)
                variantCode='% Create the group specific variant array.';
            else
                variantCode=appendCode(variantCode,'% Create the group specific variant array.');
            end

            variantCode=appendCode(variantCode,cmd);
            variantCode=appendCode(variantCode,'');
        elseif any(strcmp(next,dataVariants))
            columnName=groupDefinitionTableData(1).(next);
            dataIndex=strcmp(columnName,dataColumns);
            dataInfo=data(dataIndex);
            component=dataInfo.children(2);
            name=component.value;
            type=component.type;
            unitConversion=dataInfo.children(3).value;
            if strcmp(unitConversion,'auto')
                unitConversion='''auto''';
            end

            cmd=['variants',num2str(i),' = createVariants(groupedDataObj, ''',columnName,''', ''Names'', ''',name,''', ''Types'', ''',type,''', ''UnitConversion'', ',unitConversion,');'];

            if isempty(variantCode)
                variantCode='% Create the data variant.';
            else
                variantCode=appendCode(variantCode,'% Create the data variant.');
            end

            variantCode=appendCode(variantCode,cmd);
            variantCode=appendCode(variantCode,'');


            dataColumns(dataIndex)=[];
            data(dataIndex)=[];
        end
    end


    if~isempty(groupSpecificVariants)||~isempty(dataVariants)
        if~isempty(groupSpecificVariants)
            repmatName=variantLookup(groupSpecificVariants{1});
        else
            repmatName=variantLookup(dataVariants{1});
        end

        variantCode=appendCode(variantCode,'% Build table of variants.');

        for i=1:numel(variants)
            next=variants{i};
            if any(strcmp(next,baselineVariants))
                cmd=['variants',num2str(i),'   = num2cell(repmat(variants',num2str(i),', numel(',repmatName,'), 1));'];
                variantCode=appendCode(variantCode,cmd);
            elseif any(strcmp(next,dataVariants))
                cmd=['variants',num2str(i),'   = num2cell(variants',num2str(i),');'];
                variantCode=appendCode(variantCode,cmd);
            end
        end

        if(support.hasModelStepSliders)
            cmd=['sliders     = num2cell(repmat(sliders, numel(',repmatName,'), 1));'];
            variantCode=appendCode(variantCode,cmd);
        end

        newVariantList=fliplr(newVariantList);
        if(support.hasModelStepSliders)
            newVariantList{end+1}='sliders';
        end

        variantList=createCommaSeparatedList(newVariantList);
        if numel(newVariantList)==1
            cmd=[argName,' = ',variantList,';'];
        else
            cmd=['variantList = [',variantList,'];'];
        end
        variantCode=appendCode(variantCode,cmd);

        if~isempty(groupSpecificCode)
            variantCode=appendCode(groupSpecificCode,variantCode);
        end


        if numel(newVariantList)>1
            variantCode=appendCode(variantCode,'');
            variantCode=appendCode(variantCode,'% Convert cell matrix to a cell with one column.');
            variantCode=appendCode(variantCode,[argName,' = cell(size(variantList, 1), 1);']);
            variantCode=appendCode(variantCode,['for i = 1:numel(',argName,')']);
            variantCode=appendCode(variantCode,'    next              = variantList(i, :);');
            variantCode=appendCode(variantCode,['    ',argName,'{i} = [next{:}];']);
            variantCode=appendCode(variantCode,'end');
        end
    elseif~isempty(baselineVariants)||support.hasModelStepSliders


        if isempty(variantCode)
            variantCode='% Build array of variants.';
        else
            variantCode=appendCode(variantCode,'% Build array of variants.');
        end

        newVariantList=fliplr(newVariantList);
        if(support.hasModelStepSliders)
            newVariantList{end+1}='sliders';
        end

        variantList=createCommaSeparatedList(newVariantList);

        if numel(newVariantList)==1
            cmd=[argName,' = ',variantList,';'];
        else
            cmd=[argName,' = [',variantList,'];'];
        end
        variantCode=appendCode(variantCode,cmd);
    else
        hasVariants=false;
        variantCode='$(REMOVE)';
    end

    stepCode=strrep(stepCode,'$(VARIANTS)',variantCode);

end

function[stepCode,hasDoses]=populateDoses(step,dataStep,variantDoseStep,modelStep,stepCode,model)

    argName='dosesForFit';
    if strcmp(step.type,'Group Simulation')
        argName='dosesForSim';
    end

    hasDoses=true;



    modelStepDoses=modelStep.doses;
    usedModelStepDose={};
    hasDataDose=false;

    for i=1:numel(modelStepDoses)
        if iscell(modelStepDoses)
            next=modelStepDoses{i};
        else
            next=modelStepDoses(i);
        end

        if next.use
            usedModelStepDose{end+1}=next;

            if~hasDataDose
                hasDataDose=isfield(next,'groupColumn');
            end
        end
    end


    data=dataStep.fitDefinitions;
    if iscell(data)
        data=[data{:}];
    end


    data=data([data.use]);
    data=data(strcmp('dose from data',{data.classification}));
    dataColumns={data.property};


    groupDefinitionTableData=variantDoseStep.groupDefinitions;

    if isempty(groupDefinitionTableData)
        hasDoses=false;
        doseCode='$(REMOVE)';
        stepCode=strrep(stepCode,'$(DOSES)',doseCode);
        return;
    end


    fields=fieldnames(groupDefinitionTableData);
    doses=fields(startsWith(fields,'doses'));
    baselineDoses=getHeaderByType(variantDoseStep,'dose','base');
    groupSpecificDoses=getHeaderByType(variantDoseStep,'dose','groupSpecific');
    dataDoses=getHeaderByType(variantDoseStep,'dose','data');


    dosesToRemove={};
    for i=1:numel(groupSpecificDoses)
        doseList={groupDefinitionTableData.(groupSpecificDoses{i})};
        doseList=unique(doseList);

        if isempty(doseList)
            dosesToRemove{end+1}=groupSpecificDoses{i};
        elseif numel(doseList)==1&&isempty(doseList{1})
            dosesToRemove{end+1}=groupSpecificDoses{i};
        end
    end

    for i=1:numel(dosesToRemove)
        idx=strcmp(dosesToRemove{i},doses);
        doses(idx)=[];
        idx=strcmp(dosesToRemove{i},groupSpecificDoses);
        groupSpecificDoses(idx)=[];
    end


    groupSpecificDoseNames={};
    for i=1:numel(groupSpecificDoses)
        next={groupDefinitionTableData.(groupSpecificDoses{i})};
        groupSpecificDoseNames=horzcat(groupSpecificDoseNames,next);
        groupSpecificDoseNames=unique(groupSpecificDoseNames);
    end

    groupSpecificLookup=containers.Map('KeyType','char','ValueType','char');
    groupSpecificCode='';
    count=1;
    for i=1:numel(groupSpecificDoseNames)
        doseName=groupSpecificDoseNames{i};

        if~isempty(doseName)
            variableName=['d',num2str(count)];
            groupSpecificLookup(doseName)=variableName;

            if count==1
                groupSpecificCode='% Get the doses needed from the model.';
            end

            groupSpecificCode=appendCode(groupSpecificCode,[variableName,'  = sbioselect(getdose(model), ''Name'', ''',doseName,''');']);
            count=count+1;
        end
    end

    if~isempty(groupSpecificCode)
        groupSpecificCode=appendCode(groupSpecificCode,'');
    end


    doseCode='';
    newDoseList={};
    baseLineCount=1;
    doseLookup=containers.Map('KeyType','char','ValueType','char');

    for i=1:numel(doses)
        next=doses{i};
        newDoseList{end+1}=['doses',num2str(i)];
        doseLookup(next)=['doses',num2str(i)];
        if any(strcmp(next,baselineDoses))
            if hasDataDose
                doseInfo=usedModelStepDose{baseLineCount};
                if isfield(doseInfo,'dataName')
                    comment='% Get the baseline dose generated from data.';
                    cmd=['doses',num2str(i),' = doses(',num2str(baseLineCount),');'];
                else
                    comment='% Get the baseline dose.';
                    cmd=['doses',num2str(i),' = doses(',num2str(baseLineCount),');'];
                end
                baseLineCount=baseLineCount+1;
            else
                doseName=groupDefinitionTableData(1).(next);
                cmd=['doses',num2str(i),' = sbioselect(doses, ''Name'', ''',doseName,''');'];
                comment='% Get the baseline dose.';
            end

            if isempty(doseCode)
                doseCode=comment;
            else
                doseCode=appendCode(doseCode,comment);
            end

            doseCode=appendCode(doseCode,cmd);
            doseCode=appendCode(doseCode,'');
        elseif any(strcmp(next,groupSpecificDoses))
            doseList={groupDefinitionTableData.(next)};
            doseNames=cell(1,numel(doseList));
            for j=1:numel(doseList)
                if isempty(doseList{j})
                    doseNames{j}='';
                else
                    doseNames{j}=groupSpecificLookup(doseList{j});
                end
            end

            doseList=createSemicolonSeparatedList(doseNames);
            cmd=['doses',num2str(i),' = {',doseList,'};'];

            if isempty(doseCode)
                doseCode='% Create the group specific dose array.';
            else
                doseCode=appendCode(doseCode,'% Create the group specific dose array.');
            end

            doseCode=appendCode(doseCode,cmd);
            doseCode=appendCode(doseCode,'');
        elseif any(strcmp(next,dataDoses))
            columnName=groupDefinitionTableData(1).(next);
            dataIndex=strcmp(columnName,dataColumns);
            dataInfo=data(dataIndex);

            rateType=dataInfo.children(3).type;
            quantity=sbioselect(model,'Type','species','SessionID',dataInfo.children(2).sessionID);
            durationParameter=sbioselect(model,'Type','parameter','SessionID',dataInfo.children(3).sessionID);
            lagParameter=sbioselect(model,'Type','parameter','SessionID',dataInfo.children(4).sessionID);
            rateColumn='';
            targetName='';
            durationParameterName='';
            lagParameterName='';

            if~isempty(quantity)
                targetName=quantity.PartiallyQualifiedNameReally;
            end
            if~isempty(durationParameter)
                durationParameterName=durationParameter.PartiallyQualifiedNameReally;
            end
            if~isempty(lagParameter)
                lagParameterName=lagParameter.PartiallyQualifiedNameReally;
            end

            if strcmp(rateType,'rawdata')
                rateColumn=dataInfo.children(3).value;
            end

            if isempty(doseCode)
                doseCode='% Create the data dose.';
            else
                doseCode=appendCode(doseCode,'% Create the data dose.');
            end

            if strcmp(rateType,'parameter')
                doseCode=appendCode(doseCode,['doses',num2str(i),'                       = sbiodose(''',columnName,''');']);
                doseCode=appendCode(doseCode,['doses',num2str(i),'.TargetName            = ''',targetName,''';']);
                doseCode=appendCode(doseCode,['doses',num2str(i),'.DurationParameterName = ''',durationParameterName,''';']);
                doseCode=appendCode(doseCode,['doses',num2str(i),'.LagParameterName      = ''',lagParameterName,''';']);
            else
                doseCode=appendCode(doseCode,['doses',num2str(i),'                  = sbiodose(''',columnName,''');']);
                doseCode=appendCode(doseCode,['doses',num2str(i),'.TargetName       = ''',targetName,''';']);
                doseCode=appendCode(doseCode,['doses',num2str(i),'.LagParameterName = ''',lagParameterName,''';']);
            end

            doseCode=appendCode(doseCode,['doses',num2str(i),'                  = createDoses(groupedDataObj, ''',columnName,''', ''',rateColumn,''', doses',num2str(i),');']);
            doseCode=appendCode(doseCode,'');


            dataColumns(dataIndex)=[];
            data(dataIndex)=[];
        end
    end


    if~isempty(groupSpecificDoses)||~isempty(dataDoses)
        if~isempty(groupSpecificDoses)
            repmatName=doseLookup(groupSpecificDoses{1});
        else
            repmatName=doseLookup(dataDoses{1});
        end

        doseCode=appendCode(doseCode,'% Build table of doses.');

        for i=1:numel(doses)
            next=doses{i};
            if any(strcmp(next,baselineDoses))
                cmd=['doses',num2str(i),'   = num2cell(repmat(doses',num2str(i),', numel(',repmatName,'), 1));'];
                doseCode=appendCode(doseCode,cmd);
            elseif any(strcmp(next,dataDoses))
                cmd=['doses',num2str(i),'   = num2cell(doses',num2str(i),');'];
                doseCode=appendCode(doseCode,cmd);
            end
        end

        doseList=createCommaSeparatedList(newDoseList);
        if numel(newDoseList)==1
            cmd=[argName,' = ',doseList,';'];
        else
            cmd=['doseList = [',doseList,'];'];
        end
        doseCode=appendCode(doseCode,cmd);

        if~isempty(groupSpecificCode)
            doseCode=appendCode(groupSpecificCode,doseCode);
        end

        if numel(newDoseList)>1
            doseCode=appendCode(doseCode,'');
            doseCode=appendCode(doseCode,'% Convert cell matrix to a cell with one column.');
            doseCode=appendCode(doseCode,[argName,' = cell(size(doseList, 1), 1);']);
            doseCode=appendCode(doseCode,['for i = 1:numel(',argName,')']);
            doseCode=appendCode(doseCode,'    next           = doseList(i, :);');
            doseCode=appendCode(doseCode,['    ',argName,'{i} = [next{:}];']);
            doseCode=appendCode(doseCode,'end');
        end
    else


        if isempty(doseCode)
            doseCode='% Build array of doses.';
        else
            doseCode=appendCode(doseCode,'% Build array of doses.');
        end

        doseList=createCommaSeparatedList(newDoseList);

        if numel(newDoseList)==1
            cmd=[argName,' = ',doseList,';'];
        else
            cmd=[argName,' = [',doseList,'];'];
        end

        if isempty(newDoseList)
            hasDoses=false;
        end

        doseCode=appendCode(doseCode,cmd);
    end

    stepCode=strrep(stepCode,'$(DOSES)',doseCode);

end

function out=getHeaderByType(variantDoseStep,objType,columnType)

    out={};
    headers=variantDoseStep.groupDefinitionsHeader;
    if~iscell(headers)
        headers={headers};
    end

    for i=1:numel(headers)
        if startsWith(headers{i}.property,objType)&&strcmp(headers{i}.columnType,columnType)
            out{end+1}=headers{i}.property;
        end
    end

end

function stepCode=populateResponses(dataStep,stepCode,model)

    data=dataStep.fitDefinitions;
    responseColumns={};
    responseComponents={};

    if iscell(data)
        data=[data{:}];
    end


    data=data([data.use]);

    for i=1:length(data)
        responseColumn=data(i).property;
        classification=data(i).classification;

        switch(classification)
        case 'response'
            sessionID=data(i).children(2).sessionID;
            quantity=sbioselect(model,'SessionID',sessionID);
            if~isempty(quantity)
                responseColumns{end+1}=responseColumn;
                responseComponents{end+1}=quantity.PartiallyQualifiedNameReally;
            end
        end
    end

    expressions=cell(1,length(responseColumns));
    for i=1:length(responseColumns)
        column=responseColumns{i};
        component=responseComponents{i};
        expressions{i}=[component,' = ',column];
    end

    cmd=['{',createCommaSeparatedQuotedList(expressions),'}'];
    stepCode=strrep(stepCode,'$(RESPONSE_MAP)',cmd);

end

function stepCode=populateWeight(step,stepCode)

    errorModelType=step.errorModel.optimErrorModelOption;
    hasWeights=strcmp(errorModelType,'weights');

    if hasWeights
        cmd='% Extract data columns into separate variables for the weight expression';
        cmd=appendCode(cmd,'% evaluation.');
        cmd=appendCode(cmd,'headings = data.Properties.VariableNames;');
        cmd=appendCode(cmd,'for i=1:length(headings)');
        cmd=appendCode(cmd,'    next = headings{i};');
        cmd=appendCode(cmd,'    eval([next '' = data. '' next '';'']);');
        cmd=appendCode(cmd,'end');
        stepCode=strrep(stepCode,'$(WEIGHTS)',cmd);
    else
        stepCode=strrep(stepCode,'$(WEIGHTS)','$(REMOVE)');
    end

end

function stepCode=populateFitProblem(step,stepCode,hasVariants)

    estimationMethod=step.estimationMethod.estimationFunction;
    isMixed=startsWith(estimationMethod,'nlmefit');
    progressPlot=step.algorithmSettings.showProgress;
    errorModelType=step.errorModel.optimErrorModelOption;
    hasErrorModel=true;

    switch(errorModelType)
    case 'common'
        errorModel=['''',step.errorModel.optimErrorModel,''''];
    case 'separate'
        errorModels={step.errorModel.optimErrorModelForEachResponse.errorModel};
        errorModel=['{',createCommaSeparatedQuotedList(errorModels),'}'];
    case 'weights'
        hasErrorModel=false;
        weights=step.errorModel.optimErrorModelWeights;
    end

    runInParallel='false';
    if isfield(step,'runInParallel')&&step.runInParallel
        runInParallel='true';
    end

    pooled='''auto''';
    if isfield(step,'pooled')&&step.pooled
        pooled='true';
    end

    cmd='';
    if~isMixed
        if(hasErrorModel)
            cmd=['f.ErrorModel   = ',errorModel,';'];
        else
            cmd=['f.Weights      = ',weights,';'];
        end
    end

    if hasVariants
        next='f.Variants     = variantsForFit;';
        if isempty(cmd)
            cmd=next;
        else
            cmd=appendCode(cmd,next);
        end
    end

    next='f.Doses        = dosesForFit;';
    if isempty(cmd)
        cmd=next;
    else
        cmd=appendCode(cmd,next);
    end

    cmd=appendCode(cmd,['f.FunctionName = ''',estimationMethod,''';']);
    cmd=appendCode(cmd,'f.Options      = options;');
    cmd=appendCode(cmd,['f.ProgressPlot = ',progressPlot,';']);
    cmd=appendCode(cmd,['f.UseParallel  = ',runInParallel,';']);

    if~isMixed
        cmd=appendCode(cmd,['f.Pooled       = ',pooled,';']);
    end

    stepCode=strrep(stepCode,'$(FIT_PROBLEM)',cmd);

end

function stepCode=populateFitAlgorithmSettings(step,stepCode)

    options='';
    props={};
    values={};
    advanced='';
    localSolverSettings='';
    settings=step.algorithmSettings;

    estimateFcn=step.estimationMethod.estimationFunction;
    switch(estimateFcn)
    case 'fminsearch'
        options='optimset';
        props={'TolX','TolFun','MaxIter'};
        values={settings.tolX,settings.tolFun,settings.maxIter};
        advanced=step.advancedSettings.fminsearch;
    case{'lsqcurvefit','lsqnonlin','fminunc','fmincon'}
        options=['optimoptions(''',estimateFcn,''')'];
        props={'StepTolerance','FunctionTolerance','OptimalityTolerance','MaxIterations'};
        values={settings.tolX,settings.tolFun,settings.optimalityTolerance,settings.maxIter};
        advanced=step.advancedSettings.(estimateFcn);
    case 'patternsearch'
        options='optimoptions(''patternsearch'')';
        props={'StepTolerance','FunctionTolerance','MaxIterations'};
        values={settings.tolX,settings.tolFun,settings.maxIter};
        advanced=step.advancedSettings.patternsearch;
    case 'ga'
        options='optimoptions(''ga'')';
        props={'FunctionTolerance','MaxGenerations'};
        values={settings.tolFun,settings.generations};
        advanced=step.advancedSettings.ga;
    case 'particleswarm'
        options=['optimoptions(''',estimateFcn,''')'];
        props={'FunctionTolerance','MaxIterations'};
        values={settings.tolFun,settings.maxIter};
        advanced=step.advancedSettings.particleswarm;
    case 'scattersearch'

        if strcmp(settings.scatterSearchMaxIter,'auto')
            settings.scatterSearchMaxIter=['''',settings.scatterSearchMaxIter,''''];
        end


        if strcmp(settings.numInitialPoints,'auto')
            settings.numInitialPoints=['''',settings.numInitialPoints,''''];
        end


        if strcmp(settings.numTrialPoints,'auto')
            settings.numTrialPoints=['''',settings.numTrialPoints,''''];
        end


        settings.localSolver=['''',settings.localSolver,''''];

        options='struct';
        props={'MaxIterations','FunctionTolerance','MaxStallIterations','MaxTime'...
        ,'NumInitialPoints','NumTrialPoints','XTolerance','LocalSolver'};
        values={settings.scatterSearchMaxIter,settings.scatterSearchFunTol,settings.maxStallIterations,settings.maxTime...
        ,settings.numInitialPoints,settings.numTrialPoints,settings.xTolerance,settings.localSolver};
        advanced=step.advancedSettings.scattersearch;
        localSolverSettings=step.localSolverSettings;
    end


    propList=props;
    for i=1:length(advanced)
        next=advanced(i);
        if~next.isUndefined
            propList{end+1}=next.property;
        end
    end

    maxLength=max(cellfun('length',propList))+1;

    for i=1:length(props)
        if isnumeric(values{i})
            values{i}=num2str(values{i});
        end
    end

    cmd=['options ',blanks(maxLength),'= ',options,';'];
    for i=1:length(props)
        prop=props{i};
        space=blanks(maxLength-length(prop));
        cmd=appendCode(cmd,['options.',prop,space,'= ',values{i},';']);
    end

    for i=1:length(advanced)
        next=advanced(i);
        if~next.isUndefined
            prop=next.property;
            value=getAdvancedOptionValue(next.value);
            space=blanks(maxLength-length(prop));
            cmd=appendCode(cmd,['options.',prop,space,'= ',value,';']);
        end
    end


    if~isempty(localSolverSettings)


        localSolver=strrep(settings.localSolver,'''','');
        advanced=step.localSolverAdvancedSettings.(localSolver);
        switch(localSolver)
        case 'fminsearch'
            options='optimset';
            props={'TolX','TolFun','MaxIter'};
            values={localSolverSettings.tolX,localSolverSettings.tolFun,localSolverSettings.maxIter};
        case{'lsqcurvefit','lsqnonlin','fminunc','fmincon'}
            options=['optimoptions(''',localSolver,''')'];
            props={'StepTolerance','FunctionTolerance','OptimalityTolerance','MaxIterations'};
            values={localSolverSettings.tolX,localSolverSettings.tolFun,localSolverSettings.optimalityTolerance,localSolverSettings.maxIter};
        end

        propList=props;
        for i=1:length(advanced)
            next=advanced(i);
            if~next.isUndefined
                propList{end+1}=next.property;
            end
        end


        maxLength=max(cellfun('length',propList))+1;

        for i=1:length(props)
            if isnumeric(values{i})
                values{i}=num2str(values{i});
            end
        end

        cmd=appendCode(cmd,'');
        cmd=appendCode(cmd,'% Build local solver options');


        cmd=appendCode(cmd,['localSolverOptions ',blanks(maxLength),'= ',options,';']);
        for i=1:length(props)
            prop=props{i};
            space=blanks(maxLength-length(prop));
            cmd=appendCode(cmd,['localSolverOptions.',prop,space,'= ',values{i},';']);
        end

        for i=1:length(advanced)
            next=advanced(i);
            if~next.isUndefined
                prop=next.property;
                value=getAdvancedOptionValue(next.value);
                space=blanks(maxLength-length(prop));
                cmd=appendCode(cmd,['localSolverOptions.',prop,space,'= ',value,';']);
            end
        end


        cmd=appendCode(cmd,'');
        cmd=appendCode(cmd,sprintf('%% Set local solver options to %s',estimateFcn));
        cmd=appendCode(cmd,'options.LocalOptions = localSolverOptions;');
    end

    stepCode=strrep(stepCode,'$(ALGORITHM_OPTIONS)',cmd);

end

function stepCode=populateFitMixedAlgorithmSettings(step,stepCode)

    props={};
    values={};
    advanced='';
    settings=step.algorithmSettings;


    numEstimates=length(step.covarianceMatrixParameterNames);
    covMatrix=reshape(step.covarianceMatrix,numEstimates,numEstimates);
    covPattern=mat2str(double(covMatrix));

    estimateFcn=step.estimationMethod.estimationFunction;
    switch(estimateFcn)
    case 'nlmefit'
        props={'ErrorModel','CovPattern','ApproximationType','OptimFun',...
        'Options.TolX','Options.TolFun','Options.MaxIter'};

        values={['''',step.errorModel.nlmeErrorModel,''''],covPattern,['''',settings.approximationType,''''],['''',settings.optimFun,''''],...
        settings.nlmeTolX,settings.nlmeTolFun,settings.maxIter};

        advanced=step.advancedSettings.nlmefit;
    case 'nlmefitsa'
        props={'ErrorModel','ErrorParameters','CovPattern','NBurnIn',...
        'NIterations','NMCMCIterations','OptimFun','LogLikMethod',...
        'ComputeStdErrors','Options.TolX'};


        a=step.errorModel.nlmefitsaCombinedParameterA;
        b=step.errorModel.nlmefitsaCombinedParameterB;
        if isnumeric(a)
            a=num2str(a);
        end
        if isnumeric(b)
            b=num2str(b);
        end

        errorModelParameters=['[',a,' ',b,']'];

        values={['''',step.errorModel.nlmeErrorModel,''''],errorModelParameters,covPattern,settings.nBurnIn,...
        settings.nIterations,settings.NMCMCIterations,['''',settings.optimFun,''''],...
        ['''',settings.logLikMethod,''''],settings.computeStdErrors,settings.nlmeTolX};

        if~strcmp(step.errorModel.nlmeErrorModel,'combined')
            props(2)=[];
            values(2)=[];
        end

        advanced=step.advancedSettings.nlmefitsa;
    end

    propList=props;
    for i=1:length(advanced)
        next=advanced(i);
        if~next.isUndefined
            if next.isOption
                propList{end+1}=['Options.',next.property];
            else
                propList{end+1}=next.property;
            end
        end
    end

    maxLength=max(cellfun('length',propList))+1;

    for i=1:length(props)
        if isnumeric(values{i})
            values{i}=num2str(values{i});
        end
    end


    space=blanks(maxLength-length(props{1}));
    cmd=['options.',props{1},space,'= ',values{1},';'];

    for i=2:length(props)
        space=blanks(maxLength-length(props{i}));
        cmd=appendCode(cmd,['options.',props{i},space,'= ',values{i},';']);
    end


    for i=1:length(advanced)
        next=advanced(i);
        if~next.isUndefined
            prop=next.property;
            if next.isOption
                prop=['Options.',prop];
            end

            value=getAdvancedOptionValue(next.value);
            space=blanks(maxLength-length(prop));
            cmd=appendCode(cmd,['options.',prop,space,'= ',value,';']);
        end
    end

    stepCode=strrep(stepCode,'$(ALGORITHM_OPTIONS)',cmd);

end

function value=getAdvancedOptionValue(value)

    try

        eval([value,';']);
    catch

        value=['''',value,''''];
    end

end

function[stepCode,stepCleanup]=populateObservables(step,steps,stepCode,model)

    stepCleanup={};


    [stepCode,cleanup]=generateTurnOffObservableCode(stepCode,step,model);
    if~isempty(cleanup)
        stepCleanup{end+1}=cleanup;
    end


    observableStep=getStepByType(steps,'Calculate Observables');
    runObservableStep=observableStep.sectionEnabled;

    if runObservableStep&&~isempty(observableStep.statistics)
        [stepCode,cleanup]=generateTurnOnObservableCode(stepCode,observableStep);
        if~isempty(cleanup)
            stepCleanup{end+1}=cleanup;
        end
    else
        stepCode=strrep(stepCode,'$(TURN_ON_OBSERVABLE_CODE)','$(REMOVE)');
    end

end

function content=readTemplate(name)

    content=SimBiology.web.codegenerationutil('readTemplate',name);

end

function[stepCode,stepCleanup]=generateTurnOffObservableCode(stepCode,step,model)

    [stepCode,stepCleanup]=SimBiology.web.commoncodegenerator('generateTurnOffObservableCode',stepCode,step,model);

end

function[stepCode,stepCleanup]=generateTurnOnObservableCode(stepCode,step)

    [stepCode,stepCleanup]=SimBiology.web.commoncodegenerator('generateTurnOnObservableCode',stepCode,step);

end

function step=getStepByType(steps,type)

    step=SimBiology.web.codegenerationutil('getStepByType',steps,type);

end

function out=createCommaSeparatedList(list)

    out=SimBiology.web.codegenerationutil('createCommaSeparatedList',list);

end

function out=createCommaSeparatedQuotedList(list)

    out=SimBiology.web.codegenerationutil('createCommaSeparatedQuotedList',list);

end

function code=appendCode(code,newCode)

    code=SimBiology.web.codegenerationutil('appendCode',code,newCode);

end

function out=createSemicolonSeparatedList(list)

    out='';
    for i=1:length(list)
        if isempty(list{i})
            out=[out,'''''; '];
        else
            out=[out,list{i},'; '];
        end
    end

    if~isempty(out)
        out=out(1:end-2);
    end
end
