function[stepCall,stepCode,stepCleanup]=gsacodegenerator(step,steps,argList)











    switch(step.type)
    case 'Global Sensitivity Analysis'
        [stepCall,stepCode,stepCleanup]=generateGSACode(step,steps,argList);
    case 'Add Samples'
        [stepCall,stepCode,stepCleanup]=generateAddSampleCode(step);
    case 'MPGSA'
        [stepCall,stepCode,stepCleanup]=generateMPGSAStepCode(steps,argList);
    end

end

function[stepCall,stepCode,stepCleanup]=generateGSACode(step,steps,argList)


    stepCall='% Global sensitivity analysis.';
    stepCall=appendCode(stepCall,'args = runGSA(args);');
    stepCode=readTemplate('runGSA.txt');
    stepCleanup={};


    model=argList{1};
    cs=getconfigset(model,'active');
    needCSCode=~strcmp(cs.Name,'default');


    variants=argList{3};
    doses=argList{4};
    blankStr='';
    if~isempty(variants.modelStep)
        blankStr='   ';
    end

    argCode=['input ',blankStr,'= args.input;'];
    argCode=appendCode(argCode,['model ',blankStr,'= input.model;']);

    if needCSCode
        argCode=appendCode(argCode,['cs    ',blankStr,'= input.cs;']);
    end

    if~isempty(variants.modelStep)
        argCode=appendCode(argCode,'variants = input.variants.modelStep;');
    end

    if~isempty(doses.modelStep)
        argCode=appendCode(argCode,['doses ',blankStr,'= input.doses.modelStep;']);
    end

    if needCSCode
        argCode=appendCode(argCode,'');
        argCode=appendCode(argCode,'% Set the active configuration set.');
        argCode=appendCode(argCode,'originalConfigset = getconfigset(model, ''active'');');
        argCode=appendCode(argCode,'setactiveconfigset(model, cs);');
        argCode=appendCode(argCode,'');
        argCode=appendCode(argCode,'% Restore the original configset after the task has completed running.');
        argCode=appendCode(argCode,'cleanupConfigset = onCleanup(@() restoreActiveConfigset(model, originalConfigset));');


        stepCleanup{end+1}=readTemplate('restoreActiveConfigset.txt');
    end

    stepCode=strrep(stepCode,'$(ARG_CODE)',argCode);

    switch(step.analysis)
    case 'Sobol indices'
        stepCode=generateSobolIndicesCode(stepCode,step,steps,argList);
    case 'Elementary effects'
        stepCode=generateElementaryEffectsCode(stepCode,step,steps,argList);
    otherwise
        stepCode=generateMPGSACode(stepCode,step,steps,argList);
    end

end

function stepCode=generateSobolIndicesCode(stepCode,step,steps,argList)


    stepCode=writeScenariosCode(stepCode,step);


    stepCode=writeSensitivityOutputsCode(stepCode,step);


    options=getCommonOptions(step,steps,argList);
    stepCode=writeOptionsCode(stepCode,options);


    code='% Compute first and total order Sobol indices.';
    code=appendCode(code,'data = sbiosobol(model, inputs, outputs, options{:});');
    stepCode=strrep(stepCode,'$(ANALYSIS_CODE)',code);

end

function stepCode=generateMPGSACode(stepCode,step,steps,argList)


    stepCode=writeScenariosCode(stepCode,step);


    code=getClassifiersCode(step);
    stepCode=strrep(stepCode,'$(SENSITIVITY_OUTPUTS_CODE)',code);


    options=getCommonOptions(step,steps,argList);
    slevel=step.significanceLevel;

    if ischar(slevel)
        slevel=str2double(slevel);
    end

    if(slevel~=0.05)
        options{end+1}='SignificanceLevel';
        options{end+1}=num2str(slevel);
    end

    stepCode=writeOptionsCode(stepCode,options);


    code='% Perform multiparametric global sensitivity analysis.';
    code=appendCode(code,'data = sbiompgsa(model, inputs, classifiers, options{:});');
    stepCode=strrep(stepCode,'$(ANALYSIS_CODE)',code);

end

