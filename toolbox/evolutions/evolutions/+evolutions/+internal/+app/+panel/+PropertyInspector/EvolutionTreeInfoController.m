classdef EvolutionTreeInfoController<handle






    properties(SetAccess=immutable)
AppController
AppModel
AppView
DocumentController
InspectorView
EvolutionsTreeInfoManager


EventHandler
    end

    properties(SetAccess=protected)

EvolutionTreeInfoChangeListener
NameChangeListener
DescriptionChangeListener
    end


    methods
        function this=EvolutionTreeInfoController(parentController)

            this.DocumentController=parentController;
            appController=parentController.AppController;
            this.AppController=appController;
            this.AppModel=getAppModel(appController);
            this.AppView=getAppView(appController);
            this.EventHandler=parentController.AppController.EventHandler;

            this.InspectorView=getSubView(this.AppView,'PropertyInspector');
            this.EvolutionsTreeInfoManager=getSubModel(this.AppModel,'EvolutionTreeSummary');
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
            update(view,this.EvolutionsTreeInfoManager);
        end

    end

    methods(Access=protected)
        function deleteListeners(this)

            listeners=["NameChangeListener",...
            "DescriptionChangeListener",...
            "EvolutionTreeInfoChangeListener"];
            evolutions.internal.ui.deleteListeners(this,listeners);
        end

        function installModelListeners(this)
            this.EvolutionTreeInfoChangeListener=evolutions.internal.session...
            .EventHandler.subscribe('EtiDataChanged',@this.onEvolutionTreeInfoChange);
        end

        function installViewListeners(this)

            view=this.InspectorView;
            this.NameChangeListener=...
            listener(view,'ETIValueChanged',@this.onNameChange);
            this.DescriptionChangeListener=...
            listener(view,'ETIDescriptionChanged',@this.onDescriptionChange);
        end

        function onNameChange(this,~,data)
            newName=data.EventData;
            treeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            treeInfo=treeListManager.CurrentSelected;
            this.AppController.ServerInterface.changeEvolutionTreeName(treeInfo,newName);
        end

        function onEvolutionTreeInfoChange(this,~,data)
            changedTree=data.EventData;
            evolutionTreeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            currentTree=evolutionTreeListManager.CurrentSelected;
            if isequal(changedTree,currentTree)
                notify(this.EventHandler,'EvolutionTreeNameChanged');
            end
        end

        function onDescriptionChange(this,~,data)
            infoData=data.EventData;
            treeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            treeInfo=treeListManager.CurrentSelected;


            infoData=jsonencode(infoData);




            infoData=extractAfter(infoData,1);
            infoData=extractBefore(infoData,length(infoData));


            treeInfo.Description=infoData;
            treeInfo.save;
        end
    end
end


