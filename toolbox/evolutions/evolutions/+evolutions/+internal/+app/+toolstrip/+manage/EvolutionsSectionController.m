classdef EvolutionsSectionController<evolutions.internal.ui.tools.ToolstripSectionController




    properties(Hidden,SetAccess=immutable)

AppModel
AppController

EvolutionsSectionView

EventHandler

StateController
    end

    properties(SetAccess=protected)

        EnableButtons logical
    end

    properties(SetAccess=protected)

TreeChangeListener
EvolutionCreatedListener
WorkingModelChangeListener
StateListener
    end

    methods
        function this=EvolutionsSectionController(appController)

            this.AppController=appController;
            this.AppModel=getAppModel(appController);
            this.EvolutionsSectionView=getSubView(appController,'EvolutionsSection');
            this.EnableButtons=false;
            this.EventHandler=appController.EventHandler;
            this.StateController=appController.StateController;
        end

        function updateWidgetStates(this)
            view=this.EvolutionsSectionView;
            state=this.StateController;
            enableWidget(view,state.Create,'create');
            enableWidget(view,state.Update,'update');
            enableWidget(view,state.DeleteNode,'deletenode');
            enableWidget(view,state.DeleteBranch,'deletebranch');
            enableWidget(view,state.Get,'get');
        end

        function delete(this)
            deleteListeners(this);
        end
    end


    methods(Access=protected)
        function deleteListeners(this)
            listeners=["TreeChangeListener",...
            "EvolutionCreatedListener",...
            "WorkingModelChangeListener",...
            "StateListener"];
            evolutions.internal.ui.deleteListeners(this,listeners);
        end
        function updateView(~)

        end

        function installModelListeners(this)
            this.TreeChangeListener=evolutions.internal.session...
            .EventHandler.subscribe('TreeChanged',@this.onTreeChange);
            this.EvolutionCreatedListener=evolutions.internal.session...
            .EventHandler.subscribe('EvolutionCreated',@this.onEvolutionCreated);
        end

        function installViewListeners(this)

            view=this.EvolutionsSectionView;

            view.CreateButton.ButtonPushedFcn=@this.createEvolutionCallback;
            view.UpdateButton.ButtonPushedFcn=@this.updateParentCallback;
            view.DeleteBranch.ButtonPushedFcn=@this.deleteBranchCallback;
            view.DeleteSelected.ButtonPushedFcn=@this.deleteSelectedCallback;
            view.GetButton.ButtonPushedFcn=@this.getEvolutionCallback;
            this.WorkingModelChangeListener=...
            addlistener(this.EventHandler,'WorkingModelChanged',@this.onWorkingModelChange);
            this.StateListener=...
            addlistener(this.EventHandler,'StateChanged',@this.onStateChange);
        end
    end


    methods(Hidden,Access=protected)
        function onStateChange(this,~,~)
            updateWidgetStates(this);
        end

        function onWorkingModelChange(~,~,~)
        end

        function createEvolutionCallback(this,~,~)
            this.logButtonClickEvent("CreateEvolution");
            createEvolution(this);
        end
        function deleteBranchCallback(this,~,~)
            this.logButtonClickEvent("DeleteBranch");
            deleteBranch(this);
        end

        function getEvolutionCallback(this,~,~)
            this.logButtonClickEvent("GetEvolution");
            getEvolution(this);
        end

        function updateParentCallback(this,~,~)
            this.logButtonClickEvent("UpdateEvolution");
            updateParent(this);
        end

        function deleteSelectedCallback(this,~,~)
            this.logButtonClickEvent("DeleteEvolution");
            deleteSelected(this);
        end

        function setAppBusy(this)
            parentApp=this.AppController.AppView.getToolGroup;

            parentApp.Busy=1;
        end

        function clearAppBusy(this)
            parentApp=this.AppController.AppView.getToolGroup;

            parentApp.Busy=0;
        end

        function onTreeChange(this,~,data)
            notifyEvolutionChangeEvent(this,data,'EvolutionChanged');
        end

        function onEvolutionCreated(this,~,data)
            notifyEvolutionChangeEvent(this,data,'EvolutionCreated');
        end

        function notifyEvolutionChangeEvent(this,data,eventName)
            changedTree=data.EventData;
            evolutionTreeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            currentTree=evolutionTreeListManager.CurrentSelected;
            if isequal(changedTree,currentTree)
                notify(this.EventHandler,eventName);
            end
        end

    end

    methods
        function deleteBranch(this)
            evolutionsTreeData=getSubModel(this.AppModel,'EvolutionsTreeManager');
            nodeToDelete=evolutionsTreeData.SelectedEvolution;
            evolutionTreeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            [childNodes,~]=...
            evolutions.internal.utils.findEvolutionChildren(...
            evolutionTreeListManager.CurrentSelected.EvolutionManager,...
            nodeToDelete);
            allNodesToDelete=[nodeToDelete,childNodes];
            nodesToDeleteNames=cell(size(allNodesToDelete));
            for nodeIdx=1:length(allNodesToDelete)
                nodesToDeleteNames{nodeIdx}=allNodesToDelete(nodeIdx).getName;
            end
            warningMessage=evolutions.internal.ui.tools.prepareMessage(getString...
            (message('evolutions:ui:DeleteWarningMessage')),nodesToDeleteNames);
            selection=this.AppController.CustomDialogInterface.getUIConfirm...
            (warningMessage,'Icon','warning','DefaultOption','Cancel','CancelOption','Cancel');
            try
                if~isempty(nodeToDelete)&&~isequal(selection,'Cancel')

                    createProgressDialog(this,getString...
                    (message('evolutions:ui:DeleteProgressDialogTitle')));
                    setAppStatus(this,0.5,getString...
                    (message('evolutions:ui:DeleteBranchProgressDialogMessage',nodeToDelete.getName)));
                    this.AppController.ServerInterface.deleteEvolutions(nodeToDelete);
                    closeProgressDialog(this);
                end
            catch ME
                closeProgressDialog(this);
                handleException(this.AppController,ME);
            end
        end

        function getEvolution(this)
            evolutionsTreeData=getSubModel(this.AppModel,'EvolutionsTreeManager');
            destinationNode=evolutionsTreeData.SelectedEvolution;
            nodeName=destinationNode.getName;
            try
                [okToGet,filesNotInProject]=this.doPreGetChecks;
                if okToGet
                    createProgressDialog(this,getString...
                    (message('evolutions:ui:GetProgressDialogTitle')));
                    setAppStatus(this,0.5,getString...
                    (message('evolutions:ui:GetProgressDialogMessage',nodeName)));
                    [success,mException]=...
                    this.AppController.ServerInterface.getEvolution(destinationNode);
                    if~(success)
                        throw(mException);
                    end

                    this.addFilesToProject(filesNotInProject,...
                    destinationNode.Project);
                    closeProgressDialog(this);
                end
            catch ME
                closeProgressDialog(this);
                handleException(this.AppController,ME);
            end
        end

        function[okToGet,filesNotInProject]=doPreGetChecks(this)
            okToGet=true;
            warningMessage=string.empty;
            filesNotInProject=cell.empty;
            evolutionsTreeData=getSubModel(this.AppModel,'EvolutionsTreeManager');
            evolutionTreeListData=getSubModel(this.AppModel,'EvolutionTreeListManager');
            destinationNode=evolutionsTreeData.SelectedEvolution;
            currentWorking=evolutionTreeListData.CurrentSelected.EvolutionManager.WorkingEvolution;
            currentWorkingParent=currentWorking.Parent;
            differences=this.AppController.ServerInterface.calculateEvolutionDifferences(...
            currentWorking,currentWorkingParent);
            hasDifferences=~isempty(differences.changedFiles)||...
            ~isempty(differences.addedFiles)||...
            ~isempty(differences.removedFiles);
            if(hasDifferences)

                selection=this.AppController.CustomDialogInterface.getUIConfirm...
                (getString(message('evolutions:ui:WorkingModelDifferentDialog')),...
                'Icon','warning','DefaultOption','Cancel','CancelOption','Cancel');
                if isequal(selection,'Cancel')
                    okToGet=false;
                end
            end

            if okToGet
                [filesNotInProject,filesNotInEvolution]=...
                evolutions.internal.utils.getEvolutionToProjectDifference(destinationNode);
                if~isempty(filesNotInProject)
                    notInProjectWarningMessage=evolutions.internal.ui.tools.prepareMessage(getString...
                    (message('evolutions:ui:FileNotInProjectDialog')),filesNotInProject);
                    warningMessage=[warningMessage,notInProjectWarningMessage];
                end

                if~isempty(filesNotInEvolution)
                    fileNotInEvolutionWarningMessage=evolutions.internal.ui.tools.prepareMessage(getString...
                    (message('evolutions:ui:FileNotInEvolutionDialog')),filesNotInEvolution);
                    warningMessage=[warningMessage,fileNotInEvolutionWarningMessage];
                end
                okToGet=this.launchDialog(warningMessage);
            end
        end

        function okToGet=launchDialog(this,warningMessage)
            okToGet=true;
            if(~isempty(warningMessage))
                selection=this.AppController.CustomDialogInterface.getUIConfirm...
                (warningMessage,'Icon','warning',...
                'DefaultOption','OK','CancelOption','Cancel');



                if isequal(selection,'Cancel')
                    okToGet=false;
                end
            end
        end


        function createEvolution(this)
            try

                createProgressDialog(this,getString...
                (message('evolutions:ui:CreateProgressDialogTitle')));
                setAppStatus(this,0.5,getString...
                (message('evolutions:ui:CreateProgressDialogMessage')));
                [success,mException]=...
                this.AppController.ServerInterface.createEvolution;
                if~(success)
                    throw(mException);
                end
                closeProgressDialog(this);
            catch ME
                closeProgressDialog(this);
                handleException(this.AppController,ME);
            end
        end

        function addFilesToProject(~,missingFiles,project)
            for fileIdx=1:length(missingFiles)
                curFile=missingFiles{fileIdx};
                project.addFile(curFile);
            end
        end

        function deleteSelected(this)
            evolutionsTreeData=getSubModel(this.AppModel,'EvolutionsTreeManager');
            nodeToDelete=evolutionsTreeData.SelectedEvolution;
            warningMessage=evolutions.internal.ui.tools.prepareMessage(getString...
            (message('evolutions:ui:DeleteWarningMessage')),nodeToDelete.getName);
            selection=this.AppController.CustomDialogInterface.getUIConfirm...
            (warningMessage,'Icon','warning','DefaultOption','Cancel','CancelOption','Cancel');
            try
                if~isempty(nodeToDelete)&&~isequal(selection,'Cancel')

                    createProgressDialog(this,getString...
                    (message('evolutions:ui:DeleteProgressDialogTitle')));
                    setAppStatus(this,0.5,getString...
                    (message('evolutions:ui:DeleteSelectedProgressDialogMessage',nodeToDelete.getName)));
                    this.AppController.ServerInterface.deleteSingleEvolution(nodeToDelete);
                    closeProgressDialog(this);
                end
            catch ME
                closeProgressDialog(this);
                handleException(this.AppController,ME);
            end
        end

        function updateParent(this)

            evolutionTreeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            currentTree=evolutionTreeListManager.CurrentSelected;
            workingEvolution=this.AppController.ProjectInterface.getEvolutionTreeWorkingNode(currentTree);
            selection=this.AppController.CustomDialogInterface.getUIConfirm...
            (getString(message('evolutions:ui:UpdateEvolutionDialog',workingEvolution.Parent.getName)),...
            'Icon','warning','DefaultOption','Cancel','CancelOption','Cancel');
            try
                if~isempty(workingEvolution.Parent)&&~isequal(selection,'Cancel')

                    createProgressDialog(this,getString...
                    (message('evolutions:ui:UpdateProgressDialogTitle')));
                    setAppStatus(this,0.5,getString...
                    (message('evolutions:ui:UpdateProgressDialogMessage',workingEvolution.Parent.getName)));
                    [success,mException]=...
                    this.AppController.ServerInterface.updateEvolution;
                    if~(success)
                        throw(mException);
                    end
                    closeProgressDialog(this);
                end
            catch ME
                closeProgressDialog(this);
                handleException(this.AppController,ME);
            end
        end

    end
end


