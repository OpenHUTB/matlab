classdef EvolutionTreeListManager<handle




    properties(Hidden,SetAccess=immutable)
EventHandler
CacheManager
ProjectInterface
AppModel
    end

    properties(SetAccess=protected,GetAccess=public)
CurrentSelected
    end

    methods
        function treeList=getTreeList(this,projectInfo)
            treeList=this.ProjectInterface.getEvolutionTrees(projectInfo);
        end

        function treeMap=getTreeMap(this,projectInfo)
            treeList=getTreeList(this,projectInfo);
            treeMap=populateTreeMap(this,treeList);
        end

        function[trees,firstTreeProjectInfo]=getAllTrees(this,projectInfos)
            trees=[];
            firstTreeProjectInfo=[];
            for idx=1:numel(projectInfos)
                treeList=getTreeList(this,projectInfos(idx));
                trees=[trees,treeList];%#ok<AGROW>
                if isequal(numel(trees),1)


                    firstTreeProjectInfo=projectInfos(idx);
                end
            end
        end
    end

    methods
        function this=EvolutionTreeListManager(appModel)
            this.AppModel=appModel;
            this.EventHandler=appModel.EventHandler;
            this.ProjectInterface=appModel.ProjectInterface;
            this.CacheManager=appModel.CacheManager;
            this.CacheManager.createCache('LastTree','',@this.updateTreeCache);
            update(this);
        end

        function update(this)
            this.selectCurrentTree;
            notify(this.EventHandler,'EvolutionTreeListManagerChanged');
        end

        function setCurrentTree(this,tree)
            this.CurrentSelected=tree;
            if~isempty(tree)
                this.CacheManager.updateCache('LastTree');
            end
            notify(this.EventHandler,'EvolutionTreeSelectionChanged');
        end

        function treeNames=getTreeNames(~,treeMap)
            treeNames=keys(treeMap);
        end

        function treeMap=populateTreeMap(~,treeList)
            treeMap=containers.Map;
            for idx=1:numel(treeList)
                tree=treeList(idx);
                treeMap(tree.Id)=tree;
            end
        end

        function treeInfo=getTreeInfo(this,projectInfo,name)
            treeMap=getTreeMap(this,projectInfo);
            treeInfo=treeMap(name);
        end

        function newData=updateTreeCache(this,oldData)
            if~isempty(this.CurrentSelected)
                curId=string(this.CurrentSelected.Id);

                foundIdx=oldData==curId;
                oldData(foundIdx)=[];

                if numel(oldData)==10
                    oldData(10)=[];
                end
                newData=[curId,oldData];
            else
                newData=oldData;
            end
        end

        function selectCurrentTree(this)
            [idsToTrees,youngestTreeId]=this.gatherTreeInformation;
            if idsToTrees.Count==0

                setCurrentTree(this,[]);
            else


                projectTreeIds=idsToTrees.keys;
                lastSelectedId=this.findCacheLastSelected(projectTreeIds);
                if isempty(lastSelectedId)


                    this.setTreeIfNeeded(idsToTrees,youngestTreeId);
                else

                    this.setTreeIfNeeded(idsToTrees,lastSelectedId);
                end
            end
        end

        function setTreeIfNeeded(this,idsToTrees,treeId)
            treeToSelect=idsToTrees(treeId);
            if isempty(this.CurrentSelected)||treeToSelect~=this.CurrentSelected








                this.setCurrentTree(treeToSelect);
            end
        end

        function[idsToTrees,youngestTreeId]=gatherTreeInformation(this)
            idsToTrees=containers.Map;
            youngestTreeId='';
            youngestTreeCreationTime='';
            projectRefListModel=getSubModel(this.AppModel,'ProjectReferenceListManager');
            projectInfos=projectRefListModel.ReferenceList;
            for prjIdx=1:numel(projectInfos)
                curPrjInfo=projectInfos(prjIdx);
                treeList=this.ProjectInterface.getEvolutionTrees(curPrjInfo);
                for treeIdx=1:numel(treeList)
                    curTree=treeList(treeIdx);
                    if isempty(youngestTreeCreationTime)
                        youngestTreeCreationTime=curTree.Created;
                        youngestTreeId=curTree.Id;
                    end

                    if curTree.Created>youngestTreeCreationTime
                        youngestTreeId=curTree.Id;
                        youngestTreeCreationTime=curTree.Created;
                    end
                    idsToTrees(curTree.Id)=curTree;
                end
            end
        end

        function lastSelectedId=findCacheLastSelected(this,projectTreeIds)
            cachedTreeIds=this.CacheManager.getCacheData('LastTree');

            projectTreeIds=string(projectTreeIds);
            cachedTreeIds=string(cachedTreeIds);
            lastSelectedId='';
            idIdx=Inf;
            for prjIdx=1:numel(projectTreeIds)
                curPrjTreeId=projectTreeIds(prjIdx);

                pos=find(cachedTreeIds==curPrjTreeId);
                if~isempty(pos)


                    if pos<idIdx
                        idIdx=pos;
                    end
                end
            end
            if isfinite(idIdx)

                lastSelectedId=cachedTreeIds(idIdx).char;
            end
        end

    end
end
