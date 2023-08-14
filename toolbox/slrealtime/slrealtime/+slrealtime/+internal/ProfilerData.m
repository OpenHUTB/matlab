classdef ProfilerData<matlab.mixin.SetGet




    properties(SetAccess=private,GetAccess=public)
        TargetName;
        ModelInfo;
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        ProfileInfo;
        TaskInfo;
        ProfileRawData;
        ExecutionProfile;
        ThreadTrace;
        EventTrace;
        DebugLog;
    end

    methods
        function obj=ProfilerData(tg,appDir,appName)
            narginchk(2,3);
            validateattributes(tg,{'slrealtime.Target'},{},1);
            validateattributes(appDir,{'string','char'},{},1);
            if nargin==3
                validateattributes(appName,{'string','char'},{},1);
            else
                appName=tg.getLastApplication;
            end

            obj.TargetName=tg.TargetSettings.name;
            [obj.ProfileRawData,obj.ThreadTrace,obj.EventTrace,...
            obj.ModelInfo,obj.TaskInfo,obj.ProfileInfo,obj.DebugLog]=...
            locGetData(tg,appDir);
            if~isempty(obj.ProfileRawData)
                obj.ExecutionProfile=locProcessDataUnify(appName,...
                obj.ProfileRawData,obj.ModelInfo.ModelName,obj.ProfileInfo);
            end
        end

        function display(this)%#ok<DISPLAY>
            fprintf('Code execution profiling data for model %s.\n',...
            this.ModelInfo.ModelName);
            this.report;
            this.plot;
        end
        function report(this)


            if~isempty(this.ExecutionProfile)
                this.CreateWorkspaceVariable;
                this.ExecutionProfile.report;
            end
        end

        function plot(this)
            if~isempty(this.ExecutionProfile)
                this.ExecutionProfile.schedule();
            end
        end
    end

    methods(Hidden)

        function CreateWorkspaceVariable(this)


            varName='';


            if bdIsLoaded(this.ModelInfo.ModelName)
                varName=get_param(this.ModelInfo.ModelName,...
                'CodeExecutionProfileVariable');
            else

                if exist(this.ModelInfo.ModelName,'file')==4
                    load_system(this.ModelInfo.ModelName);
                    varName=get_param(this.ModelInfo.ModelName,...
                    'CodeExecutionProfileVariable');
                    close_system(this.ModelInfo.ModelName,0);
                end
            end





            if isempty(varName)
                varName='slrtExecutionProfile';
            end


            assignin('base',varName,this.ExecutionProfile);
        end

    end
end



function[mdltrace,threadtrace,eventtrace,mdl_info,task_info,prof_info,debug_info]=locGetData(tg,appDir)


    disp(getString(message('slrealtime:profiling:TransferingData')));

    task_info=[];

    tmpDir=tempname;
    mkdir(tmpDir);
    currDir=pwd;
    cdCleanup=onCleanup(@()cd(currDir));
    dirCleanup=onCleanup(@()rmdir(tmpDir,'s'));
    cd(tmpDir);
    locCopyFiles(tg,appDir);
    cd("profiler");

    if isfile('slrealtime_task_info.m')
        task_info=slrealtime_task_info();
    end


    if isfile('traceinfo.m')
        debug_info=traceinfo();
    else
        debug_info.Frequency=1e9;
        warning(message('slrealtime:profiling:DefaultFrequency'));
    end


    if isfile('profiling_info.mat')
        prof_info=load('profiling_info.mat');
        mdl_info.ModelName=prof_info.lGlobalRegistry.Model;
    else
        prof_info=[];
        mdl_info.ModelName='';
        warning(message('slrealtime:profiling:NoProfilingMATFile','profiling_info.mat'));
    end


    mdl_info.MATLABRelease=['R',version('-release')];


    mdltrace=locGetModelTrace(str2double(debug_info.Frequency));


    eventtrace=slrealtime.internal.eventTrace('EventTrace.bin',str2double(debug_info.Frequency));

    threadtrace=slrealtime.internal.threadTrace('ThreadTrace.bin',str2double(debug_info.Frequency));
end

