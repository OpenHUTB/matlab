function socCreateModel(varargin)

























    narginchk(1,2);

    if isequal(nargin,1)
        mdl=varargin{1};
        mustBeTextScalar(mdl);
        tasks=locGetTasks(mdl);
    else
        allocFile=varargin{1};
        alocScenario=varargin{2};
        mustBeTextScalar(allocFile);
        mustBeTextScalar(alocScenario);
        tasks=locGetTasksForAllocationScenario(allocFile,alocScenario);
    end
    aperiodicTasks=locGetSortedAperiodicTasks(tasks);
    periodicTasks=locGetSortedPeriodicTasks(tasks);
    tasks=[aperiodicTasks,periodicTasks];
    refMdl=locCreateRefModel(tasks);
    topMdl=locCreateTopModel(tasks,refMdl);
    locConnectTopAndRefModel(tasks,topMdl);
end


function tasks=locGetTasks(model)
    pComp=soc.internal.systemcomposer.getPeriodicTaskComponents(model);
    aComp=soc.internal.systemcomposer.getAperiodicTaskComponents(model);
    tasks=arrayfun(@(x)locInitializeTaskStructure,1:numel(pComp)+numel(aComp));
    for i=1:numel(pComp)
        tasks(i).taskName=pComp(i).Name;
        taskStereotype='soc_blockset_profile.PeriodicSoftwareTask';
        period=iGetPropVal(pComp(i),taskStereotype,'Period');
        tasks(i).taskType='Timer-driven';
        tasks(i).taskPeriod=period;
        tasks(i)=iSetTaskDuration(tasks(i),pComp(i),taskStereotype);
    end
    ofs=numel(pComp);
    for i=1:numel(aComp)
        tasks(ofs+i).taskName=comp(i).Name;
        taskStereotype='soc_blockset_profile.AperiodicSoftwareTask';
        priority=iGetPropVal(comp(i),taskStereotype,'Priority');
        tasks(ofs+i).taskType='Event-driven';
        tasks(ofs+i).taskPriority=priority;
        tasks(ofs+i).taskEvent=[tasks(i).taskName,'Event'];
        tasks(ofs+i)=iSetTaskDuration(tasks(ofs+i),pComp(i),taskStereotype);
    end
    function t=iSetTaskDuration(t,c,st)
        t.taskDurationData.mean=iGetPropVal(c,st,'MeanExecutionTime');
        t.taskDurationData.min=iGetPropVal(c,st,'MinExecutionTime');
        t.taskDurationData.max=iGetPropVal(c,st,'MaxExecutionTime');
        t.taskDurationData.dev=iGetPropVal(c,st,'ExecutionTimeStd');
    end
    function value=iGetPropVal(component,stereotype,property)
        str=[stereotype,'.',property];
        value=component.getPropertyValue(str);
    end
end


function tmTasks=locGetTasksForAllocationScenario(allocFile,alocScenario)
    allocSet=systemcomposer.allocation.load(allocFile);
    allocScenarios=allocSet.Scenarios;
    allocScenarioNames=arrayfun(@(x)(x.Name),allocScenarios,'UniformOutput',false);
    [found,idx]=ismember(alocScenario,allocScenarioNames);
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
        tmTasks=[tmTasks,myTasks];%#ok<AGROW> 
    end
end



function locConnectTopAndRefModel(tasks,mdl)
    try
        set_param(mdl,'SimulationCommand','update');
    catch me
        expectedErrID='soc:scheduler:TaskManagerUnconnectedTask';
        if~isequal(me.cause{1}.identifier,expectedErrID)
            rethrow(me);
        end
    end
    for i=1:numel(tasks)
        str=num2str(i);
        add_line(mdl,['Task Manager/',str],['Model/',str],'autorouting','on');
    end
    Simulink.BlockDiagram.arrangeSystem(mdl);
end


function out=locGetSortedAperiodicTasks(tasks)
    out=tasks(arrayfun(@(x)isequal(x.taskType,'Event-driven'),tasks));
    out=locSortArrStruct(out,'taskName');
end


function out=locGetSortedPeriodicTasks(tasks)
    out=tasks(arrayfun(@(x)isequal(x.taskType,'Timer-driven'),tasks));
    per=str2double(arrayfun(@(x)(x.taskPeriod),out,'UniformOutput',false));
    [~,idx]=sort(per);
    out=out(idx);
    swapped=true;
    while(swapped)
        swapped=false;
        for i=1:numel(out)-1
            if~isequal(out(i).taskPeriod,out(i+1).taskPeriod),continue;end
            names={out(i:i+1).taskName};
            if~isequal(sort(names),names)
                tmp=out(i);
                out(i)=out(i+1);
                out(i+1)=tmp;
                swapped=true;
            end
        end
    end
