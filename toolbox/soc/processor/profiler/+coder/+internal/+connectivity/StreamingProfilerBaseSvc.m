classdef StreamingProfilerBaseSvc




    properties(Access=public)
        topModelName;
    end
    methods(Static)
        function ret=isStreamingProfilerAppSvcNeeded(h)
            if isa(h,'Simulink.ConfigSet')||...
                isa(h,'Simulink.ConfigSetRef')
                mdl=get_param(h.getModel,'Name');
            elseif isa(h,'char')||isa(h,'double')
                mdl=h;
            else
                ret=false;
                return
            end
            isSupportedTarget=~isempty(mdl)&&...
            codertarget.attributes.supportTargetServicesFeature(mdl,...
            'StreamingProfilerAppSvc');
            isProfilerOn=isequal(get_param(mdl,'CodeExecutionProfiling'),'on');
            hCS=getActiveConfigSet(mdl);
            isKernelProfiler=...
            codertarget.profile.internal.isKernelProfilingEnabled(hCS);
            ret=isSupportedTarget&&isProfilerOn&&~isKernelProfiler;
        end
        function dataMat=getDataFile(mdl)
            bdirObj=RTW.getBuildDir(mdl);
            dataMatfile=fullfile(bdirObj.BuildDirectory,'tasks.mat');
            if isequal(exist(dataMatfile,'file'),2)
                dataMat=load(dataMatfile);
            else
                dataMat=[];
            end
        end
        function res=getBaseRatePriority(mdl)
            ctd=get_param(mdl,'CoderTargetData');
            if isfield(ctd,'RTOS')&&~isequal(ctd.RTOS,'Baremetal')
                res=eval(ctd.RTOSBaseRateTaskPriority);
            else
                res=40;
            end
        end
        function cores=getTaskCores(mdl)
            import coder.internal.connectivity.*
            if StreamingProfilerBaseSvc.isSoCBEnabled(mdl)
                cores=soc.internal.getActiveCoresFromTaskManager(mdl);
            else
                hCS=getActiveConfigSet(mdl);
                if isequal(get_param(mdl,'EnableConcurrentExecution'),'on')&&...
                    isequal(get_param(mdl,'ConcurrentTasks'),'on')
                    numCores=codertarget.targethardware.getNumberOfCores(hCS);
                    cores=0:numCores-1;
                else
                    cores=0;
                end
            end
        end
        function res=getProfileTimerResolution(mdl)
            hCS=getActiveConfigSet(mdl);
            attr=codertarget.attributes.getTargetHardwareAttributes(hCS);
            if isnan(str2double(attr.Profiler.TimerTicksPerS))
                res=feval(attr.Profiler.TimerTicksPerS,hCS);
            else
                res=eval(attr.Profiler.TimerTicksPerS);
            end
        end
        function res=isSoCBEnabled(mdl)
            try
                res=codertarget.utils.isESBEnabled(mdl);
            catch
                res=false;
            end
        end
        function probes=getTaskProbes(mdl)
            probes=[];
            bdirObj=RTW.getBuildDir(mdl);
            bdir=bdirObj.BuildDirectory;
            infoFile=fullfile(bdir,'instrumented','profiling_info.mat');
            if~isequal(exist(infoFile,'file'),2),return;end
            profInfo=load(infoFile);
            probes=[profInfo.topLevelRegistry.Probes{:}];
            idx=ismember(probes(1:2:end),'TASK_TIME_PROBE');
            probes=[profInfo.topLevelRegistry.Probes{idx}];
            probes=probes(2:2:end);
        end
        function probes=updateProbeNames(mdl,probes)
            import coder.internal.connectivity.*
            if~StreamingProfilerBaseSvc.isSoCBEnabled(mdl),return;end
            [tNames,tPeriods,tVisible]=soc.internal.getTimerDrivenTasks(mdl);
            for i=1:numel(tNames)
                tNames{i}=soc.internal.mapToActualName(mdl,tNames{i});
            end
            if isequal(numel(tNames),numel(tPeriods))


                probePeriods=cellfun(@(x)(([x{5},x{6}])),...
                probes,'UniformOutput',false);
                for i=1:numel(tNames)





                    idx=find(cellfun(@(x)...
                    (isequal(x,tPeriods{i})),probePeriods),1);
                    if~isempty(idx)




                        probePeriods{idx}=[NaN,NaN];
                        probePeriods{idx+1}=[NaN,NaN];
                        probes{idx}{3}=tNames{i};
                        if~tVisible(i)
                            probes(idx+1)=[];
                            probes(idx)=[];


                            probePeriods=cellfun(@(x)(([x{5},x{6}])),...
                            probes,'UniformOutput',false);
                        end
                    end
                end
            end
        end
        function tasks=createTaskArray(mdl,probes)
            import coder.internal.connectivity.*
            hCS=getActiveConfigSet(mdl);
            ctd=get_param(mdl,'CoderTargetData');
            numOfCores=codertarget.targethardware.getNumberOfCores(hCS);
            dataMat=StreamingProfilerBaseSvc.getDataFile(mdl);
            isPosPriority=isequal(get_param(hCS,'PositivePriorityOrder'),'on');
            factor=power(-1,(1+2*isPosPriority));
            tmp=[probes{:}];
            sampleTimes=unique([tmp{5,:}]);
            synchonousSampleTime=sampleTimes(sampleTimes>0&~isinf(sampleTimes));
            cores=StreamingProfilerBaseSvc.getTaskCores(mdl);
            tasks=[];
            for i=1:numel(probes)
                probeName=probes{i}{3};
                probeRate=probes{i}{5};
                if isequal(get_param(mdl,'EnableConcurrentExecution'),'on')&&...
                    isequal(get_param(mdl,'ConcurrentTasks'),'on')
                    affinity=uint32(cores);
                else
                    affinity=uint32(0);
                end
                if StreamingProfilerBaseSvc.isSoCBEnabled(mdl)
                    affinity=soc.internal.getAffinityForTaskManagerTasks(mdl,...
                    probeName);
                end
                if isinf(probeRate)
                    priority=StreamingProfilerBaseSvc.getBaseRatePriority(mdl);
                    if~isempty(dataMat)
                        [found,idx]=ismember(probeName,{dataMat.taskVec(:).name});
                        if found
                            priority=dataMat.taskVec(idx).priority;
                            affinity=dataMat.taskVec(idx).affinity;
                        end
                    end
                else
                    if probeRate>0
                        priority=StreamingProfilerBaseSvc.getBaseRatePriority(mdl)+...
                        factor*(probeRate/synchonousSampleTime(1));
                    end
                end
                t=StreamingProfilerBaseSvc.constructTask(mdl,probes{i},...
                ctd,numOfCores,affinity,priority);
                tasks=StreamingProfilerBaseSvc.insertTask(t,tasks);
            end
        end
        function task=constructTask(mdl,probe,ctd,numCores,affinity,priority)
            import coder.internal.connectivity.*
            task=[];
            probeID=probe{1};
            probeName=probe{3};


            if(StreamingProfilerBaseSvc.isSoCBEnabled(mdl)&&...
                contains(probeName,'_step')||contains(probeName,'_drop'))
                return;
            elseif isequal(probeName,strcat(mdl,'_terminate'))




                return
            elseif isequal(probeName,strcat(mdl,'_initialize'))
                if isfield(ctd,'Profiler')&&isfield(ctd.Profiler,'LogModelInit')&&...
                    ctd.Profiler.LogModelInit
                    cores=uint32(0:numCores-1);
                    task=soc.profiler.Task(probeName,probeID,priority,cores);
                end
            else
                task=soc.profiler.Task(probeName,probeID,priority,affinity);
            end
        end
        function taskArray=insertTask(task,taskArray)
            if isempty(taskArray)&&~isempty(task)
                taskArray=task;
            elseif~isempty(task)
                taskArray(end+1)=task;
            end
        end
    end
end