function mdltrace=locGetModelTrace(freq)


    mdltrace=[];
    modelTraceFile='ModelTrace.bin';
    RECORD_SIZE=28;

    if~isfile(modelTraceFile)
        error(message('slrealtime:profiling:FileNotFound',modelTraceFile));
    end

    filesize=0;
    fileattr=dir(modelTraceFile);
    if~isempty(fileattr)
        filesize=fileattr.bytes;
    end
    if filesize==0



        warning(message('slrealtime:profiling:NoData'));
        return;
    end

    fid=fopen(modelTraceFile,'rb');
    nRec=fix(filesize/RECORD_SIZE);
    rawdata=fread(fid,nRec*RECORD_SIZE,'*uint8');
    fclose(fid);

    reader=slrealtime.internal.binReader('uint32','uint32',...
    'uint32','uint32','uint32','single','uint32');
    [event,stampl,stamph,taskh,cpu,mdltime,state]=reader.decode(rawdata);
    t=bitshift(uint64(stamph),32)+uint64(stampl);
    t=[0;diff(t)];
    t=double(t)/freq;



    mdltrace=[0,2,freq,0,0,0,0,0];
    mdltrace=[mdltrace;...
    [double(event),double(cpu),t,double(mdltime),...
    double(stamph),double(stampl),double(taskh),double(state)]];






    i=find(mdltrace(:,1)==101,1);
    if i>2
        mdltrace(2:i-1,:)=[];
    end
end


function locCopyFiles(tg,appDir)

    tg.copyfolder(strcat(appDir,"/profiler"));


    srcFile=strcat(appDir,"/misc/slrealtime_task_info.m");
    destFile="profiler/slrealtime_task_info.m";
    tg.receiveFile(srcFile,destFile);


    srcFile=strcat(appDir,"/misc/profiling_info.mat");
    destFile="profiler/profiling_info.mat";
    tg.receiveFile(srcFile,destFile);

end

function executionProfile=locProcessDataUnify(appName,rawdata,model,profiling_info)

    if isempty(rawdata)
        error(message('slrealtime:profiling:NoData'));
    end
    profileInfo.idNBits=32;
    profileInfo.tNBits=64;
    profileInfo.bufferIncrement=uint64(10000);
    profileInfo.doDestroy=0;
    profileInfo.isRealTime=true;
    profileInfo.summaryOnly=false;
    if exist(model,'file')==4
        open_system(model);
    end
    MAXTASKID=132;
    disp(getString(message('slrealtime:profiling:ProcessingDataHost')));
    disp(' ');


    xPCprofData=locProfileUnpackUnify(rawdata,MAXTASKID);
    TimerTicksPerSecond=xPCprofData.TimerTicksPerSecond;

    identifierClass=sprintf('uint%d',profileInfo.idNBits);
    timerClass=sprintf('uint%d',profileInfo.tNBits);

    timerDataTyped=feval(timerClass,xPCprofData.timerValues);
    sectionIdsTyped=feval(identifierClass,xPCprofData.sectionIds);

    sectionIdsForTasks=unique(xPCprofData.sectionIds,'stable');
    sectionIdsForTasks=sectionIdsForTasks(sectionIdsForTasks>0);
    sectionIdsForTasks=sectionIdsForTasks(sectionIdsForTasks<=MAXTASKID);


    for i=1:length(sectionIdsForTasks)
        count=0;
        btcmpsectionIds=ibtcmp(sectionIdsForTasks(i),profileInfo.idNBits);
        for j=1:length(xPCprofData.sectionIds)
            if(xPCprofData.sectionIds(j)==sectionIdsForTasks(i))
                count=count+1;
            else
                if(xPCprofData.sectionIds(j)==btcmpsectionIds)
                    count=count-1;
                end
            end
            if(count>1||count<-1)
                warning(['An unmatched event ',num2str(sectionIdsForTasks(i))...
                ,' at row ',num2str(j)]);
                error(message('slrealtime:profiling:UnmatchingEvent'));
            end
        end
    end

    minContextSwitch=500;


    buildDir='';
    if~isempty(model)&&exist(model)==4 %#ok 
        bDirInfo=RTW.getBuildDir(model);
        buildDir=bDirInfo.BuildDirectory;
    end

    sectionIdsForTaskSuspend=locProfileGetSuspendSection_ids(profiling_info);

    codeInstrFolder='';
    if~isempty(model)



        codeInstrFolder=coder.internal.getSubFolderForSlrtProfilingBuild;
    end


    app=slrealtime.Application(appName);
    taskinfo=app.extract('/misc/taskinfo.mat');
    taskinfo=load(taskinfo{1,2});
    taskinfo=taskinfo.taskinfo;

    [executionProfile,~,~]=coder.profile.executionTimeAnalyze...
    (timerDataTyped,sectionIdsTyped,...
    'summaryOnly',profileInfo.summaryOnly,...
    'coreNumbers',xPCprofData.coreNum,...
    'isRealTime',profileInfo.isRealTime,...
    'taskSectionIdentifiers',sectionIdsForTasks,...
    'taskSuspendIdentifiers',sectionIdsForTaskSuspend,...
    'minimumContextSwitchTime',uint64(minContextSwitch),...
    'timerTicksPerSecond',TimerTicksPerSecond,...
    'instrumentedCodeFolder',codeInstrFolder,...
    'codeFolder',buildDir,...
    'simulationTimes',xPCprofData.simTimes,...
    'threadIdentifiers',xPCprofData.threadIds,...
    'documentationLinkParameters',...
    {{'toolbox','rtw','helptargets.map'},'sil_pil_code_exe_profile'},...
    'MaxTimerAdjustment',TimerTicksPerSecond*10);

    executionProfile.SimulationComponent=model;
    executionProfile.SimulationComponentSID=model;
    executionProfile.ModelForProfilingTopSettings=model;
    executionProfile.OriginalComponentName=model;

