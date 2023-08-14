classdef FileListController<handle




    properties(SetAccess=immutable)

AppController
AppModel
AppView


InspectorView
FileListManager

EventHandler

StateController

FileSectionController

MessageChannel
        FileListMessageChannel='/FileList'
    end

    properties(SetAccess=protected)

FileListActionListener
EvolutionSelectionListener
FileListChangedListener
FileAddActiveListener
FileAddAllListener
FileRemoveActiveListener
FileRemoveAllListener
FileListCurrentSelectedListener
RefreshFilesActionListener
ButtonStates
    end

    methods
        function this=FileListController(parentController)
            this.AppController=parentController.AppController;
            this.AppModel=getAppModel(this.AppController);
            this.AppView=getAppView(this.AppController);
            this.InspectorView=getSubView(this.AppView,'PropertyInspector');
            this.FileListManager=getSubModel(this.AppModel,'FileList');

            this.EventHandler=parentController.AppController.EventHandler;
            this.StateController=parentController.AppController.StateController;
            this.FileSectionController=getSubController(this.AppController,'file');

            this.MessageChannel=this.AppView.MsgChannel+this.FileListMessageChannel;
        end

        function setup(this)

            installViewListeners(this);


        end

        function delete(this)
            deleteListeners(this);
        end

        function update(this,varargin)
            view=this.InspectorView;
            update(view,this.FileListManager);



            selectedFile=this.InspectorView.FileUIList.Value;
            this.updateContextMenuStates();
            notifyFileChange(this,selectedFile);
        end

        function deleteListeners(this)

            listeners=["FileListActionListener","EvolutionSelectionListener",...
            "RefreshFilesActionListener",...
            "FileListChangedListener","FileAddActiveListener",...
            "FileAddAllListener","FileRemoveActiveListener",...
            "FileRemoveAllListener","ButtonStates"];
            evolutions.internal.ui.deleteListeners(this,listeners);
        end

    end

    methods(Access=protected)
        function installViewListeners(this)
            this.FileListActionListener=...
            listener(this.InspectorView,'ValueChanged',@this.onValueChanged);

            this.RefreshFilesActionListener=...
            listener(this.InspectorView,'RefreshFiles',@this.RefreshFilesClicked);

            this.FileListCurrentSelectedListener=...
            listener(this.InspectorView,'CurrentSelectedFiles',@this.onSelectedFilesChanged);

            this.FileListChangedListener=...
            listener(this.EventHandler,'FileListChanged',@this.update);

            this.EvolutionSelectionListener=...
            listener(this.EventHandler,'TreeSelectionChanged',@this.onEvolutionChange);

            this.FileAddActiveListener=...
            listener(this.InspectorView,'FileAddActive',@this.onFileAddActive);

            this.FileAddAllListener=...
            listener(this.InspectorView,'FileAddAll',@this.onFileAddAll);

            this.FileRemoveActiveListener=...
            listener(this.InspectorView,'FileRemoveActive',@this.onFileRemoveActive);

            this.FileRemoveAllListener=...
            listener(this.InspectorView,'FileRemoveAll',@this.onFileRemoveAll);

            this.ButtonStates=...
            listener(this.InspectorView,'ButtonStates',@this.onChangeofButtonStates);
        end


    end

    methods(Hidden,Access=protected)

        function onValueChanged(this,~,ed)
            newCurrentTreeName=ed.Source.FileUIList.CurrentTreeName;
            selectedFile=this.FileListManager.changeCurrentSelected(newCurrentTreeName);
            notifyFileChange(this,selectedFile);
        end

        function RefreshFilesClicked(this,~,~)
            this.FileListManager.update();
        end
        function onSelectedFilesChanged(this,~,ed)
            currentSelectedFiles=ed.Source.LatestSelectedFiles;
            this.FileListManager.changeLatestSelectedFiles(currentSelectedFiles);
        end

        function onChangeofButtonStates(this,~,states)
            newButtonStates=states.Source.ButtonStateUpdate;
            this.FileListManager.updateButtonStates(newButtonStates);
            this.updateContextMenuStates();
        end

        function onEvolutionChange(this,~,~)
            update(this.FileListManager);
            selectedFile=this.FileListManager.CurrentSelected;
            evolutionTreeManager=getSubModel(this.AppModel,'EvolutionsTreeManager');
            treeList=getSubModel(this.AppModel,'EvolutionTreeListManager');
            selectedNode=evolutionTreeManager.SelectedEvolution;
            if~isempty(selectedFile)
                associatedNode=evolutions.internal.artifactserver.getArtifactObject...
                (treeList.CurrentSelected.ArtifactRootFolder,selectedFile,selectedNode);
                notify(this.EventHandler,'FileListSelectionChanged',...
                evolutions.internal.ui.GenericEventData(associatedNode));
            end
        end


        function onFileAddActive(this,~,addFields)
            addToActiveFileList=(addFields.Source.FileList);
            addToActiveEvent=(addFields.Source.FileEvent);
            this.FileSectionController.addFile(false,addToActiveEvent,addToActiveFileList);
        end

        function onFileAddAll(this,~,addAllFields)
            addToAllFileList=(addAllFields.Source.FileList);
            addToAllEvent=(addAllFields.Source.FileEvent);
            this.FileSectionController.addFile(true,addToAllEvent,addToAllFileList);
        end

        function onFileRemoveActive(this,~,removeFiles)
            removeFromActiveFileList=(removeFiles.Source.FileList);
            this.FileSectionController.removeFile(false,removeFromActiveFileList);
        end

        function onFileRemoveAll(this,~,removeFiles)
            removeFromAllFileList=(removeFiles.Source.FileList);
            this.FileSectionController.removeFile(true,removeFromAllFileList);
        end

        function notifyFileChange(this,selectedFile)
            evolutionTreeManager=getSubModel(this.AppModel,'EvolutionsTreeManager');
            treeList=getSubModel(this.AppModel,'EvolutionTreeListManager');
            selectedNode=evolutionTreeManager.SelectedEvolution;
            if~isempty(selectedNode)&&~isempty(selectedFile)
                associatedNode=evolutions.internal.artifactserver.getArtifactObject...
                (treeList.CurrentSelected.ArtifactRootFolder,selectedFile,selectedNode);

                notify(this.EventHandler,'FileListSelectionChanged',...
                evolutions.internal.ui.GenericEventData(associatedNode));
            end
        end

        function updateContextMenuStates(this)
            state=this.StateController;
            fileListStates=struct('HasEvolutions',state.HasEvolutions,'isWorkingEvolution',state.isWorkingEvolution);
            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.MessageChannel,'FileListStates',fileListStates);

        end

    end
end


