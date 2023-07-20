function[schedulable,tasks,cores]=socTaskSchedulability(varargin)




































    narginchk(1,2);
    tasks=[];
    cores=[];
    if isequal(nargin,1)
        mdl=varargin{1};
        mustBeTextScalar(mdl);
        if~bdIsLoaded(mdl),end
        if systemcomposer.internal.isSystemComposerModel(mdl)
            tmTasks=locGetTasksForSoftwareModel(mdl);
        elseif codertarget.utils.isMdlConfiguredForSoC(getActiveConfigSet(mdl))
            tmTasks=locGetTasksForSoCBModel(mdl);
        end
    else
        allocation=varargin{1};
        alocScenario=varargin{2};
        mustBeTextScalar(allocation);
        mustBeTextScalar(alocScenario);
        tmTasks=locGetTasksForAllocationScenario(allocation,alocScenario);
    end
    coreNumbers=arrayfun(@(x)(x.coreNum),tmTasks,'UniformOutput',false);
    if any(ismember(str2double(coreNumbers),-1))
        error(message('soc:scheduler:TaskSchedulabilityUnassignedCores',mdl));
    end
    uniqueCores=unique(coreNumbers);
    for i=1:numel(uniqueCores)
        cores(i).name=uniqueCores{i};
        idx=arrayfun(@(x)isequal(x.coreNum,uniqueCores{i}),tmTasks);
        thisCoreTasks=tmTasks(idx);
        thisCoreTasks=locSortTaskPerPeriod(thisCoreTasks);
        thisCoreTasks=locInitTaskArrayForAnalysis(thisCoreTasks);
        outTasks=locIsSchedulablePerWCET(thisCoreTasks);
        cores(i).usage=locGetCoreUsage(outTasks);
        tasks=[tasks,outTasks];
    end
    schedulable=locAllTasksMarkedSchedulable(tasks);
    tasks=rmfield(tasks,'period');
    tasks=rmfield(tasks,'WCET');
end


function tmTasks=locGetTasksForSoftwareModel(mdl)
    taskComps=soc.internal.systemcomposer.getTaskComponents(mdl);
    if isempty(taskComps)
        error(message('soc:scheduler:TaskSchedulabilityNoTaskComponents',mdl));
    end
    tmTasks=soc.internal.systemcomposer.getTasksFromTaskComponents(taskComps);
end


function tmTasks=locGetTasksForSoCBModel(mdl)
    tmBlk=soc.internal.connectivity.getTaskManagerBlock(mdl);
    if iscell(tmBlk)
        error(message('soc:scheduler:TaskSchedulabilityMultipleCPUs',mdl));
    end
    tmTasks=soc.internal.taskmanager.getTasks(tmBlk);
end


function tmTasks=locGetTasksForAllocationScenario(allocFile,allocScenario)
    allocSet=systemcomposer.allocation.load(allocFile);
    allocScenarios=allocSet.Scenarios;
    allocScenarioNames=arrayfun(@(x)(x.Name),allocScenarios,'UniformOutput',false);
    [found,idx]=ismember(allocScenario,allocScenarioNames);
    if~found
        error(message('soc:scheduler:TaskSchedulabilityNoScenario',allocScenario,allocFile));
    end
    thisScenario=allocScenarios(idx);
    coreSterotype='soc_blockset_profile.ProcessorCore';
    [~,coreComps]=allocSet.TargetModel.find(systemcomposer.query.HasStereotype(...
    systemcomposer.query.IsStereotypeDerivedFrom(coreSterotype)));
    tmTasks=[];
    for i=1:numel(coreComps)
        thisCoreComp=coreComps(i);
        allocatedTaskComponents=thisScenario.getAllocatedFrom(thisCoreComp);
        if isempty(allocatedTaskComponents),continue;end
        myTasks=soc.internal.systemcomposer.getTasksFromTaskComponents(...
        allocatedTaskComponents);
        coreNum=thisCoreComp.getPropertyValue([coreSterotype,'.CoreNum']);
        for j=1:numel(myTasks),myTasks(j).coreNum=coreNum;end
        tmTasks=[tmTasks,myTasks];
    end
end


function tasks=locInitTaskArrayForAnalysis(thisCoreTasks)
    tasks=[];
    for i=1:numel(thisCoreTasks)
        thisTask=thisCoreTasks(i);
        tasks(i).name=thisTask.taskName;%#ok<*AGROW>
        tasks(i).period=str2double(thisTask.taskPeriod);
        if isscalar(thisTask.taskDurationData)
            tasks(i).WCET=str2double(thisTask.taskDurationData.max);
        else
            allMax=[thisTask.taskDurationData(:).max];
            allMaxNum=cellfun(@(x)str2double(x),allMax,'UniformOutput',true);
            tasks(i).WCET=max(allMaxNum);
        end
        tasks(i).schedulable=1;
    end
end


function ret=locAllTasksMarkedSchedulable(tasks)
    sched=arrayfun(@(x)(x.schedulable),tasks,'UniformOutput',false);
    ret=all(cell2mat(sched));
end


function usage=locGetCoreUsage(myTasks)
    usage=100;
    if~locAllTasksMarkedSchedulable(myTasks),return;end
    m=1;
    p=arrayfun(@(x)(x.period),myTasks);
    while~all(arrayfun(@(x)(x>=1),p))
        m=m*10;
        p=m*p;
    end
    mylcm=p(1);
    for i=2:numel(p)
        mylcm=lcm(mylcm,p(i));
    end
    val=0;
    for i=1:numel(p)
        val=val+(mylcm/p(i))*myTasks(i).WCET*m;
    end
    usage=100*(val/mylcm);
    usage=min(usage,100);
end


function t=locSortTaskPerPeriod(t)
    p=arrayfun(@(x)(x.taskPeriod),t,'UniformOutput',false);
    p=str2double(p);
    [~,idx]=sort(p);
    t=t(idx);
end


function tasks=locIsSchedulablePerWCET(tasks)
    for j=1:numel(tasks)
        I=0;
        R=0;
        Cj=tasks(j).WCET;
        Pj=tasks(j).period;
        Dj=Pj;
        while((I+Cj)>R)
            R=I+Cj;
            if(R>Dj)
                tasks(j).schedulable=0;
                break;
            end
            mySum=0;
            for k=1:j-1
                Ck=tasks(k).WCET;
                Pk=tasks(k).period;
                mySum=mySum+Ck*ceil(R/Pk);
            end
            I=mySum;
        end
        if 0==tasks(j).schedulable,break;end
        tasks(j).schedulable=1;
    end

    for j=2:numel(tasks)
        if 0==tasks(j-1).schedulable
            tasks(j).schedulable=0;
        end
    end
end
