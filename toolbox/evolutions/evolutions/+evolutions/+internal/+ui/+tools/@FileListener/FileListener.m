classdef FileListener<handle




    properties(Access=protected)
AppController
EventHandler
ChangeListener
    end

    properties(SetAccess=protected)
FilePathMap

FileListChangedListener
ActiveEvolutionChangedListener
    end

    methods
        function obj=FileListener(appController)
            obj.FilePathMap=containers.Map;
            obj.AppController=appController;
            obj.EventHandler=appController.EventHandler;
            obj.ChangeListener=evolutions.internal.FileChangeListener;
            obj.installListeners;
        end

        function delete(obj)

            obj.deleteListeners;

            obj.clearListenerToBaseFiles;
        end

        function installListeners(obj)
            obj.FileListChangedListener=evolutions.internal.session...
            .EventHandler.subscribe('FileListChanged',@obj.fileAddedRemoved);
            obj.ActiveEvolutionChangedListener=...
            listener(obj.EventHandler,'ActiveEvolutionChanged',@obj.activeEvolutionChanged);
        end

        addListenerToBaseFiles(obj,activeEvolution);
        fileChangedCallback(obj,src,event);
        clearListenerToBaseFiles(obj);
    end

    methods(Hidden,Access=protected)
        function deleteListeners(obj)

            listeners=["FileListChangedListener","ActiveEvolutionChangedListener"];
            evolutions.internal.ui.deleteListeners(obj,listeners);
        end

        function fileAddedRemoved(obj,~,data)
            changedTree=data.EventData;
            evolutionTreeListManager=getSubModel(obj.AppController,'EvolutionTreeListManager');
            currentTree=evolutionTreeListManager.CurrentSelected;
            if isequal(changedTree,currentTree)
                addFileListeners(obj);
            end
        end

        function activeEvolutionChanged(obj,~,data)
            if isempty(data.EventData)
                obj.clearListenerToBaseFiles;
            else
                obj.addFileListeners;
            end
        end

        function addFileListeners(obj,~,~)
            treeListManager=getSubModel(obj.AppController,'EvolutionTreeListManager');
            activeEvolution=treeListManager.CurrentSelected.EvolutionManager.WorkingEvolution;
            obj.addListenerToBaseFiles(activeEvolution);
        end
    end
end
