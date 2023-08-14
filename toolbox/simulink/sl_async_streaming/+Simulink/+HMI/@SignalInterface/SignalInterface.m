



classdef SignalInterface<handle


    properties(Dependent=true,Access=public)


        Model;

    end


    methods


        function val=get.Model(this)
            val=this.Model_;
        end

    end


    methods(Static,Hidden)


        function startStreamingToWeb(repo,mdl,opts)




            if~isfield(opts,'TargetComputer')
                opts.TargetComputer='';
            end

            if~isfield(opts,'SDIOptimizeVisual')
                opts.SDIOptimizeVisual=true;
            end

            if opts.EnableRollback
                stepperInterval=int32(opts.SnapshotInterval);
                stepperNumSteps=int32(opts.NumberOfSteps);
            else
                stepperInterval=int32(0);
                stepperNumSteps=int32(0);
            end

            if isfield(opts,'ModelHandle')
                mdlHandle=opts.ModelHandle;
            else
                mdlHandle=0;
            end

            Simulink.HMI.setRunStartAndStopTime(...
            mdl,...
            opts.StartTime,opts.StopTime,...
            stepperInterval,stepperNumSteps,...
            mdlHandle,...
            opts.TargetComputer,...
            opts.SDIOptimizeVisual);

            Simulink.HMI.startStreamingToWeb(repo,mdl,opts.StartTime,opts.StopTime,opts.TargetComputer);
        end


        function[bpath,label]=getSignalPathAndLabel(blk,portIdx)

            if isa(blk,'Stateflow.State')
                bpath=Simulink.BlockPath(blk.Chart.Path);
                bpath.SubPath=sf('FullName',blk.Id,blk.Chart.Id,'.');
                label=blk.Name;
            elseif isa(blk,'Stateflow.Data')
                bpath=Simulink.BlockPath(blk.Path);
                bpath.SubPath=blk.Name;
                label=blk.Name;
            else
                obj=get_param(blk,'Object');
                bpath=Simulink.BlockPath(obj.getFullName());

                ph=get_param(blk,'PortHandles');
                label=get_param(ph.Outport(portIdx),'Name');
            end

            if isempty(label)
                label=sprintf('%s:%d',get_param(blk,'Name'),portIdx);
            end
        end

    end


    methods(Hidden=true)


        function obj=SignalInterface(mdl)

            obj.Model_=mdl;
        end


        function renameModel(this,newName)

            this.Model_=newName;
        end


        function ret=getWebClientObserversFromSpec(this)




            ret={};
            clients=[];
            if bdIsLoaded(this.Model_)
                clients=get_param(this.Model_,'StreamingClients');
            end
            if isempty(clients)
                return;
            end

            len=clients.Count;
            for idx=1:len
                cnt=get(clients,idx);
                if strcmpi(cnt.ObserverType,'webclient_observer')
                    ret{end+1}=cnt;%#ok<AGROW>
                end
            end
        end
    end


    methods(Hidden=true,Static=true)


        function onModelStart(mdl,opts)


            if~Simulink.sdi.Instance.isRepositoryCreated()
                return
            end

            eng=Simulink.sdi.Instance.engine;

            persistent repo;
            if isempty(repo)
                repo=sdi.Repository(true);
            end

            Simulink.HMI.helperOnModelStart(mdl,eng,repo,opts);


            if~isfield(opts,'TargetComputer')
                opts.TargetComputer='';
            end


            DEFAULT_QUEUES_ONLY=true;
            EXCULDE_DISABLED_QUEUES=true;
            qs=Simulink.AsyncQueue.Queue.getAllQueues(...
            mdl,DEFAULT_QUEUES_ONLY,opts.TargetComputer,EXCULDE_DISABLED_QUEUES);
            isStreaming=~isempty(qs);
            if opts.VisualizeOn&&~opts.CommandLine&&isStreaming
                Simulink.sdi.internal.SLMenus.getSetNewDataAvailable(mdl,true);
            else
                Simulink.sdi.internal.SLMenus.getSetNewDataAvailable(mdl,false);
            end
        end


        function bNotUsed=observerIsNotUsed(obs)

            import Simulink.HMI.*;
            bNotUsed=false;
            try
                if~bdIsLoaded(obs.ObserverParams.ModelName)
                    return;
                end
            catch me %#ok<NASGU>



            end
        end

    end

    properties(Hidden=true)
        Model_;
    end

end
