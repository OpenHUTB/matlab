classdef WizardController<handle



    properties(SetAccess=immutable)

AppController
AppModel
AppView
EventHandler
EvolutionsTreeManager
FileListManager
TreeListManager
EvolutionSummaryManager
EvolutionsTreeSummaryManager

MessageChannel
JSWebChannelForProjectValues


        FileListMessageChannel='/Wizard'
        StartupWizardChannel='/Wizard/startupWizard'
        ProjectValuesMessageChannel='/WebTree';
    end

    properties(SetAccess=protected)

FileListChangedListener
CreateButtonActionListener
StartupWizardActionListener
    end

    methods
        function this=WizardController(appController)
            this.AppController=appController;
            this.AppModel=getAppModel(appController);
            this.AppView=getAppView(appController);
            this.EventHandler=appController.EventHandler;
            this.EvolutionsTreeManager=getSubModel(this.AppModel,'EvolutionsTreeManager');
            this.EvolutionsTreeSummaryManager=getSubModel(this.AppModel,'EvolutionTreeSummary');
            this.FileListManager=getSubModel(this.AppModel,'FileList');
            this.TreeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            this.EvolutionSummaryManager=getSubModel(this.AppModel,'EvolutionSummary');
            this.MessageChannel=getMsgChannel(this.AppView);


            this.JSWebChannelForProjectValues=this.MessageChannel+this.ProjectValuesMessageChannel;
        end

        function setup(this)

            installModelListeners(this);
            installViewListeners(this);
        end


        function delete(this)

            deleteListeners(this);
        end

        function deleteListeners(this)

            listeners=["FileListChangedListener","CreateButtonActionListener","StartupWizardActionListener"];
            evolutions.internal.ui.deleteListeners(this,listeners);
        end

        function installModelListeners(this)
            this.FileListChangedListener=evolutions.internal.ui.tools.JSSubscription.subscribe...
            (this,this.MessageChannel,@this.FileListCallback,this.FileListMessageChannel);
            this.StartupWizardActionListener=evolutions.internal.ui.tools.JSSubscription.subscribe...
            (this,this.MessageChannel,@this.StartupWizardCallback,this.StartupWizardChannel);
        end

        function installViewListeners(~)
        end

        function StartupWizardCallback(this,data)
            viewField=data.item;
            viewValue=data.value;
            if(~isempty(data.value))
                switch viewField
                case 'WizardCreateAction'
                    this.setupCreateAction(viewValue)
                case 'HelpIconAction'
                    this.HelpIconActionActionCallback(viewValue)
                end
            end
        end

        function HelpIconActionActionCallback(~,data)
            helpview(fullfile(docroot,data.toolbox,data.map),data.anchor);
        end

        function FileListCallback(this,~)
            bringUpStartupwizard=false;
            if isempty(this.EvolutionsTreeManager.RootEvolution)
                bringUpStartupwizard=true;
            end
            allProjectFiles=this.FileListManager.AllProjectFiles;
            valsStruct=struct('allProjectFiles',{allProjectFiles},'startUpWizard',bringUpStartupwizard);
            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.MessageChannel+this.FileListMessageChannel,'allProjectfilesStruct',valsStruct);
        end
    end

    methods(Access=private)
        function setupCreateAction(this,value)





            this.AppView.disableProgressDialog;
            this.AppView.setBusy;
            cleanup=onCleanup(@()clearBusy(this.AppView));
            enableDialogs=onCleanup(@()enableProgressDialog(this.AppView));

            inspectorValues=value.inspectorValue;
            appActions=value.appActions;

            projectPath=appActions.projectPath;

            EvoutionTreeName=inspectorValues.EtiName;
            EvoutionTreeDescription=inspectorValues.EtiDescription;

            editDesc=~(EvoutionTreeDescription=="");
            editName=~(EvoutionTreeName=="");






            this.createNewTree(projectPath);
            this.AppController.ServerInterface.syncFilesWithProject();
            this.createEvolution();
            this.editDescription(editDesc,EvoutionTreeDescription);
            this.editName(editName,EvoutionTreeName);


            EvolutionsTreeInfoManager=getSubModel(this.AppModel,'EvolutionTreeSummary');
            update(EvolutionsTreeInfoManager);


            this.getProjectTreeMap;
        end

        function createNewTree(this,projectPath)
            DocumentController=getSubController(this.AppController,'document');
            EvolutionWebPlotController=DocumentController.EvolutionTreeDocumentController.EvolutionPlotController;

            EvolutionWebPlotController.onCreateTreeButtonClick(projectPath);
        end


        function createEvolution(this)

            evolutionsSectionController=getSubController(this.AppController,'evolutions');
            evolutionsSectionController.createEvolution();
            editEvolutionName(this,getString(message('evolutions:ui:BaselineName')));

            rootEvolution=this.EvolutionsTreeManager.RootEvolution;
            documentView=getSubView(this.AppView,'DocumentView');
            evolutionTreeDocumentView=getSubView(documentView,'EvolutionTreeDocument');
            evolutionPlotView=getSubView(evolutionTreeDocumentView,'EvolutionPlotView');
            update(evolutionPlotView,rootEvolution,false);
        end

        function editDescription(this,editDesc,EvoutionTreeDescription)

            if(editDesc)
                InspectorView=getSubView(this.AppView,'PropertyInspector');
                treeInfo=this.TreeListManager.CurrentSelected;



                treeInfo.Description=EvoutionTreeDescription;
                treeInfo.save;


                update(this.EvolutionsTreeSummaryManager)
                update(InspectorView,this.EvolutionsTreeSummaryManager)
            end
        end

        function editEvolutionName(this,EvolutionName)
            InspectorView=getSubView(this.AppView,'PropertyInspector');
            currentNode=this.EvolutionsTreeManager.SelectedEvolution;
            this.AppController.ServerInterface.changeEvolutionInfoName(currentNode,EvolutionName);
            update(InspectorView,this.EvolutionSummaryManager);
        end

        function editName(this,editName,EvoutionTreeName)

            if(editName)
                newName=EvoutionTreeName;
                treeInfo=this.TreeListManager.CurrentSelected;
                this.AppController.ServerInterface.changeEvolutionTreeName(treeInfo,newName);
            end
        end

        function getProjectTreeMap(this)
            projectRefListModel=getSubModel(this.AppModel,'ProjectReferenceListManager');
            projectList=getProjectFullPath(projectRefListModel);
            projDir=cell.empty;
            for idx=1:numel(projectList)
                projectName=projectList{idx};
                [~,projectDir]=fileparts(projectName);
                projDir{idx}=projectDir;
            end
            valsStruct=struct('projNames',projDir,'projPaths',projectList);
            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.JSWebChannelForProjectValues,'BundledMsg',valsStruct);
        end

    end

end


