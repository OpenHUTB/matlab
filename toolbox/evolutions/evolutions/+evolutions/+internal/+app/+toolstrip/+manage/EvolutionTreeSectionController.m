classdef EvolutionTreeSectionController<evolutions.internal.ui.tools.ToolstripSectionController




    properties(SetAccess=immutable)

AppModel
AppController
AppView


EvolutionTreeSectionView

EventHandler

StateController

ProjectInterface


JSWebChannel
JSChannelHeader
        Channel='/WebTree';
        ChannelHeader='/WebTree/header';
    end

    properties(SetAccess=protected)

StateListener
EvolutionTreeListManagerChangedListener
EvolutionTreeNameChangeListener
EtmChangeListener

ChangeTreeButtonClickListener
CreateTreeButtonClickListener
DeleteTreeButtonClickListener
    end

    methods
        function this=EvolutionTreeSectionController(appController)

            this.AppController=appController;
            this.AppModel=getAppModel(appController);
            this.AppView=getAppView(appController);
            this.EvolutionTreeSectionView=getSubView(appController,'EvolutionTreeSection');
            this.EventHandler=appController.EventHandler;
            this.StateController=appController.StateController;
            this.ProjectInterface=this.AppModel.ProjectInterface;


            this.JSWebChannel=this.AppView.MsgChannel+this.Channel;
            this.JSChannelHeader=this.AppView.MsgChannel+this.ChannelHeader;
        end

        function updateWidgetStates(this)
            view=this.EvolutionTreeSectionView;
            state=this.StateController;
            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.JSWebChannel,'CreateEvo',state.Create);

            enableWidget(view,state.CreateEvolutionTree,'createTree');
            enableWidget(view,state.ChangeEvolutionTree,'changeTree');
            enableWidget(view,state.DeleteEvolutionTree,'deleteTree');
        end
    end


    methods(Access=protected)
        function updateView(this)
            updateWidgetStates(this)
        end

        function installModelListeners(this)
            this.EvolutionTreeListManagerChangedListener=...
            addlistener(this.EventHandler,'EvolutionTreeListManagerChanged',@this.onEvolutionTreeListManagerChange);
            this.EtmChangeListener=evolutions.internal.session...
            .EventHandler.subscribe('EtmChanged',@this.onEtmChange);
        end

        function installViewListeners(this)

            view=this.EvolutionTreeSectionView;

            this.StateListener=...
            addlistener(this.EventHandler,'StateChanged',@this.onStateChange);



            view.CreateTreeButton.ButtonPushedFcn=@this.createTreeCallback;
            view.DeleteTreeButton.DynamicPopupFcn=@(~,~)deleteTreePopupList(this);
            view.ChangeTreeButton.DynamicPopupFcn=@(~,~)changeTreePopupList(this);


            this.ChangeTreeButtonClickListener=...
            addlistener(view,'ChangeTreeButtonClick',@this.onChangeTreeButtonClick);

            this.CreateTreeButtonClickListener=...
            addlistener(view,'CreateTreeButtonClick',@this.onCreateTreeButtonClick);

            this.DeleteTreeButtonClickListener=...
            addlistener(view,'DeleteTreeButtonClick',@this.onDeleteTreeButtonClick);

            this.EvolutionTreeNameChangeListener=...
            addlistener(this.EventHandler,'EvolutionTreeNameChanged',@this.onTreeNameChange);
        end

    end


    methods(Hidden,Access=protected)
        function onTreeNameChange(this,~,~)
            evolutionTreeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');

            evolutionTreeListManager.setCurrentTree...
            (evolutionTreeListManager.CurrentSelected);
            valStruct=struct('CurrentTree',evolutionTreeListManager.CurrentSelected.getName,...
            'CurrentTreeId',evolutionTreeListManager.CurrentSelected.Id);
            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.JSWebChannel,'BundledMsg',valStruct);

            updateTreeNameList(this);

            view=this.EvolutionTreeSectionView;
            resetDropDownLists(view);
        end



        function updateTreeNameList(this)
            projectRefListModel=getSubModel(this.AppModel,'ProjectReferenceListManager');
            treeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            trees=treeListManager.getAllTrees(projectRefListModel.ReferenceList);
            treeDetails=struct.empty;
            treeNames=string.empty;
            count=1;
            for treeIdx=1:numel(trees)
                treeNames(end+1)=trees(treeIdx).getName;%#ok<AGROW>
                treeDetails(count).treeNames=trees(treeIdx).getName;
                treeDetails(count).treeIds=trees(treeIdx).Id;
                count=count+1;
            end


            valsStruct=struct('treeDetails',treeDetails,'treeNames',treeNames);
            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.JSChannelHeader,'TreeNameBundleMsg',valsStruct);
        end

        function createTreeCallback(this,~,~)
            this.logButtonClickEvent("CreateTree");
            this.startupOnCreateTreeButtonClick();
        end

        function popup=deleteTreePopupList(this)
            [projectList,projectTreeMap]=getProjectTreeMap(this);
            view=this.EvolutionTreeSectionView;
            popup=updateDeleteTreePopup(view,projectList,projectTreeMap);
        end

        function popup=changeTreePopupList(this)
            [projectList,projectTreeMap]=getProjectTreeMap(this);
            evolutionTreeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            currentSelectedTree=evolutionTreeListManager.CurrentSelected;
            view=this.EvolutionTreeSectionView;
            popup=updateChangeTreePopup(view,projectList,projectTreeMap,currentSelectedTree);

        end

        function[projectList,projectTreeMap]=getProjectTreeMap(this)
            projectRefListModel=getSubModel(this.AppModel,'ProjectReferenceListManager');
            projectList=getProjectFullPath(projectRefListModel);
            projectTreeMap=containers.Map;
            for idx=1:numel(projectList)
                projectName=projectList{idx};
                projectInfo=getProjInfo(projectRefListModel,projectName);
                trees=this.ProjectInterface.getEvolutionTrees(projectInfo);
                projectTreeMap(projectName)=trees;
            end
        end

        function onStateChange(this,~,~)
            updateWidgetStates(this);
        end


        function onChangeTreeButtonClick(this,~,data)

            logData.tree_id=data.EventData.TreeId;
            this.logListItemSelectedEvent("ChangeTree",logData);
            projectRefListModel=getSubModel(this.AppModel,'ProjectReferenceListManager');
            projectInfo=getProjInfo(projectRefListModel,data.EventData.ProjectFullPath);
            changeTreeAction(this,projectInfo,data.EventData.ProjectFullPath,data.EventData.TreeId);
        end

        function onDeleteTreeButtonClick(this,~,data)

            logData.tree_id=data.EventData.TreeId;
            this.logListItemSelectedEvent("DeleteTree",logData);
            projectRefListModel=getSubModel(this.AppModel,'ProjectReferenceListManager');
            projectInfo=getProjInfo(projectRefListModel,data.EventData.ProjectFullPath);
            deleteTreeAction(this,projectInfo,data.EventData.ProjectFullPath,data.EventData.TreeId,data.EventData.TreeName);
        end

        function trees=getAllTrees(this,path)
            projectRefListModel=getSubModel(this.AppModel,'ProjectReferenceListManager');
            projectList=getProjectFullPath(projectRefListModel);
            for idx=1:numel(projectList)
                projectName=projectList{idx};
                if(strcmp(path,projectName))
                    projectInfo=getProjInfo(projectRefListModel,projectName);
                    trees=this.ProjectInterface.getEvolutionTrees(projectInfo);
                end

            end
        end

        function onCreateTreeButtonClick(this,~,data)
            projectRefListModel=getSubModel(this.AppModel,'ProjectReferenceListManager');
            projectInfo=getProjInfo(projectRefListModel,data.EventData.ProjectFullPath);
            createTreeAction(this,projectInfo,data.EventData.ProjectFullPath);
        end

        function onEvolutionTreeListManagerChange(this,~,~)
            updateView(this);
        end

        function onEtmChange(this,~,~)
            evolutionTreeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            update(evolutionTreeListManager);
        end
    end

    methods
        function createTreeAction(this,projectInfo,projectFullPath)
            try
                createProgressDialog(this,getString...
                (message('evolutions:ui:CreateTreeProgressDialogTitle')));
                setAppStatus(this,0.5,getString...
                (message('evolutions:ui:CreateTreeProgressDialogMessage')));
                evolutionTreeInfo=this.AppController.ServerInterface.createEvolutionTree(projectInfo);

                evolutionTreeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
                trees=getAllTrees(this,projectFullPath);
                treeDetails=struct.empty;
                treeNames=string.empty;
                count=1;
                for treeIdx=1:numel(trees)
                    treeNames(count)=trees(treeIdx).getName;
                    treeDetails(count).treeNames=trees(treeIdx).getName;
                    treeDetails(count).treeIds=trees(treeIdx).Id;
                    count=count+1;
                end

                evolutionTreeListManager.setCurrentTree(evolutionTreeInfo);
                state=this.StateController;


                valsStruct=struct('treeDetails',treeDetails,'Header',projectFullPath,'treeNames',treeNames);
                evolutions.internal.ui.tools.JSSubscription.publish...
                (this.JSChannelHeader,'BundledMsg',valsStruct);

                msgVals=struct('CurrentTree',evolutionTreeInfo.getName,...
                'CurrentProject',projectFullPath,...
                'ChangeTreeVisibility',state.ChangeEvolutionTree,...
                'DeleteTreeVisibility',state.DeleteEvolutionTree,...
                'CurrentTreeId',evolutionTreeInfo.Id);
                evolutions.internal.ui.tools.JSSubscription.publish...
                (this.JSWebChannel,'BundledMsg',msgVals);

                closeProgressDialog(this);
            catch ME
                closeProgressDialog(this);
                handleException(this.AppController,ME);
            end
        end

        function startupOnCreateTreeButtonClick(this)
            valsStruct=struct('startUpWizard',true);
            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.JSWebChannel,'BundledMsg',valsStruct);
        end

        function deleteTreeAction(this,projectInfo,projectFullPath,treeId,treeName)

            evolutionTreeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            treeMap=getTreeMap(evolutionTreeListManager,projectInfo);
            selectedTree=treeMap(treeId);
            trees=getAllTrees(this,projectFullPath);
            treeDetails=struct.empty;
            treeNames=string.empty;
            warningMessage=evolutions.internal.ui.tools.prepareMessage(getString...
            (message('evolutions:ui:DeleteTreeWarningMessage')),treeName);
            selection=this.AppController.CustomDialogInterface.getUIConfirm...
            (warningMessage,'Icon','warning','DefaultOption','Cancel','CancelOption','Cancel');
            for idx=1:numel(trees)
                if(not(strcmp(trees(idx).Id,selectedTree.Id)))
                    treeNames(idx)=trees(idx).getName;
                    treeDetails(idx).treeNames=trees(idx).getName;
                    treeDetails(idx).treeIds=trees(idx).Id;
                end

            end

            if~isequal(selection,'Cancel')
                valsStruct=struct('treeDetails',treeDetails,'Header',projectFullPath,'treeNames',treeNames);
                evolutions.internal.ui.tools.JSSubscription.publish...
                (this.JSChannelHeader,'BundledMsg',valsStruct);

                try
                    createProgressDialog(this,getString...
                    (message('evolutions:ui:DeleteTreeProgressDialogTitle')));
                    setAppStatus(this,0.5,getString...
                    (message('evolutions:ui:DeleteTreeProgressDialogMessage',...
                    treeName)));
                    this.AppController.ServerInterface.deleteEvolutionTree(projectInfo,selectedTree);
                    currentSelectedTree=evolutionTreeListManager.CurrentSelected;
                    if(~isempty(currentSelectedTree))
                        valStruct=struct('CurrentTree',currentSelectedTree.getName,'CurrentTreeId',currentSelectedTree.Id);
                        evolutions.internal.ui.tools.JSSubscription.publish...
                        (this.JSWebChannel,'BundledMsg',valStruct);
                    else
                        evolutions.internal.ui.tools.JSSubscription.publish...
                        (this.JSWebChannel,'CurrentProject',struct('EmptyProject',''));

                    end

                    state=this.StateController;
                    msgVals=struct('CurrentProject',projectFullPath,...
                    'ChangeTreeVisibility',state.ChangeEvolutionTree,...
                    'DeleteTreeVisibility',state.DeleteEvolutionTree);
                    evolutions.internal.ui.tools.JSSubscription.publish...
                    (this.JSWebChannel,'BundledMsg',msgVals);

                    closeProgressDialog(this);
                catch ME
                    closeProgressDialog(this);
                    handleException(this.AppController,ME);
                end
            end
        end

        function changeTreeAction(this,projectInfo,projectFullPath,treeId)
            evolutionTreeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            treeMap=getTreeMap(evolutionTreeListManager,projectInfo);
            selectedTree=treeMap(treeId);
            evolutionTreeListManager.setCurrentTree(selectedTree);
            state=this.StateController;


            msgVals=struct('CurrentTree',selectedTree.getName,...
            'CurrentProject',projectFullPath,...
            'ChangeTreeVisibility',state.ChangeEvolutionTree,...
            'DeleteTreeVisibility',state.DeleteEvolutionTree,...
            'CurrentTreeId',selectedTree.Id);
            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.JSWebChannel,'BundledMsg',msgVals);
        end
    end
end


