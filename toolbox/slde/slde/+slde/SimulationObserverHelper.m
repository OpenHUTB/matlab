classdef SimulationObserverHelper<handle


    methods(Access={?simevents.SimulationObserver})
        function obj=SimulationObserverHelper(modelName,modelObs)


            if(~slde.isDesModel(modelName))
                return;
            end

            mHdl=get_param(modelName,'handle');


            obj.fModelName=modelName;
            obj.fModelRT=simevents.ModelRoot.get(mHdl);
            obj.fReadyToRun=false;
            obj.fModelObs=modelObs;


            obj.fRunningListener=Simulink.listener(...
            mHdl,'EngineSimStatusRunning',@obj.simRunningHdler);
            obj.fPauseListener=Simulink.listener(...
            mHdl,'EngineSimStatusPaused',@obj.simPausedHdler);
            obj.fTerminatingListener=Simulink.listener(...
            mHdl,'EngineSimStatusTerminating',@obj.simTerminatingHdler);
        end

        function mName=getModelName(obj)

            mName=obj.fModelName;
        end

        function addBlockNotification(obj,blkPath)

            if~isKey(obj.fBlkPathToHdlsMap,blkPath)
                blk=obj.fModelRT.getBlock(get_param(blkPath,'Handle'));
                numStorages=length(blk.Storage);
                StorageObservers=cell(1,numStorages);
                for m=1:numStorages
                    StorageObservers(m)={slde.SimulationStorageObserverHelper(...
                    obj,obj.fModelObs,blk,...
                    blk.Storage(m),m)};
                end
                obj.fBlkPathToHdlsMap(blkPath)=StorageObservers;
            end
        end
        function removeBlockNotification(obj,blkPath)

            StorageObservers=obj.fBlkPathToHdlsMap(blkPath);
            for m=1:length(StorageObservers)
                StorageObservers(m).destroyListeners;
            end
            remove(obj.fBlkPathToHdlsMap,blkPath);
        end

        function evcal=getEventCalendars(obj)

            evcal=obj.fModelRT.getEventCalendars;
        end

        function allBlkPaths=getAllBlockWithStorages(obj)

            allBlkPaths={};
            evcal=obj.fModelRT.getEventCalendars;
            for k=1:length(evcal)
                blks=evcal(k).BlocksInSystem;
                for m=1:length(blks)
                    if(~isempty(blks(m).Storage))
                        allBlkPaths(end+1)={blks(m).BlockPath};
                    end
                end
            end
        end

        function blkHandle=getHandleToBlock(obj,blkPath)

            assert(obj.fReadyToRun);
            blkHandle=obj.fModelRT.getBlock(get_param(blkPath,'Handle'));
        end
        function storagesForBlock=getHandlesToBlockStorages(obj,blkPath)

            assert(obj.fReadyToRun);
            storagesForBlock=obj.fModelRT.getBlock(get_param(blkPath,'Handle')).Storage;
        end
    end
    methods(Access={?slde.SimulationStorageObserverHelper})
        function evData=getCurrentEntityAndEvent(obj,blkHdl)

            evData=obj.fEventData;
        end
    end

    properties(Access=private)
        fModelName=''
        fModelRT=[]
        fModelObs=[]
        fEventData=[]

        fReadyToRun=false
        fBlkPathToHdlsMap=[]
        fEventCalendarHandles=[]
        fEventCalendarListeners=[]
        fAllBlkPaths={}

        fPauseListener=[]
        fRunningListener=[]
        fTerminatingListener=[]
    end

    methods(Access=private)
        function simRunningHdler(obj,~,~)


            if~obj.fReadyToRun
                obj.fModelRT.initRunTimeData;
                obj.fEventData=simevents.EventData(get_param(obj.fModelName,'handle'));

                if~isempty(obj.fModelObs.notifyEventCalendarEvents())
                    notifyEvt=obj.fModelObs.notifyEventCalendarEvents();
                else
                    notifyEvt=false;
                end
                blkPaths=obj.fModelObs.getBlocksToNotify();
                notifyAll=~isempty(blkPaths)&&ischar(blkPaths)&&strcmp(blkPaths,'ALL');

                if notifyEvt||notifyAll
                    try
                        evcal=obj.fModelRT.getEventCalendars;
                        obj.fEventCalendarHandles=evcal;
                    catch ex
                        if strcmp(ex.identifier,'SimulinkDiscreteEvent:mcos:InvalidSystem')
                            return;
                        end
                    end
                end


                if notifyEvt
                    for k=1:length(evcal)
                        fObs=obj.fModelObs;
                        l=addlistener(evcal(k),'PreExecute',@fObs.preExecute);
                        obj.fEventCalendarListeners=[obj.fEventCalendarListeners,l];
                    end
                end

                obj.fBlkPathToHdlsMap=containers.Map;

                if~isempty(blkPaths)
                    if notifyAll
                        for k=1:length(evcal)
                            blks=evcal(k).BlocksInSystem;
                            for m=1:length(blks)
                                obj.fAllBlkPaths(end+1)={blks(m).BlockPath};
                            end
                        end
                        blkPaths=obj.fAllBlkPaths;
                    end
                    for k=1:length(blkPaths)
                        obj.addBlockNotification(blkPaths{k});
                    end
                end

                obj.fReadyToRun=true;


                obj.fModelObs.simStarted();
            else

                obj.fModelObs.simResumed();
            end
        end
        function simPausedHdler(obj,~,~)


            obj.fModelObs.simPaused();
        end
        function simTerminatingHdler(obj,~,~)



            obj.fModelObs.simTerminating();

            try

                if~isempty(obj.fBlkPathToHdlsMap)
                    blkPaths=obj.fBlkPathToHdlsMap.keys;
                    for k=1:length(blkPaths)
                        obj.removeBlockNotification(blkPaths{k});
                    end
                    obj.fBlkPathToHdlsMap=[];
                end

                for k=1:length(obj.fEventCalendarListeners)
                    delete(obj.fEventCalendarListeners(k));
                end
            catch me
            end

            obj.fEventCalendarListeners=[];
            obj.fEventCalendarHandles=[];

            obj.fReadyToRun=false;
        end
    end
end

