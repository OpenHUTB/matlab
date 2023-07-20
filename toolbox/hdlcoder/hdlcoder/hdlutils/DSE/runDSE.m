function log=runDSE(model,targetNames,targetValues,iterationLimit)














    if~isempty(model)
        model=convertStringsToChars(model);
    end

    assert(ischar(model));


    modelchip=hdlget_param(model,'HDLSubsystem');
    if(isequal(modelchip,model))
        chip='';
    else
        assert(modelchip(length(model)+1)=='/');
        chip=modelchip(length(model)+2:end);
    end


    AdaptivePipelining={'on','off'};
    ClockRatePipelining={'on','off'};
    DistributedPipelining={'on','off'};
    InputPipeline='numeric';
    OutputPipeline='numeric';
    SharingFactor='numeric';
    StreamingFactor='numeric';

    geneTypes={AdaptivePipelining,ClockRatePipelining,DistributedPipelining,InputPipeline...
    ,OutputPipeline,SharingFactor,StreamingFactor};
    geneNames={'AdaptivePipelining','ClockRatePipelining','DistributedPipelining','InputPipeline',...
    'OutputPipeline','SharingFactor','StreamingFactor'};


    currentAdaptivePipelining=hdlget_param([model,'/',chip],'AdaptivePipelining');
    if isequal(currentAdaptivePipelining,"inherit")
        currentAdaptivePipelining=hdlget_param(model,'AdaptivePipelining');
    end
    currentClockRatePipelining=hdlget_param([model,'/',chip],'ClockRatePipelining');
    if isequal(currentClockRatePipelining,"inherit")
        currentClockRatePipelining=hdlget_param(model,'ClockRatePipelining');
    end
    currentDistributedPipelining=hdlget_param([model,'/',chip],'DistributedPipelining');
    currentInputPipeline=hdlget_param([model,'/',chip],'InputPipeline');
    currentOutputPipeline=hdlget_param([model,'/',chip],'OutputPipeline');
    currentSharingFactor=hdlget_param([model,'/',chip],'SharingFactor');
    currentStreamingFactor=hdlget_param([model,'/',chip],'StreamingFactor');

    geneValues={currentAdaptivePipelining,currentClockRatePipelining,currentDistributedPipelining,currentInputPipeline...
    ,currentOutputPipeline,currentSharingFactor,currentStreamingFactor};


    populationSize=10;
    individuals=cell(1,populationSize);
    for i=1:populationSize
        individuals{i}=Individual(geneNames,geneValues,geneTypes);
    end
    population=Population(individuals);


    assert(all(ismember(targetNames,["CPDelay","latency","multipliers","addersSubtractors","registers","oneBitRegisters","rams","multiplexers","IOBits","staticShiftOperators","dynamicShiftOperators"])));
    for i=1:numel(targetNames)
        targets.(targetNames(i))=targetValues(i);
    end


    resultsFolder='runDSE_results';
    if(exist(fullfile('.',resultsFolder),'dir')~=7)
        s=mkdir('.',resultsFolder);
        if(~s)
            error(message('hdlcoder:optimization:CannotCreateDir',resultsFolder));
        end
    end


    assert(iterationLimit==floor(iterationLimit)&&iterationLimit>0);
    iterCtrl.iter=1;
    iterCtrl.iterLimit=iterationLimit;


    log=cell(1,3);

tic
    while(true)

        [newPopulation,iterCtrl,status,optionsTable,resourceTable]=iterProcess(population,iterCtrl,targets,model,chip,resultsFolder);
        t=toc;


        log{1}=[log{1};optionsTable];
        log{2}=[log{2};resourceTable];
        log{3}=[log{3};t];


        if(status)
            break;
        end


        population=newPopulation;
        iterCtrl.iter=iterCtrl.iter+1;
    end


    rmdir('slprj','s');
    rmdir('hdlsrc','s');


    cd(fullfile(resultsFolder,['Iter',num2str(iterCtrl.iter)]));
    saved_params();
    makehdl([model,'/',chip],'CriticalPathEstimation','on','ResourceReport','on','GenerateModel','on');
