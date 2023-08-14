classdef BuildStatusDB<handle




    properties
TopMdlName
StatusTable
TopProgressBarValue
NumWkInUse
NumWks
NumTotalMdls
TargetType
OptNumWorkers
TotalElapsedTime

BuildStatusTableChannel
TopProgressBarChannel
PoolUsageChannel
    end

    methods
        function obj=BuildStatusDB(topMdlName,mdlRefNames,numWks,targetType,iBuildArgs)
            obj.TopMdlName=topMdlName;

            if includeTopMdl(topMdlName,targetType,iBuildArgs)
                mdlNames=[mdlRefNames,{topMdlName}];
            else
                mdlNames=mdlRefNames;
            end
            mdlNames=unique(mdlNames);



            stats=struct('status',DAStudio.message('RTW:buildStatus:Blocked'),...
            'progress',0,...
            'buildTime','-');
            initalStats=cell(1,length(mdlNames));
            [initalStats{:}]=deal(stats);
            if isempty(initalStats)
                obj.StatusTable=[];
            else
                obj.StatusTable=containers.Map(mdlNames,initalStats);
            end

            obj.TopProgressBarValue=0;
            obj.NumWkInUse=0;
            obj.NumWks=numWks;
            obj.NumTotalMdls=length(mdlNames);
            obj.TargetType=targetType;
            obj.OptNumWorkers=0;
            obj.TotalElapsedTime=0;

            channelPrefix=['/BuildStatusUI/',topMdlName,'/',targetType];

            obj.BuildStatusTableChannel=[channelPrefix,'/updateBuildStatusTable'];
            obj.TopProgressBarChannel=[channelPrefix,'/topProgressBar'];
            obj.PoolUsageChannel=[channelPrefix,'/poolUsage'];
        end

        function updateBuildStatusTable(obj,mdlRefNames,varargin)










            idx=ismember(mdlRefNames,obj.StatusTable.keys);
            mdlRefNames=mdlRefNames(idx);

            if isempty(mdlRefNames)
                return;
            end

            for k=1:length(mdlRefNames)
                for i=1:2:(nargin-3)
                    field=varargin{i};
                    value=varargin{i+1};

                    tmp=obj.StatusTable(mdlRefNames{k});
                    tmp.(field)=value;
                    obj.StatusTable(mdlRefNames{k})=tmp;
                end
            end

            if isequal(varargin,{'status',DAStudio.message('RTW:buildStatus:Scheduled')})
                for k=1:length(mdlRefNames)
                    msg.mdlRefName=mdlRefNames{k};
                    msg.status=varargin{2};
                    msg.progress=0;
                    msg.buildTime='-';

                    message.publish(obj.BuildStatusTableChannel,msg);
                end
            else
                for k=1:length(mdlRefNames)
                    msg.mdlRefName=mdlRefNames{k};
                    msg.status=obj.StatusTable(mdlRefNames{k}).status;
                    msg.progress=obj.StatusTable(mdlRefNames{k}).progress;
                    if ischar(obj.StatusTable(mdlRefNames{k}).buildTime)
                        msg.buildTime=obj.StatusTable(mdlRefNames{k}).buildTime;
                    else
                        msg.buildTime=datestr(obj.StatusTable(mdlRefNames{k}).buildTime/(24*60*60),'HH:MM:SS');
                    end
                    message.publish(obj.BuildStatusTableChannel,msg);
                end
            end
        end

        function updateTopProgressBar(obj,nFinished)
            obj.TopProgressBarValue=nFinished;
            message.publish(obj.TopProgressBarChannel,obj.TopProgressBarValue);
        end

        function updateBuildStatusTableFromWorkers(obj,info)





            iMdlRefName=info{1};
            obj.updateBuildStatusTable(iMdlRefName,info{2:end});
        end

        function updateWkInUseFromWorkers(obj,info)


            switch info{1}
            case 'addOne'
                obj.NumWkInUse=obj.NumWkInUse+1;
            case 'minusOne'
                obj.NumWkInUse=obj.NumWkInUse-1;
            end

            msg.numWkInUse=obj.NumWkInUse;
            msg.option='updateWorkerInUse';
            message.publish(obj.PoolUsageChannel,msg);
        end

        function updateInfoFromWorkersCB(obj,msg)




            op=msg{1};
            info=msg{2};
            switch op
            case 'updateBuildStatusTable'
                obj.updateBuildStatusTableFromWorkers(info);
            case 'updateWkInUse'
                obj.updateWkInUseFromWorkers(info);
            end
        end

        function updateOptNumWorkers(obj,optNumWorkers)
            obj.OptNumWorkers=optNumWorkers;
            msg.optNumWorkers=optNumWorkers;
            msg.option='updateOptNumWorkers';
            message.publish(obj.PoolUsageChannel,msg);
        end

        function ctrlTotalElapsedTimer(obj,ctrl)
            persistent tstart;

            msg.option='ctrlTotalElapsedTimer';
            msg.control=ctrl;
            message.publish(obj.PoolUsageChannel,msg);

            switch ctrl
            case 'startTimer'
                tstart=clock();
            case 'stopTimer'
                tstop=clock();


                obj.TotalElapsedTime=etime(tstop,tstart)+1;
            end
        end

    end
end




function tf=includeTopMdl(topMdlName,targetType,iBuildArgs)
    tf=false;
    if isempty(iBuildArgs)
        return;
    end

    switch targetType
    case 'SIM'
        if~iBuildArgs.IsUpdatingSimForRTW
            if iBuildArgs.UpdateTopModelReferenceTarget
                tf=true;
            else
                simMode=get_param(topMdlName,'SimulationMode');
                if strcmp(simMode,'normal')||strcmp(simMode,'accelerator')
                    tf=false;
                else
                    tf=true;
                end
            end
        elseif~iBuildArgs.ModelReferenceRTWTargetOnly&&...
            iBuildArgs.UpdateTopModelReferenceTarget
            tf=true;
        else
            tf=false;
        end

    case 'RTW'
        if iBuildArgs.XilInfo.IsModelBlockXil


            tf=false;
        else
            tf=true;
        end
    end
end

