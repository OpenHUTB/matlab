classdef EvolutionInfoController<handle





    properties(SetAccess=immutable)
AppController
AppModel
AppView
DocumentController
InspectorView
EvolutionInfoManager


EventHandler
    end

    properties(SetAccess=protected)

EvolutionInfoChangeListener
NameChangeListener
DescriptionChangeListener
TreeSelectionChangeListener
    end

    methods
        function this=EvolutionInfoController(parentController)

            this.DocumentController=parentController;
            appController=parentController.AppController;
            this.AppController=appController;
            this.AppModel=getAppModel(appController);
            this.AppView=getAppView(appController);
            this.EventHandler=parentController.AppController.EventHandler;

            this.InspectorView=getSubView(this.AppView,'PropertyInspector');
            this.EvolutionInfoManager=getSubModel(this.AppModel,'EvolutionSummary');
        end

        function setup(this)

            installModelListeners(this);
            installViewListeners(this);
        end

        function delete(this)

            deleteListeners(this)
        end

        function update(this)
            view=this.InspectorView;
            update(view,this.EvolutionInfoManager);
        end

    end

    methods(Access=protected)
        function deleteListeners(this)

            listeners=["NameChangeListener",...
            "DescriptionChangeListener",...
            "EvolutionInfoChangeListener",...
            "TreeSelectionChangeListener"];
            evolutions.internal.ui.deleteListeners(this,listeners);
        end

        function installModelListeners(this)
            this.EvolutionInfoChangeListener=evolutions.internal.session...
            .EventHandler.subscribe('EiDataChanged',@this.onEvolutionInfoChange);
            this.TreeSelectionChangeListener=...
            listener(this.EventHandler,'TreeSelectionChanged',@this.onTreeSelectionChange);
        end

        function installViewListeners(this)
            view=this.InspectorView;
            this.NameChangeListener=...
            listener(view,'EIValueChanged',@this.onNameChange);
            this.DescriptionChangeListener=...
            listener(view,'EIDescriptionChanged',@this.onDescriptionChange);
        end

        function onNameChange(this,~,data)
            newName=data.EventData;
            evolutionNameChangeAction(this,newName);

        end

        function onEvolutionInfoChange(this,~,data)
            changedTree=data.EventData;
            evolutionTreeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            currentTree=evolutionTreeListManager.CurrentSelected;
            if isequal(changedTree,currentTree)
                notify(this.EventHandler,'EvolutionNameChanged');
            end
        end

        function onDescriptionChange(this,~,data)
            infoData=data.EventData;
            evolutionTreeManager=getSubModel(this.AppModel,'EvolutionsTreeManager');
            currentNode=evolutionTreeManager.SelectedEvolution;



            infoData=jsonencode(infoData);




            infoData=extractAfter(infoData,1);
            infoData=extractBefore(infoData,length(infoData));


            currentNode.Description=infoData;
            treeList=getSubModel(this.AppModel,'EvolutionTreeListManager');
            tree=treeList.CurrentSelected;
            tree.save;

            updateEvolutionSummary(this.EvolutionInfoManager,currentNode);
        end

        function onTreeSelectionChange(this,~,data)

            updateEvolutionSummary(this.EvolutionInfoManager,data.EventData);
            update(this);

        end
    end

    methods
        function evolutionNameChangeAction(this,newName)
            evolutionTreeManager=getSubModel(this.AppModel,'EvolutionsTreeManager');
            currentNode=evolutionTreeManager.SelectedEvolution;
            this.AppController.ServerInterface.changeEvolutionInfoName(currentNode,newName);
            updateEvolutionSummary(this.EvolutionInfoManager,currentNode);
            update(this);
        end
    end

end