end

function[newPopulation,iterCtrl,status,optionsTable,resourceTable]=iterProcess(population,iterCtrl,targets,model,chip,resultsFolder)

















    newPopulation=Population({});
    status=true;


    hasReached=runCodegenAndSaveResults(population,targets,model,chip,iterCtrl);


    population.calculateFitnesses(targets);


    [optionsTable,resourceTable]=saveResults(model,chip,population,iterCtrl,resultsFolder);


    if hasReached
        disp("Exiting because all targets are reached")
        return
    end


    if iterCtrl.iter>=iterCtrl.iterLimit
        disp('Exiting because iteration limit is reached')
        return
    end


    newPopulation=population.getNextGeneration();

    status=false;
end

function hasReached=runCodegenAndSaveResults(population,targets,model,chip,iterCtrl)












    hasReached=false;

    for i=1:population.PopulationSize
        individual=population.Individuals{i};


        setOptimOptions(model,chip,individual);

        makehdl([model,'/',chip],'CriticalPathEstimation','on','ResourceReport','on','GenerateModel','off');


        load(fullfile('.','hdlsrc',model,'hdlcodegenstatus.mat'));
        individual.saveCodegenResults(ResourceSummary,CriticalPathDelay,Latency);


        fieldNames=fieldnames(targets);
        isReached=zeros(1,numel(fieldNames));
        for j=1:numel(fieldNames)
            if individual.CodegenResults.(fieldNames{j})<=targets.(fieldNames{j})
                isReached(j)=1;
            end
        end
        if all(isReached)
            hasReached=true;
        end


        if iterCtrl.iter==1
            for j=2:population.PopulationSize
                individual=population.Individuals{j};
                individual.saveCodegenResults(ResourceSummary,CriticalPathDelay,Latency);
            end
            break
        end
    end
end

function setOptimOptions(model,chip,individual)







    for i=1:numel(individual.GeneNames)
        hdlset_param([model,'/',chip],individual.GeneNames{i},individual.Genes.(individual.GeneNames{i}))
    end
end

function[optionsTable,resourceTable]=saveResults(model,chip,population,iterCtrl,resultsFolder)













    currentResultsFolder=fullfile(resultsFolder,['Iter',num2str(iterCtrl.iter)]);
    if(exist(fullfile('.',currentResultsFolder),'dir')~=7)
        s=mkdir('.',currentResultsFolder);
        if(~s)
            error(message('hdlcoder:optimization:CannotCreateDir',currentResultsFolder));
        end
    end
    [~,fittestIdx]=max(population.Fitnesses);
    bestIndividual=population.Individuals{fittestIdx};


    setOptimOptions(model,chip,bestIndividual);
    hdlsaveparams([model,'/',chip],fullfile(currentResultsFolder,'saved_params.m'),true);
    optionsTable=table;
    optionsTable=logOptimOptions(population.Individuals(fittestIdx),optionsTable);


    resourceTable=table;
    resourceTable=logCodegenResults(population.Individuals(fittestIdx),resourceTable);
    writetable(resourceTable,fullfile(currentResultsFolder,'resource_usage.csv'));
end

function logTable=logOptimOptions(individuals,logTable)

    fieldNames=fieldnames(individuals{1}.Genes);
    for i=1:numel(fieldNames)
        options=cell(numel(individuals),1);
        for j=1:numel(individuals)
            options{j}=individuals{j}.Genes.(fieldNames{i});
        end
        logTable.(fieldNames{i})=options;
    end
end

function logTable=logCodegenResults(individuals,logTable)

    fieldNames=fieldnames(individuals{1}.CodegenResults);
    for i=1:numel(fieldNames)
        results=cell(numel(individuals),1);
        for j=1:numel(individuals)
            results{j}=individuals{j}.CodegenResults.(fieldNames{i});
        end
        logTable.(fieldNames{i})=results;
    end
end