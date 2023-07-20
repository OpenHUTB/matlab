




classdef WatchpointList<Simulink.Debug.BaseItemList
    methods


        function addObserver(this,newObserver)
            addObserver@Simulink.Debug.BaseItemList(this,newObserver);




            this.updateWatchesAndNotifyObservers();
        end
    end

    methods(Access=protected)


        function reactToModelLoad(this,modelName)


            reactToModelLoad@Simulink.Debug.BaseItemList(this,modelName);

            modelHandle=get_param(modelName,'Handle');



            add_engine_event_listener(modelHandle,'EngineSimStatusPaused',...
            @(blockDiagram,unused2)this.updateWatchesAndNotifyObservers(blockDiagram.getFullName()));


            add_engine_event_listener(modelHandle,'EngineSimStatusTerminating',...
            @(blockDiagram,unused2)this.refreshAndClearWatchValues(blockDiagram.getFullName()));
        end
    end

    methods
        function updateWatchesAndNotifyObserversSFX(this,varargin)
            updateWatchesAndNotifyObservers(this,varargin)
        end
    end
    methods(Access=private)

        function updateWatchesAndNotifyObservers(this,varargin)
            if nargin>1
                mdlName=varargin{1};
            else



                mdlName='';
            end

            allWatchpoints=this.getActiveItems();

            for i=1:numel(allWatchpoints)
                watchpoint=allWatchpoints{i};
                if isempty(mdlName)||watchpoint.belongsToModel(mdlName)
                    watchpoint.updateValue();
                end
            end

            this.notifyObserversListUpdated();
        end

        function refreshAndClearWatchValues(this,mdlName)




            this.updateWatchesAndNotifyObservers(mdlName);

            allWatchpoints=this.getActiveItems();

            for i=1:numel(allWatchpoints)
                watchpoint=allWatchpoints{i};
                if watchpoint.belongsToModel(mdlName)
                    watchpoint.clearValue();
                end
            end







        end
    end


    methods(Static)
        function out=getInstance()
mlock
            persistent instance
            if isempty(instance)
                instance=Simulink.Debug.WatchpointList();
            end
            out=instance;
        end

        function watchList=getAllWatchpoints()
            instance=Simulink.Debug.WatchpointList.getInstance();
            watchList=instance.getAllItems();
        end

        function activeWatchList=getActiveWatchpoints()
            instance=Simulink.Debug.WatchpointList.getInstance();
            activeWatchList=instance.getActiveItems();
        end

        function addWatchpointToList(watchpoint)
            instance=Simulink.Debug.WatchpointList.getInstance();
            instance.addItemToList(watchpoint);
        end

        function removeWatchpointFromList(watchpoint)
            instance=Simulink.Debug.WatchpointList.getInstance();
            instance.removeItemFromList(watchpoint);
        end

        function notifyInstanceOfModelLoadEvent(modelName)
            instance=Simulink.Debug.WatchpointList.getInstance();
            instance.reactToModelLoad(modelName);
        end

        function notifyInstanceOfModelCloseEvent(modelName)
            instance=Simulink.Debug.WatchpointList.getInstance();
            instance.reactToModelClose(modelName);
        end

        function refreshWatchpointList(modelName)
            instance=Simulink.Debug.WatchpointList.getInstance();
            instance.updateWatchesAndNotifyObservers(modelName);
        end

        function exportWatchesToMATFile(matFilePath)
            import Simulink.Debug.*;
            watches=WatchpointList.getAllWatchpoints();

            if exist(matFilePath,'file')
                save(matFilePath,'watches','-append');
            else
                save(matFilePath,'watches');
            end
        end

        function importWatchesFromMATFile(matFilePath)
            Simulink.Debug.WatchpointList.deleteAllWatchpoints();

            instance=Simulink.Debug.WatchpointList.getInstance();


            matFileContents=load(matFilePath);



            instance.loadItems(matFileContents.watches);
        end

        function deleteAllWatchpoints()
            instance=Simulink.Debug.WatchpointList.getInstance();
            instance.deleteAllItems();
        end
    end
end
