function out=socHardwareUsage(modelName,SDIRun,varargin)




























    import soc.internal.connectivity.*

    suppressPlot=false;
    narginchk(2,3);
    if(nargin==3)
        opt=string(varargin{1});
        suppressPlot=isequal(lower(opt),"suppressplot");
        if~suppressPlot

            msg=['If you pass the third argument to the function '...
            ,'''socHardwareUsage'', it must be ''SuppressPlot''.'];
            assert(false,msg);
        end
    end

    if~isequal(exist(modelName,'file'),4)
        error(message('soc:utils:ModelDoesNotExist',modelName));
    end

    run=soc.internal.sdi.getRun(SDIRun);
    if isempty(run)
        errID='soc:scheduler:TesterSDIRunNotFound';
        error(message(errID,SDIRun));
    end
    runID=run.id;

    mgrBlks=getTaskManagerBlock(modelName);
    if~iscell(mgrBlks),mgrBlks={mgrBlks};end
    out=[];
    for i=1:numel(mgrBlks)
        if isequal(get_param(mgrBlks{i},'EnableTaskSimulation'),'on')
            r=processPU(modelName,mgrBlks{i},runID,suppressPlot);
            out=[out,r];
        end
    end
    if~isempty(out)
        if all(arrayfun(@(x)isempty(x.TaskUsage),out,'UniformOutput',true))

            error(message('soc:scheduler:InvalidCoreData',modelName));
        end
    end
end


function out=processPU(modelName,mgrBlk,runID,suppressPlot)
    import soc.internal.sdi.*
    allTaskData=get_param(mgrBlk,'AllTaskData');
    taskMgrData=soc.internal.TaskManagerData(allTaskData);
    allTaskNames=taskMgrData.getTaskNames;
    pu=locGetPUForTaskManager(mgrBlk);
    if~suppressPlot
        figure('Name',pu,'NumberTitle','off')
        socbCorePlotFigureHdl=gcf;
    end
    numCores=locGetNumOfCoresForTaskManager(mgrBlk);
    for coreIdx=1:numCores
        coreName=locGetCoreName(pu,coreIdx);
        sigNames=getSignalNames(runID);
        coreUsage.Name=coreName;
        if ismember(coreName,sigNames)
            coreSDIData=getSignalData(runID,coreName);
            if isempty(coreSDIData.Data)
                if exist('socbCorePlotFigureHdl','var')&&isvalid(socbCorePlotFigureHdl)
                    close(socbCorePlotFigureHdl);
                end
                error(message('soc:scheduler:InvalidDataForCore',modelName,coreName));
            end
            [used,idle]=soc.internal.sdi.getCoreUsage(coreSDIData);
            totTime=sum(used)+sum(idle);
            coreUsage.PercentUsed=(sum(used)/totTime)*100;
            coreUsage.PercentIdle=(sum(idle)/totTime)*100;
            taskDurations=[];
            for j=1:numel(allTaskNames)
                d=getCoreUsageByTask(coreSDIData,allTaskNames{j});
                taskDurations(j)=sum(d);%#ok<*AGROW>
            end
            runidx=find(taskDurations>0);
            if~isempty(runidx)
                taskDurs=taskDurations(runidx);
                taskLbls=allTaskNames(runidx);
                toPrint={};
                for j=1:numel(taskLbls)
                    percTime=100*taskDurs(j)/totTime;
                    toPrint{j}=[taskLbls{j},' (',num2str(percTime),'%)'];
                end
                clear('taskStruct');
                taskStruct(1,numel(taskLbls))=struct;
                for j=1:numel(taskLbls)
                    taskStruct(j).Task=taskLbls{j};
                    taskStruct(j).PercentUsed=100*taskDurs(j)/totTime;
                end
                coreUsage.TaskUsage=taskStruct;
            else
                coreUsage.PercentUsed=0;
                coreUsage.PercentIdle=100;
                coreUsage.TaskUsage=[];
            end
        else
            coreUsage.PercentUsed=0;
            coreUsage.PercentIdle=100;
            coreUsage.TaskUsage=[];
        end
        out(coreIdx)=coreUsage;
        if~suppressPlot
            figure(socbCorePlotFigureHdl);
            subplot(1,numCores,coreIdx)
            if(coreUsage.PercentIdle==100)
                taskDurs=100;
                toPrint={'Idle (100%)'};
            elseif(coreUsage.PercentIdle==0)
                taskDurs=100*taskDurs/totTime;
            else
                taskDurs=[taskDurs,sum(idle)];
                taskDurs=100*taskDurs/totTime;
                toPrint{end+1}=['Idle (',num2str(taskDurs(end)),'%)'];
            end
            pie(taskDurs,toPrint);
            title(['Core: ',num2str(coreIdx-1)]);
        end
    end
end


function res=locGetNumOfCoresForTaskManager(mgrBlk)
    refMdl=soc.internal.connectivity.getModelConnectedToTaskManager(mgrBlk);
    if isequal(get_param(refMdl,'BlockType'),'ModelReference')
        refMdlName=get_param(refMdl,'ModelName');
        if~bdIsLoaded(refMdlName)
            load_system(refMdlName);
        end
        hCS=getActiveConfigSet(refMdlName);
    else
        hCS=getActiveConfigSet(bdroot(mgrBlk));
    end
    if codertarget.data.isValidParameter(hCS,'Processor.NumberOfCores')
        numCores=codertarget.data.getParameterValue(hCS,'Processor.NumberOfCores');
        res=str2double(numCores);
    else
        hwBoard=get_param(hCS,'HardwareBoard');
        hwBoardData=codertarget.targethardware.getTargetHardware(hwBoard);
        res=hwBoardData.NumOfCores;
    end
end


function pu=locGetPUForTaskManager(mgrBlk)
    refMdl=soc.internal.connectivity.getModelConnectedToTaskManager(mgrBlk);
    if isequal(get_param(refMdl,'BlockType'),'ModelReference')
        refMdlName=get_param(refMdl,'ModelName');
        if~bdIsLoaded(refMdlName)
            load_system(refMdlName);
        end
        hCS=getActiveConfigSet(refMdlName);
    else
        hCS=getActiveConfigSet(bdroot(mgrBlk));
    end
    pu=codertarget.targethardware.getProcessingUnitName(hCS);
end


function coreName=locGetCoreName(procUnitName,coreIdx)
    if isequal(procUnitName,'None')
        coreName=['Core: ',num2str(coreIdx-1)];
    else
        coreName=[procUnitName,':Core',num2str(coreIdx-1)];
    end
end