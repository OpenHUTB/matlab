classdef ComparisonController<handle





    properties(SetAccess=immutable)
AppController
AppModel
AppView
CompareManager
EventHandler
InspectorView
    end

    properties(SetAccess=protected)


TreeSelectionChangedListener
FileListChangedListener
EdgeClickChangedListener
CompareButtonClickedListener
ActiveFileEditedListener
EvolutionNameChangedListener
DescriptionChangeListener
EvolutionSelectionChangedListener
EvolutionTreeSelectionChangedListener
OnDiskDataChangeListener
    end

    methods
        function this=ComparisonController(parentController)

            appController=parentController.AppController;
            this.AppController=appController;
            this.AppModel=getAppModel(appController);
            this.AppView=getAppView(appController);
            this.EventHandler=parentController.AppController.EventHandler;

            this.CompareManager=getSubModel(this.AppModel,'Compare');
            this.InspectorView=getSubView(this.AppView,'PropertyInspector');
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
            update(this.CompareManager);
            update(view,this.CompareManager);
        end

    end

    methods(Access=protected)
        function deleteListeners(this)
            listeners=["EdgeClickChangedListener",...
            "CompareButtonClickedListener",...
            "TreeSelectionChangedListener",...
            "FileListChangedListener",...
            "ActiveFileEditedListener",...
            "EvolutionNameChangedListener",...
            "DescriptionChangeListener",...
            "OnDiskDataChangeListener"];
            evolutions.internal.ui.deleteListeners(this,listeners);
        end

        function installModelListeners(this)


            this.EvolutionSelectionChangedListener=...
            listener(this.EventHandler,'EvolutionChanged',@this.onEvolutionSelectionChanged);

            this.EvolutionTreeSelectionChangedListener=...
            addlistener(this.EventHandler,'EvolutionTreeSelectionChanged',@this.onEvolutionTreeSelectionChanged);

            this.OnDiskDataChangeListener=evolutions.internal.session...
            .EventHandler.subscribe('OnDiskFileChanged',@this.changeDeltas);
        end

        function installViewListeners(this)
            view=this.InspectorView;
            this.EdgeClickChangedListener=...
            listener(view,'EdgeClicked',@this.changeDeltas);

            this.CompareButtonClickedListener=...
            listener(view,'CompareButtonClicked',@this.launchCompareVisDiff);

            this.ActiveFileEditedListener=...
            listener(this.EventHandler,'FileOnDiskChange',@this.changeDeltas);

            this.TreeSelectionChangedListener=...
            listener(this.EventHandler,'TreeSelectionChanged',@this.onTreeSelectionChanged);

            this.FileListChangedListener=...
            listener(this.EventHandler,'FileListChanged',@this.changeDeltas);

            this.EvolutionNameChangedListener=...
            listener(this.EventHandler,'EvolutionNameChanged',@this.changeDeltas);

            this.DescriptionChangeListener=...
            listener(view,'EdgeDescriptionChanged',@this.onDescriptionChange);

        end

        function onEvolutionSelectionChanged(this,~,~)
            if~isvalid(this.CompareManager.CompareEdge)
                this.CompareManager.CompareEdge=evolutions.model.Edge.empty(1,0);
            end
        end

        function onEvolutionTreeSelectionChanged(this,evt,data)
            this.onTreeSelectionChanged(evt,data);
        end

        function onTreeSelectionChanged(this,evt,data)
            this.CompareManager.CompareEdge=evolutions.model.Edge.empty(1,0);
            this.changeDeltas(evt,data);
        end

        function onDescriptionChange(this,~,data)
            infoData=data.EventData;
            currentEdge=this.CompareManager.CompareEdge;


            infoData=jsonencode(infoData);




            infoData=extractAfter(infoData,1);
            infoData=extractBefore(infoData,length(infoData));


            currentEdge.Description=infoData;
            treeList=getSubModel(this.AppModel,'EvolutionTreeListManager');
            tree=treeList.CurrentSelected;
            tree.save;

            updateEdgeSummary(this.CompareManager,currentEdge);
        end

        function launchCompareVisDiff(this,~,data)

            fromEvolutionId=data.EventData.fromEvolutionId;
            toEvolutionId=data.EventData.toEvolutionId;
            changedFileName=data.EventData.fileName;


            try
                this.AppController.ServerInterface.compareFiles(fromEvolutionId,toEvolutionId,changedFileName);
            catch ME
                handleException(this.AppController,ME);
            end

        end

        function differenceArray=fileDifferenceArray(~,fileList)
            differenceArray={numel(fileList)};
            if(numel(fileList)>0)
                for fileIndex=1:numel(fileList)
                    differenceArray{fileIndex}=fileList(fileIndex).File;
                end
            end
        end

        function changeDeltas(this,~,~)
            treeManager=getSubModel(this.AppModel,'EvolutionsTreeManager');
            rootEvolution=treeManager.RootEvolution;
            eis={};
            currentProjectPath='';
            if~isempty(rootEvolution)
                currentProjectPath=rootEvolution.Project.RootFolder;
                eis=gatherAllEis(this,rootEvolution);
            end
            differencesStruct=this.getDifferencesBetweenEvolutions(eis);
            setDifferences(this.CompareManager,differencesStruct,currentProjectPath);
            update(this)
        end

        function differencesStruct=getDifferencesBetweenEvolutions(this,eis)
            differencesStruct={};
            for eiIndex=1:numel(eis)
                curEi=eis(eiIndex);
                for childIdx=1:numel(curEi.Children)
                    nodeOnCompareDropDown=eis(eiIndex);
                    nodeOnTree=curEi.Children(childIdx);
                    differences=this.calculateDifferenceBetweenEvolutions(nodeOnTree,nodeOnCompareDropDown);
                    differencesStruct{end+1}=struct("from",eis(eiIndex).Id,"fromEvolution",eis(eiIndex).getName,...
                    "to",curEi.Children(childIdx).Id,"toEvolution",curEi.Children(childIdx).getName,"differences",differences);%#ok<AGROW>
                end
            end
        end

        function differences=calculateDifferenceBetweenEvolutions(this,nodeOnTree,nodeOnCompareDropDown)
            if~isempty(nodeOnTree)&&~isempty(nodeOnCompareDropDown)
                differences=this.AppController.ServerInterface.calculateEvolutionDifferences...
                (nodeOnTree,nodeOnCompareDropDown);
            end
        end

        function eis=gatherAllEis(this,ei)
            eis=ei;
            eis=addChildrenRecursively(this,eis,ei);
        end

        function eis=addChildrenRecursively(this,eis,ei)
            children=ei.Children;
            for chdIdx=1:numel(children)
                curChild=children(chdIdx);
                eis=[eis,curChild];%#ok<AGROW>
                eis=addChildrenRecursively(this,eis,curChild);
            end
        end

    end
end