end


function topMdlName=locCreateTopModel(tasks,refMdl)
    topMdl=new_system;
    topMdlName=get_param(topMdl,'Name');
    open_system(topMdlName);
    set_param(topMdlName,'HardwareBoard','Custom Hardware Board');
    numCores=numel(unique(arrayfun(@(x)(x.coreNum),tasks,'UniformOutput',false)));
    codertarget.data.setParameterValue(getActiveConfigSet(topMdlName),...
    'Processor.NumberOfCores',num2str(numCores));
    set_param(topMdlName,'ConcurrentTasks','on');
    mgrBlk=add_block('proctasklib/Task Manager',[topMdlName,'/Task Manager']);
    set_param(mgrBlk,'UseScheduleEditor','on');
    mdlBlk=add_block('simulink/Ports & Subsystems/Model',[topMdlName,'/Model']);
    set_param(mdlBlk,'ModelName',refMdl);
    set_param(mdlBlk,'ScheduleRates','on');
    set_param(mdlBlk,'ScheduleRatesWith','Ports');
    locAddTask(mgrBlk,tasks);
    idx=0;
    for i=1:numel(tasks)
        if isequal(tasks(i).taskType,'Event-driven')
            idx=idx+1;
            name=[tasks(i).taskName,'EventSource'];
            add_block('prociodatalib/Event Source',[topMdlName,'/',name]);
            add_line(topMdlName,[name,'/1'],['Task Manager/',num2str(idx)],...
            'autorouting','on');
        end
    end
end


function refMdlName=locCreateRefModel(tasks)
    refMdl=new_system;
    set_param(refMdl,'HardwareBoard','Custom Hardware Board');
    open_system(refMdl);
    set_param(refMdl,'SolverType','Fixed-step');
    set_param(refMdl,'EnableMultiTasking','on');
    refMdlName=get_param(refMdl,'Name');
    for i=1:numel(tasks)
        taskName=tasks(i).taskName;
        taskSrcLib='simulink/Ports & Subsystems/Subsystem';
        subsys=add_block(taskSrcLib,[refMdlName,'/',taskName]);
        set_param(subsys,'TreatAsAtomicUnit','on');
        set_param(subsys,'PartitionName',taskName);
        if isequal(tasks(i).taskType,'Timer-driven')
            period=tasks(i).taskPeriod;
            set_param(subsys,'SystemSampleTime',num2str(period));
            set_param(subsys,'ScheduleAs','Periodic partition');
        else
            set_param(subsys,'ScheduleAs','Aperiodic partition');
        end
    end
    Simulink.BlockDiagram.arrangeSystem(refMdlName);
end


function locAddTask(mgrBlk,tasks)
    allTaskDataParam='AllTaskData';
    allTaskData=get_param(mgrBlk,allTaskDataParam);
    dm=soc.internal.TaskManagerData(allTaskData);
    taskNames=dm.getTaskNames;
    for tskIdx=1:numel(tasks)
        thisTask=tasks(tskIdx);
        if isequal(tskIdx,1)
            if~ismember(thisTask.taskName,taskNames)
                dm.addNewTask(thisTask.taskName,true);
                dm.deleteTask(taskNames);
            end
        else
            dm.addNewTask(thisTask.taskName,true);
        end
        fnames=fieldnames(thisTask);
        for j=1:numel(fnames)
            fName=fnames{j};
            fVal=thisTask.(fName);
            if isnumeric(fVal)
                fVal=num2str(fVal);
            end
            dm.updateTask(thisTask.taskName,...
            fName,fVal);
        end
        set_param(mgrBlk,'AllTaskData',dm.getData);
    end
end


function taskStr=locInitializeTaskStructure
    taskStr=struct('taskName','',...
    'taskType','Event-driven',...
    'taskEvent','<empty>',...
    'taskPeriod','1',...
    'taskPriority','10',...
    'coreNum','0',...
    'dropOverranTasks',false,...
    'taskDurationSource','Dialog',...
    'diagnosticsFile','',...
    'logExecutionData',true,...
    'logDroppedTasks',false,...
    'playbackRecorded',false,...
    'taskDurationData',locGetDefaultTaskDurationData);
end


function dur=locGetDefaultTaskDurationData
    dur=struct('percent','100',...
    'mean','1.0000e-06',...
    'dev','0',...
    'min','1.0000e-06',...
    'max','1.0000e-06');
end


function[out,isSwapped]=locSortArrStruct(in,fieldName)
    tbl=struct2table(in);
    sortedTbl=sortrows(tbl,fieldName);
    out=table2struct(sortedTbl)';
    isSwapped=~isequal(in,out);
end