function stepCode=generateElementaryEffectsCode(stepCode,step,steps,argList)


    stepCode=strrep(stepCode,'$(SCENARIOS_CODE)','$(REMOVE)');


    inputs=step.sensitivityInputs.sensitivityBoundedInputs;
    if iscell(inputs)
        inputs=[inputs{:}];
    end

    inputs=inputs([inputs.use]);
    inputs=inputs([inputs.sessionID]~=-1);
    bounds=createBoundsMatrix(inputs);
    inputs={inputs.name};
    inputs=['inputs = {',createCommaSeparatedQuotedList(inputs),'};'];

    code='% Define sensitivity inputs';
    code=appendCode(code,inputs);
    stepCode=strrep(stepCode,'$(SENSITIVITY_INPUTS_CODE)',code);


    stepCode=writeSensitivityOutputsCode(stepCode,step);


    options=getCommonOptions(step,steps,argList);
    numSamples=step.numberOfSamples;
    gridSettings=step.gridSettings;
    gridLevel=gridSettings.gridLevel;
    gridDelta=gridSettings.gridDelta;

    if~isempty(bounds)
        options{end+1}='Bounds';
        options{end+1}=mat2str(bounds);
    end

    if ischar(numSamples)
        numSamples=str2double(numSamples);
    end

    if ischar(gridLevel)
        gridLevel=str2double(gridLevel);
    end

    if ischar(gridDelta)
        gridDelta=str2double(gridDelta);
    end

    if(numSamples~=1000)
        options{end+1}='NumberSamples';
        options{end+1}=num2str(numSamples);
    end

    if(gridLevel~=10)
        options{end+1}='GridLevel';
        options{end+1}=num2str(gridLevel);
    end

    if(gridDelta~=gridLevel/2)
        options{end+1}='GridDelta';
        options{end+1}=num2str(gridDelta);
    end

    if~strcmp(gridSettings.pointSelection,'chain')
        options{end+1}='PointSelection';
        options{end+1}=['''',gridSettings.pointSelection,''''];
    end

    if~strcmp(gridSettings.samplingMethod,'lhs')
        options{end+1}='SamplingMethod';
        options{end+1}=['''',gridSettings.samplingMethod,''''];
    end

    outputSettings=step.outputSettings;
    if~strcmp(outputSettings.absoluteEffects,'true')
        options{end+1}='AbsoluteEffects';
        options{end+1}=outputSettings.absoluteEffects;
    end

    stepCode=writeOptionsCode(stepCode,options);


    code='% Compute elementary effects.';
    code=appendCode(code,'data = sbioelementaryeffects(model, inputs, outputs, options{:});');
    stepCode=strrep(stepCode,'$(ANALYSIS_CODE)',code);

end

function stepCode=writeScenariosCode(stepCode,step)

    isSobol=strcmp(step.analysis,'Sobol indices');
    nameLookup=containers.Map('KeyType','char','ValueType','char');
    numberOfSamples=step.numberOfSamples;
    sets=step.sensitivityInputs;
    if iscell(sets)
        sets=[sets{:}];
    end

    sets=sets([sets.use]);
    code='% Generate scenarios.';
    pdCount=1;
    samplesCount=1;

    for i=1:numel(sets)
        startCount=pdCount;
        tableData=sets(i).sensitivityInputs;
        if iscell(tableData)
            tableData=[tableData{:}];
        end

        tableData=tableData([tableData.use]);
        tableData=tableData([tableData.sessionID]~=-1);




        if~isSobol
            numberOfSamples=sets(i).numberOfSamples;
        end

        if~isempty(tableData)
            if samplesCount~=1
                code=appendCode(code,'');
            end

            varName=['samples',num2str(samplesCount)];
            code=appendCode(code,[varName,' = SimBiology.Scenarios();']);



            nameLookup(sets(i).name)=varName;


            for j=1:length(tableData)
                next=generateProbabilityDistributionCode(tableData(j),varName,pdCount);
                code=appendCode(code,next);
                pdCount=pdCount+1;
            end


            [code,optionsIncluded,optionsName]=generateSamplingOptionCode(code,sets(i),samplesCount);



            next=generateSamplingCode(sets(i),tableData,varName,startCount,optionsIncluded,optionsName,numberOfSamples);
            code=appendCode(code,next);

            samplesCount=samplesCount+1;
        end
    end


    code=appendCode(code,'');
    code=appendCode(code,'% Configure RandomSeed to a unique value.');
    for i=1:samplesCount-1
        if i==1
            code=appendCode(code,'seeds               = typecast(now, ''uint32'');');
            code=appendCode(code,['samples',num2str(i),'.RandomSeed = seeds(1);']);
        else
            code=appendCode(code,['samples',num2str(i),'.RandomSeed = rng;']);
        end
    end

    stepCode=strrep(stepCode,'$(SCENARIOS_CODE)',code);


    code=defineCombinationCode(step.combinations,nameLookup);
    stepCode=strrep(stepCode,'$(SENSITIVITY_INPUTS_CODE)',code);

end

function code=generateProbabilityDistributionCode(data,varName,pdCount)


    code=SimBiology.web.scenarioscodegenerationutil('generateProbabilityDistributionCode',data,varName,pdCount);

end

function[code,optionsIncluded,optionsName]=generateSamplingOptionCode(code,set,nameIdx)


    [code,optionsIncluded,optionsName]=SimBiology.web.scenarioscodegenerationutil('generateSamplingOptionCode',code,set,set.samplingOptions.type,nameIdx);

end

function code=generateSamplingCode(set,tableData,varName,startCount,optionsIncluded,optionsName,numberOfSamples)



    samplingTypes={'latin hypercube','sobol','halton','copula','random',...
    'latin hypercube sampling with rank correlation matrix',...
    'sobol sampling with rank correlation matrix',...
    'halton sampling with rank correlation matrix',...
    'copula sampling with rank correlation matrix',...
    'random sampling with rank correlation matrix',...
    'latin hypercube sampling with covariance matrix',...
    'random sampling with covariance matrix'};
    samplingMethods={'lhs','sobol','halton','copula','random','lhs',...
    'sobol','halton','copula','random','lhs','random'};
    samplingIndex=strcmp(set.samplingOptions.type,samplingTypes);



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


    hasCorr=contains(set.samplingOptions.type,'correlation matrix');
    hasCov=contains(set.samplingOptions.type,'covariance matrix');
    corrMatrix='[]';
    covMatrix='[]';

    if(hasCorr)
        corrNames=set.correlationMatrix.paramNames;
        corrData=set.correlationMatrix.tableData;
        if~isempty(corrData)
            corrMatrix=SimBiology.web.codegenerationutil('generateCovarianceMatrix',corrNames,corrData);
            corrMatrix=mat2str(corrMatrix);
        end
    end

    if(hasCov)
        covNames=set.covarianceMatrix.paramNames;
        covData=set.covarianceMatrix.tableData;
        if~isempty(covData)
            covMatrix=SimBiology.web.codegenerationutil('generateCovarianceMatrix',covNames,covData);
            covMatrix=mat2str(covMatrix);
        end
    end


    if isnumeric(numberOfSamples)
        numberOfSamples=num2str(numberOfSamples);
    end


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
    names,', ',args,', ''Number'', ',numberOfSamples,', ''SamplingMethod'', ''',samplingMethod,''''];

    if optionsIncluded
        code=[code,', ''SamplingOptions'', ',optionsName,''];
    end

    if hasCorr
        code=[code,', ''RankCorrelation'', ',corrMatrix,');'];
    elseif hasCov
        code=[code,', ''Covariance'', ',covMatrix,');'];
    else
        code=[code,');'];
    end

end

function[code,name]=defineCombinationCode(combinations,nameLookup)





    code='% Define sensitivity inputs.';
    if nameLookup.Count==0
        code=appendCode(code,'inputs = [];');
        return;
    elseif nameLookup.Count==1
        code=appendCode(code,'inputs = samples1;');
        return;
    end

    if iscell(combinations)
        combinations=[combinations{:}];
    end

    code='% Combine scenarios.';

    for i=1:length(combinations)
        name1=combinations(i).prop1;
        name2=combinations(i).prop2;

        if isKey(nameLookup,name1)
            sample1=nameLookup(name1);
        else
            sample1=name1;
        end

        if isKey(nameLookup,name2)
            sample2=nameLookup(name2);
        else
            sample2=name2;
        end

        name=combinations(i).name;
        type=combinations(i).product;
        code=appendCode(code,[name,' = add(copy(',sample1,'), ''',type,''', ',sample2,');']);
    end

    code=appendCode(code,'');
    code=appendCode(code,'% Define sensitivity inputs.');
    code=appendCode(code,['inputs = ',name,';']);

end

function out=createBoundsMatrix(inputs)

    out=[];
    lowerBounds={inputs.lower};
    upperBounds={inputs.upper};
    values={inputs.value};

    if all(cellfun('isempty',upperBounds))&&all(cellfun('isempty',lowerBounds))
        return;
    end

    out=zeros(numel(upperBounds),2);
    for i=1:numel(upperBounds)
        lowerBound=lowerBounds{i};
        upperBound=upperBounds{i};
        value=values{i};

        if ischar(lowerBound)
            lowerBound=str2double(lowerBound);
        end

        if ischar(upperBound)
            upperBound=str2double(upperBound);
        end

        if ischar(value)
            value=str2double(value);
        end

        if isnan(lowerBound)
            lowerBound=value-(0.1*value);
        end

        if isnan(upperBound)
            upperBound=value+(0.1*value);
        end

        if lowerBound==0&&upperBound==0
            upperBound=1;
        end

        if lowerBound<upperBound
            out(i,1)=lowerBound;
            out(i,2)=upperBound;
        else
            out(i,1)=upperBound;
            out(i,2)=lowerBound;
        end
    end

end

function stepCode=writeSensitivityOutputsCode(stepCode,step)


    outputs=step.sensitivityOutputs;
    if iscell(outputs)
        outputs=[outputs{:}];
    end

    outputs=outputs([outputs.use]);
    outputs=outputs([outputs.sessionID]~=-1);
    outputs={outputs.name};
    outputs=['outputs = {',createCommaSeparatedQuotedList(outputs),'};'];

    code='% Define sensitivity outputs.';
    code=appendCode(code,outputs);
    stepCode=strrep(stepCode,'$(SENSITIVITY_OUTPUTS_CODE)',code);

end

function code=getClassifiersCode(step)


    classifiers=step.classifiers;
    if iscell(classifiers)
        classifiers=[classifiers{:}];
    end

    classifiers=classifiers([classifiers.use]);
    classifiers={classifiers.expression};
    for i=1:numel(classifiers)
        classifiers{i}=strrep(classifiers{i},'''','''''');
    end

    classifiers=['classifiers = {',createCommaSeparatedQuotedList(classifiers),'};'];

    code='% Define classifiers.';
    code=appendCode(code,classifiers);

end

function options=getCommonOptions(step,steps,argList)

    modelStep=getStepByType(steps,'Model');
    accelerate=modelStep.accelerate;
    variants=argList{3};
    doses=argList{4};
    options={};

    if~isempty(variants.modelStep)
        options{end+1}='Variants';
        options{end+1}='variants';
    end

    if~isempty(doses.modelStep)
        options{end+1}='Doses';
        options{end+1}='doses';
    end

    if(~accelerate)
        options{end+1}='Accelerate';
        options{end+1}='false';
    end

    if(step.runInParallel)
        options{end+1}='UseParallel';
        options{end+1}='true';
    end

    simTime=step.simulationTimeSettings;
    if(simTime.useStopTime)
        options{end+1}='StopTime';
        options{end+1}=num2str(simTime.stopTime);

        if~strcmp(simTime.interpolation,'interp1q')
            options{end+1}='InterpolationMethod';
            options{end+1}=['''',simTime.interpolation,''''];
        end
    else
        options{end+1}='OutputTime';
        options{end+1}=simTime.outputTimes;
    end

end

function stepCode=writeOptionsCode(stepCode,options)

    code='% Define options.';
    if isempty(options)
        code=appendCode(code,'options = {};');
        stepCode=strrep(stepCode,'$(OPTIONS_CODE)',code);
        return;
    end

    next='options = {';
    for i=1:2:numel(options)
        next=[next,'''',options{i},''', ',options{i+1},', '];%#ok<*AGROW> 
        if rem(i+1,6)==0
            if(i+1)~=numel(options)
                code=appendCode(code,[next,'...']);
                next='    ';
            else
                code=appendCode(code,[next(1:end-2),'};']);
                next='    ';
            end
        end
    end

    if~isempty(deblank(next))
        code=appendCode(code,[next(1:end-2),'};']);
    end

    stepCode=strrep(stepCode,'$(OPTIONS_CODE)',code);

end

function[stepCall,stepCode,stepCleanup]=generateAddSampleCode(step)


    stepCall='% Add samples.';
    stepCall=appendCode(stepCall,'args = runAddSamples(args);');
    stepCode=readTemplate('runAddSamples.txt');
    stepCleanup={};

    settings=step.sampleSettings;
    numSamples=settings.numSamples;

    if isnumeric(numSamples)
        numSamples=num2str(numSamples);
    end

    stepCode=strrep(stepCode,'$(NUMSAMPLES)',numSamples);

end

function[stepCall,stepCode,stepCleanup]=generateMPGSAStepCode(steps,argList)


    model=argList{1};


    gsaStep=getStepByType(steps,'Global Sensitivity Analysis');
    isSobol=strcmp(gsaStep.analysis,'Sobol indices');


    stepCleanup={};
    stepCall='% Compute MPGSA results.';
    stepCall=appendCode(stepCall,'args = runMPGSA(args);');

    if isSobol
        defined=areTokensDefined(model,gsaStep);
        if defined
            stepCode=readTemplate('runMPGSASobol.txt');
        else
            stepCode=readTemplate('runMPGSASobolOnModel.txt');
        end
    else
        stepCode=readTemplate('runMPGSA.txt');
    end


    cs=getconfigset(model,'active');
    needCSCode=~strcmp(cs.Name,'default');

    if needCSCode
        csCode='% Extract the inputs.';
        csCode=appendCode(csCode,'inputs = args.input;');
        csCode=appendCode(csCode,'model  = inputs.model;');
        csCode=appendCode(csCode,'cs     = inputs.cs;');
        csCode=appendCode(csCode,'');
        csCode=appendCode(csCode,'% Set the active configuration set.');
        csCode=appendCode(csCode,'originalConfigset = getconfigset(model, ''active'');');
        csCode=appendCode(csCode,'setactiveconfigset(model, cs);');
        csCode=appendCode(csCode,'');
        csCode=appendCode(csCode,'% Restore the original configset after the task has completed running.');
        csCode=appendCode(csCode,'cleanupConfigset = onCleanup(@() restoreActiveConfigset(model, originalConfigset));');

        stepCode=strrep(stepCode,'$(CONFIGSET_CODE)',csCode);


        gsaStep=getStepByType(steps,'Global Sensitivity Analysis');
        if~gsaStep.enabled
            stepCleanup{end+1}=readTemplate('restoreActiveConfigset.txt');
        end
    else
        stepCode=strrep(stepCode,'$(CONFIGSET_CODE)','$(REMOVE)');
    end


    options={};
    slevel=gsaStep.significanceLevel;

    if ischar(slevel)
        slevel=str2double(slevel);
    end

    if(slevel~=0.05)
        options{end+1}='SignificanceLevel';
        options{end+1}=num2str(slevel);
    end

    if~isempty(options)
        stepCode=writeOptionsCode(stepCode,options);
        stepCode=strrep(stepCode,'$(OPTIONS_ARG_CODE)',', options{:}');
    else
        stepCode=strrep(stepCode,'$(OPTIONS_CODE)','$(REMOVE)');
        stepCode=strrep(stepCode,'$(OPTIONS_ARG_CODE)','$(REMOVE)');
    end


    code=getClassifiersCode(gsaStep);
    stepCode=strrep(stepCode,'$(CLASSIFIERS_CODE)',code);

end

function out=areTokensDefined(model,gsaStep)


    outputs=gsaStep.sensitivityOutputs;
    if iscell(outputs)
        outputs=[outputs{:}];
    end

    outputs=outputs([outputs.use]);
    outputs=outputs([outputs.sessionID]~=-1);
    outputs={outputs.name};


    classifiers=gsaStep.classifiers;
    if iscell(classifiers)
        classifiers=[classifiers{:}];
    end

    classifiers=classifiers([classifiers.use]);
    classifiers={classifiers.expression};
    [~,tokens]=SimBiology.gsa.MPGSA.getClassifierTokens(model,classifiers);


    for i=1:numel(tokens)
        next=tokens{i};
        for j=1:numel(next)
            if~any(strcmp(next{j},outputs))
                out=false;
                return;
            end
        end
    end

    out=true;

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
