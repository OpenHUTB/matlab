classdef EvolutionWebPlotController<handle





    properties(SetAccess=immutable)
AppController
AppModel
AppView
DocumentController
EvolutionPlotView
EvolutionsTreeManager
CompareManager
EventHandler
ProjectInterface

PanelController

MessageChannel





JSChannelHeader
JSWebChannel
        Channel='/WebTree';
        ChannelHeader='/WebTree/header';
        SwitchViewMsgChannel='/AppViewChange';
    end

    properties(SetAccess=protected)


    end

    properties(SetAccess=protected)

ModelSelectionChangedListener
EvolutionTreeManagerChangedListener
EvolutionNameChangedListener
CanvasClickedListener
NodeClickedListener
EdgeClickedListener

ViewSelectionChangedListener

ActiveFileEditedListener



JSWebTreeEventListener
JSWebTreeHeaderEventListener

EvolutionCreatedListener
EdgeSelectionChangedListener
    end

    methods
        function this=EvolutionWebPlotController(parentController)

            this.DocumentController=parentController;
            appController=parentController.AppController;
            this.AppController=appController;
            this.AppModel=getAppModel(appController);
            this.AppView=getAppView(appController);


            documentView=getSubView(this.AppView,'DocumentView');
            evolutionTreeDocumentView=getSubView(documentView,'EvolutionTreeDocument');
            this.EvolutionPlotView=getSubView(evolutionTreeDocumentView,'EvolutionPlotView');
            this.EvolutionsTreeManager=getSubModel(this.AppModel,'EvolutionsTreeManager');
            this.CompareManager=getSubModel(this.AppModel,'Compare');

            this.PanelController=getSubController(this.AppController,'panel');
            this.EventHandler=appController.EventHandler;
            this.ProjectInterface=this.AppController.ProjectInterface;

            this.MessageChannel=getMsgChannel(this.AppView);

            this.JSWebChannel=this.MessageChannel+this.Channel;
            this.JSChannelHeader=this.MessageChannel+this.ChannelHeader;
        end

        function setup(this)

            installModelListeners(this);
            installViewListeners(this);
        end

        function delete(this)

            deleteListeners(this)
        end

        function update(this)
            rootEvolution=this.EvolutionsTreeManager.RootEvolution;
            update(this.EvolutionPlotView,rootEvolution,false);
            updateLayout(this)
        end

        function updateLayout(this)


            notify(this.EventHandler,'ActiveEvolutionChanged',...
            evolutions.internal.ui.GenericEventData(this.EvolutionPlotView.ActiveEi));

            setWorkingSelected(this.EvolutionsTreeManager);
            selectedEvolution=this.EvolutionsTreeManager.SelectedEvolution;
            changeSelected(this.EvolutionPlotView,selectedEvolution);

            layoutView(this.EvolutionPlotView);
        end

        function updateSelected(this)
            selectedEvolution=this.EvolutionsTreeManager.SelectedEvolution;
            if~isempty(selectedEvolution)
                changeSelected(this.EvolutionPlotView,selectedEvolution);
            end
        end

        function updatePlot(this)
            rootEvolution=this.EvolutionsTreeManager.RootEvolution;
            update(this.EvolutionPlotView,rootEvolution,true);
            updateLayout(this)
        end

        function executeJSEvent(this,data)
            evolutionsSectionController=getSubController(this.AppController,'evolutions');
            item=data.item;
            project=data.project;
            tree=data.tree;

            switch item
            case 'NewTree'
                this.createTreePopupList();
            case 'changeTree'
                this.changeTreePopupList();
            case 'deleteTree'
                this.deleteTreePopupList();
            case 'ChangeTreeClick'
                this.onChangeTreeButtonClick(project,tree);
            case 'DeleteTreeClick'
                this.onDeleteTreeButtonClick(project,tree);
            case 'NewTreeClick'
                this.logMenuItemSelectedEvent("CreateTree",struct());
                this.launchStartupWizard;
            case 'getEvolution'
                this.logMenuItemSelectedEvent("GetEvolution",struct());
                evolutionsSectionController.getEvolution();
            case 'deleteEvolution'
                this.logMenuItemSelectedEvent("DeleteEvolution",struct());
                evolutionsSectionController.deleteSelected();
            case 'deleteBranch'
                this.logMenuItemSelectedEvent("DeleteBranch",struct());
                evolutionsSectionController.deleteBranch();
            case 'updateWithActive'
                this.logMenuItemSelectedEvent("UpdateEvolution",struct());
                evolutionsSectionController.updateParent();
            case 'createEvolution'
                this.logMenuItemSelectedEvent("CreateEvolution",struct());
                evolutionsSectionController.createEvolution();
            otherwise
                assert(strcmp(item,'EvolutionName'));
                propertyInspectorController=getSubController(this.PanelController,'PropertyInspector');
                propertyInspectorController.EvolutionInfoController.evolutionNameChangeAction(tree);
            end
        end
    end

    methods(Access=protected)

        function logMenuItemSelectedEvent(~,id,data)
            import matlab.ddux.internal.*;
            eventId=UIEventIdentification(...
            "Design Evolution",...
            "Design Evolution Manager",...
            EventType.CLICK,...
            ElementType.MENU_ITEM,...
            id);
            logUIEvent(eventId,data);
        end

        function deleteListeners(this)
            listeners=["ModelSelectionChangedListener","CanvasClickedListener",...
            "EvolutionTreeManagerChangedListener","EvolutionCreatedListener",...
            "NodeClickedListener",...
            "EvolutionNameChangedListener","EdgeClickedListener",...
            "ViewSelectionChangedListener","JSWebTreeEventListener","JSWebTreeHeaderEventListener",...
            "EdgeSelectionChangedListener"];
            evolutions.internal.ui.deleteListeners(this,listeners);
        end

        function installModelListeners(this)


            this.EvolutionTreeManagerChangedListener=...
            listener(this.EventHandler,'EvolutionsTreeManagerChanged',@this.onEvolutionTreeManagerChanged);
            this.EvolutionCreatedListener=...
            listener(this.EventHandler,'NewEvolutionCreated',@this.onEvolutionCreated);
            this.ActiveFileEditedListener=...
            listener(this.EventHandler,'FileOnDiskChange',@this.onActiveFileOnDiskChange);
        end

        function installViewListeners(this)
            this.ViewSelectionChangedListener=...
            listener(this.EvolutionPlotView,...
            'SelectionChanged',@this.onViewSelectionChanged);

            this.EdgeSelectionChangedListener=...
            listener(this.EvolutionPlotView,...
            'EdgeSelectionChanged',@this.onEdgeSelectionChanged);


            this.ModelSelectionChangedListener=...
            listener(this.EventHandler,'TreeSelectionChanged',@this.onModelSelectionChanged);


            this.EvolutionNameChangedListener=...
            listener(this.EventHandler,'EvolutionNameChanged',@this.onEvolutionNameChanged);


            this.CanvasClickedListener=...
            listener(this.EvolutionPlotView,'CanvasClicked',@(~,~)notify(this.EventHandler,'CanvasClicked'));


            this.NodeClickedListener=...
            listener(this.EvolutionPlotView,'NodeClicked',@(~,~)notify(this.EventHandler,'NodeClicked'));


            this.EdgeClickedListener=...
            listener(this.EvolutionPlotView,'EdgeClicked',@(~,~)notify(this.EventHandler,'EdgeClicked'));

            this.JSWebTreeEventListener=evolutions.internal.ui.tools.JSSubscription.subscribe...
            (this,this.MessageChannel,@this.executeJSEvent,this.Channel);

            this.JSWebTreeHeaderEventListener=evolutions.internal.ui.tools.JSSubscription.subscribe...
            (this,this.MessageChannel,@this.executeJSEvent,this.ChannelHeader);
        end

        function onEvolutionNameChanged(this,~,~)

            selectedEvolution=this.EvolutionsTreeManager.SelectedEvolution;
            changeEvolutionName(this.EvolutionPlotView,selectedEvolution);
        end

        function onActiveFileOnDiskChange(this,~,~)

            activeNode=this.EvolutionPlotView.ActiveEi;
            differences=this.AppController.ServerInterface.calculateEvolutionDifferences(...
            activeNode,activeNode.Parent);
            if differences.hasDifferences
                this.EvolutionPlotView.setActiveEdited;
            end
        end

        function onEvolutionTreeManagerChanged(this,~,~)

            update(this);
        end

        function onEvolutionCreated(this,~,~)



            updatePlot(this);
            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.JSWebChannel,'EvolutionCreated',true);
        end

        function onModelSelectionChanged(this,~,~)

            updateSelected(this);
        end

        function onViewSelectionChanged(this,~,nodeEventData)
            clickedEi=nodeEventData.EventData;
            this.ModelSelectionChangedListener.Enabled=false;
            this.EvolutionsTreeManager.SelectedEvolution=clickedEi;
            this.ModelSelectionChangedListener.Enabled=true;
        end

        function onEdgeSelectionChanged(this,~,nodeEventData)
            clickedEntity=nodeEventData.EventData;
            clickedEdge=clickedEntity;
            clickedEntityType=nodeEventData.EventData.type;

            if isequal(clickedEntityType,'diagram.Port')
                clickedEdge=clickedEntity.connections(1);
            end
            this.CompareManager.SelectedEdge=clickedEdge;
            fromEvolutionId=clickedEdge.getAttribute("fromEvolutionId");
            toEvolutionId=clickedEdge.getAttribute("toEvolutionId");
            fromEvolution=this.EvolutionPlotView.EvolutionIdToInfo(fromEvolutionId.value);
            toEvolution=this.EvolutionPlotView.EvolutionIdToInfo(toEvolutionId.value);
            this.CompareManager.CompareEdge=this.AppController.ServerInterface.getEdgeInfo(fromEvolution,toEvolution);
            notify(this.EventHandler,'EdgeSelectionChanged')
        end

    end

    methods
        function changeTreePopupList(this)
            evolutionTreeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            currentSelectedTree=evolutionTreeListManager.CurrentSelected;
            this.publishCurrentProject(currentSelectedTree);
            publishTreeNames(this);
        end

        function publishCurrentProject(this,currentSelectedTree)
            currentProjPath=strsplit(currentSelectedTree.ArtifactRootFolder,'EvolutionTrees');
            currentProjPath=char(currentProjPath(1));
            currentProjPath=currentProjPath(1:end-1);
            msgVals=struct('CurrentTree',currentSelectedTree.getName,'CurrentProject',currentProjPath,...
            'CurrentTreeId',currentSelectedTree.Id,'ProjectDescription',currentSelectedTree.Project.Description);
            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.JSWebChannel,'BundledMsg',msgVals);
        end

        function deleteTreePopupList(this)
            evolutionTreeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            currentSelectedTree=evolutionTreeListManager.CurrentSelected;
            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.JSWebChannel,'CurrentTree',currentSelectedTree.getName,'CurrentTreeId',currentSelectedTree.Id);
            publishTreeNames(this);
        end

        function publishTreeNames(this)
            [projectList,projectTreeMap]=getProjectTreeMap(this);
            for projectIdx=1:numel(projectList)
                projectFullPath=projectList{projectIdx};
                trees=projectTreeMap(projectFullPath);
                if~isempty(trees)
                    [treeNames,treeDetails]=this.publishAllTreeNames(trees);
                    valsStruct=struct('Header',projectFullPath,'treeDetails',treeDetails,'treeNames',treeNames);
                    evolutions.internal.ui.tools.JSSubscription.publish...
                    (this.JSChannelHeader,'BundledMsg',valsStruct);
                end
            end
        end

        function[treeNames,treeDetails]=publishAllTreeNames(~,trees)
            treeDetails=struct.empty;
            treeNames=string.empty;
            for treeIdx=1:numel(trees)
                treeNames(treeIdx)=trees(treeIdx).getName;
                treeDetails(treeIdx).treeNames=trees(treeIdx).getName;
                treeDetails(treeIdx).treeIds=trees(treeIdx).Id;
            end

        end

        function projectTreeMap=createTreePopupList(this)
            [~,projectTreeMap]=getProjectTreeMap(this);
        end


        function[projectList,projectTreeMap]=getProjectTreeMap(this)
            projectRefListModel=getSubModel(this.AppModel,'ProjectReferenceListManager');
            projectList=getProjectFullPath(projectRefListModel);
            projectTreeMap=containers.Map;
            projDir=cell.empty;
            for idx=1:numel(projectList)
                projectName=projectList{idx};
                [~,projectDir]=fileparts(projectName);
                projDir{idx}=projectDir;
                projectInfo=getProjInfo(projectRefListModel,projectName);
                trees=this.ProjectInterface.getEvolutionTrees(projectInfo);
                projectTreeMap(projectName)=trees;
            end
            valsStruct=struct('projNames',projDir,'projPaths',projectList);
            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.JSWebChannel,'BundledMsg',valsStruct);
        end

        function trees=getProjectTrees(this,path)
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

        function onChangeTreeButtonClick(this,path,title)
            projectRefListModel=getSubModel(this.AppModel,'ProjectReferenceListManager');
            projectInfo=getProjInfo(projectRefListModel,path);
            treeId=this.getTreeId(path,title);
            logData.tree_id=string(treeId);
            this.logMenuItemSelectedEvent("ChangeTree",logData);
            evolutionsSectionController=getSubController(this.AppController,'evolutiontree');
            evolutionsSectionController.changeTreeAction(projectInfo,path,treeId);
        end


        function treeId=getTreeId(this,path,title)
            trees=getProjectTrees(this,path);
            for idx=1:numel(trees)
                if(strcmp(title,trees(idx).getName))
                    treeId=trees(idx).Id;
                end
            end
        end

        function launchStartupWizard(this)
            evolutionsSectionController=getSubController(this.AppController,'evolutiontree');
            evolutionsSectionController.startupOnCreateTreeButtonClick();
        end


        function onCreateTreeButtonClick(this,title)
            projectRefListModel=getSubModel(this.AppModel,'ProjectReferenceListManager');
            projectInfo=getProjInfo(projectRefListModel,title);
            evolutionsSectionController=getSubController(this.AppController,'evolutiontree');
            evolutionsSectionController.createTreeAction(projectInfo,title);
        end

        function onDeleteTreeButtonClick(this,path,title)
            projectRefListModel=getSubModel(this.AppModel,'ProjectReferenceListManager');
            projectInfo=getProjInfo(projectRefListModel,path);
            treeId=this.getTreeId(path,title);
            logData.tree_id=string(treeId);
            this.logMenuItemSelectedEvent("DeleteTree",logData);

            evolutionsSectionController=getSubController(this.AppController,'evolutiontree');
            evolutionsSectionController.deleteTreeAction(projectInfo,path,treeId,title);
            if~isempty(this.EvolutionsTreeManager.SelectedEvolution)
                selectedEvolution=this.EvolutionsTreeManager.SelectedEvolution.Project.RootFolder;
                evolutions.internal.ui.tools.JSSubscription.publish...
                (this.JSWebChannel,'CurrentProject',selectedEvolution);
                this.getProjectTreeMap;
            end

        end


    end

    methods(Access=?evolutionsTest.ui.tree.Tester)
        function enablePanMode(this)
            appView=this.AppController.AppView;
            msgChannel=appView.MsgChannel;
            evolutions.internal.ui.tools.JSSubscription.publish...
            (msgChannel+'/WebTree','Modes','panToolMode');
        end

        function disablePanMode(this)
            appView=this.AppController.AppView;
            msgChannel=appView.MsgChannel;
            evolutions.internal.ui.tools.JSSubscription.publish...
            (msgChannel+'/WebTree','Modes','cancelTool');
        end

        function enableSelectMode(this)
            appView=this.AppController.AppView;
            msgChannel=appView.MsgChannel;
            evolutions.internal.ui.tools.JSSubscription.publish...
            (msgChannel+'/WebTree','Modes','selectMode');
        end

        function disableSelectMode(this)
            appView=this.AppController.AppView;
            msgChannel=appView.MsgChannel;
            evolutions.internal.ui.tools.JSSubscription.publish...
            (msgChannel+'/WebTree','Modes','cancelTool');
        end
    end
end