end

function xPCprofData=locProfileUnpackUnify(rawdata,MAXTASKID)


    nonMdlZeroEvents=find(rawdata(:,4)~=0);
    realstartEventIdx=nonMdlZeroEvents(1);
    for i=nonMdlZeroEvents(1)-1:-1:1
        if(rawdata(i,1)==1)&&(rawdata(i,8)==1)
            realstartEventIdx=i;
            break;
        end
    end
    if(realstartEventIdx~=nonMdlZeroEvents(1))
        rawdata(2:realstartEventIdx-1,:)=[];
    end


    rawdata(:,2)=rawdata(:,2)+1;
    rawdata(1,2)=rawdata(1,2)-1;



    COLUMN=struct('EVENT',1,'CPU',2,'TIMEDIF',3,'MODELTIME',4,'HIGHTIME',5,'LOWTIME',6,'THREADID',7);
    TASKS=struct('MAXTHREADID',64,'FIRSTIRQ',101,'LASTIRQ',132);


    firstdatarow=rawdata(1,2);
    rawdatasize=size(rawdata);
    rowend=rawdatasize(1);
    if(firstdatarow+2)>rowend
        error(message('slrealtime:profiling:NoData'));
    end


    xPCprofData.TimerTicksPerSecond=rawdata(1,3);


    lastevent=rawdata(rowend,COLUMN.EVENT);
    i=(rowend-1);
    if(((lastevent>=TASKS.FIRSTIRQ)&&(lastevent<=TASKS.LASTIRQ))...
        ||((bitcmp(lastevent,'uint32')>=TASKS.FIRSTIRQ)&&(bitcmp(lastevent,'uint32')<=TASKS.LASTIRQ)))
        for i=(rowend-1):-1:(firstdatarow+1)
            if bitcmp(rawdata(i,COLUMN.EVENT),'uint32')~=lastevent&&rawdata(i,COLUMN.EVENT)~=lastevent
                break;
            end
        end
    end

    rowend=min(i+2,rowend);
    rawdata=rawdata(1:rowend,:);


    xPCprofData.numCPU=rawdata(1,2);


    xPCprofData.sectionIds=rawdata(firstdatarow:rowend,COLUMN.EVENT);
    xPCprofData.timerValues=bitshift(uint64(rawdata(firstdatarow:rowend,COLUMN.HIGHTIME)),32)+...
    uint64(rawdata(firstdatarow:rowend,COLUMN.LOWTIME));
    xPCprofData.coreNum=rawdata(firstdatarow:rowend,COLUMN.CPU);
    xPCprofData.simTimes=rawdata(firstdatarow:rowend,COLUMN.MODELTIME);

    numCols=length(rawdata(1,:));
    xPCprofData.threadIds=[];
    if numCols>=COLUMN.THREADID
        xPCprofData.threadIds=rawdata(firstdatarow:rowend,COLUMN.THREADID);
    end

end


function suspendSectionIds=locProfileGetSuspendSection_ids(profiling_info)
    suspendSectionIds=[];

    if isempty(profiling_info)
        return;
    end

    lGlobalRegistry=profiling_info.lGlobalRegistry;
    [globalAddressOffsets,registries]=...
    lGlobalRegistry.getRegistryInfo();
    for i=1:length(registries)
        reg=registries{i};
        allOffsets=globalAddressOffsets{i};
        if~allOffsets.isKey(uint32(coder_profile_ProbeType.TASK_TIME_PROBE))
            continue;
        end
        offset=allOffsets(uint32(coder_profile_ProbeType.TASK_TIME_PROBE));
        sectionIdsMutexTake=reg.getSectionIdsForCodeName(...
        coder_profile_ProbeType.TASK_TIME_PROBE,...
        'rtw_xpc_mutex_take');
        suspendSectionIds=[
        suspendSectionIds(:)
        sectionIdsMutexTake+offset];
    end
end

function y=ibtcmp(x,nBits)

    if nargin<2
        nBits=8;
    end

    y=(2^nBits-1)-x;

end
