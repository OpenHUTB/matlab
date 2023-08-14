classdef Tree<handle




    properties(SetObservable=true)
        interface=[]
        root=[]
        resultsExplorer=[]
        name=''
        isActive=false
        needAggregate=false
        activeTab=0
        isCodeFilterTab=false
    end
    methods(Static=true)
        function tree=create(tag,resultsExplorer)
            tree=cvi.ResultsExplorer.Tree(tag,resultsExplorer);
            tree.interface=SlCovResultsExplorer.Folder(resultsExplorer,tree);
            tree.root=cvi.ResultsExplorer.Node(tree,[]);

            tree.root.interface=tree.interface;

        end

        function tabChangedCallback(dlg,~,idx)
            dlg.getSource.m_impl.activeTab=idx;
        end

        function filterTabChangedCallback(hDialog,~,tab_Index)
            if isa(hDialog.getSource,'SlCovResultsExplorer.Folder')
                src=hDialog.getSource;
                src.m_impl.isCodeFilterTab=tab_Index==1;
                hDialog.refresh();
            end
        end

    end
    methods

        function tree=Tree(name,resultsExplorer)

            tree.resultsExplorer=resultsExplorer;
            tree.name=name;
        end


        function label=getDisplayLabel(tree)
            label=tree.name;
            if tree.isActive
                if numel(tree.root.children)>1
                    if isempty(tree.root.data)||tree.root.data.needSave
                        label=[label,'*'];
                    end
                end
                if tree.resultsExplorer.highlightedNode==tree.root
                    label=[label,' (H)'];
                end
            end
        end


        function icon=getDisplayIcon(obj)

            if obj.resultsExplorer.root.passiveTree==obj
                icon=fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','folder_open.png');
            else
                icon=fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','AddData.png');
            end

        end

        function setSaveIds(tree,node,nodeMap)
            node.saveId=nodeMap.size(1)+1;
            nodeMap(node.saveId)=node;
            children=node.children;

            for idx=1:numel(children)
                setSaveIds(tree,children{idx},nodeMap);
            end

        end

        function newNode=copyTreeNode(tree,nodes,treeDst)
            for idx=1:numel(nodes)

                node=nodes{idx};
                if~node.data.marked
                    node.data.mark;

                    if~isempty(node.parentTree.root.data)
                        node.parentTree.root.data.needSave=true;
                    end

                    newNode=cvi.ResultsExplorer.Node.createRef(node,tree);
                    treeDst.addNodeToRoot(newNode);
                end
            end
        end

        function addNodeToRoot(tree,childNode)
            tree.root.addChild(childNode);
            childNode.parentTree=tree;
        end


        function removeTreeNode(tree,childNodes)
            for idx=1:numel(childNodes)
                childNode=childNodes{idx};

                removeChild(childNode);

                if~isempty(tree.root.data)
                    tree.root.data.needSave=true;
                end
            end
        end

        function nodeDst=copyTree(tree,nodeSrc,treeDst)
            nodeDst=treeDst.root;
            treeDst.root.data=nodeSrc.data;
            tree.copyTreeNode(nodeSrc.children,treeDst);
        end

        function removeTree(tree,node)

            tree.removeTreeNode(node.children);
            tree.removeTreeNode({node});
            delete(node.data);
            node.data=[];

        end


        function nodes=getAllNodes(tree,childNodes)
            nodes={};
            for idx=1:numel(childNodes)
                n=childNodes{idx};
                nodes=[childNodes,tree.getAllNodes(n.children)];
            end
        end

        function res=isempty(tree)
            res=numel(tree.root.children)==0;
        end


        function str=print(tree,root)
            strch='';
            str=root.print;
            if isempty(root.children)
                return;
            end
            for idx=1:numel(root.children)
                ch=root.children{idx};
                strch=[strch,'{',print(tree,ch),'}'];%#ok<AGROW>
            end
            str=[str,strch];
        end


        function retVal=getPropertyStyle(tree,~)
            retVal=DAStudio.PropertyStyle;
            if tree.isActive
                retVal.Tooltip=getString(message('Slvnv:simcoverage:cvresultsexplorer:ActiveTreeName'));
            else
                retVal.Tooltip=getString(message('Slvnv:simcoverage:cvresultsexplorer:AvailableData'));
            end
        end

        function actionCallback(obj,action)
            try
                switch action
                case{'folderOpen'}
                    pDir=uigetdir(obj.resultsExplorer.getInputDir());
                    if ischar(pDir)&&isfolder(pDir)
                        obj.resultsExplorer.setInputDir(pDir);
                        obj.resultsExplorer.syncAllData();
                    end
                case{'modelOpen'}
                    open_system(obj.resultsExplorer.topModelName);
                case{'syncFolder'}
                    obj.resultsExplorer.syncAllData();
                end

            catch MEx
                display(MEx.stack(1));
            end
        end

        function cm=getContextMenu(obj)
            try


                cm=[];
                if obj.isActive
                    if obj.isempty
                        return;
                    end
                    re=obj.resultsExplorer;
                    cvi.ResultsExplorer.ResultsExplorer.activeNode(obj.root,re.topModelName);
                    e=re.explorer;
                    cm=re.am.createPopupMenu(e);
                    if numel(obj.root.children)>1
                        saveText=getString(message('Slvnv:simcoverage:cvresultsexplorer:SaveCumData'));
                        eMenu=re.am.createAction(e,...
                        'Text',saveText,...
                        'Tag','SaveCumData',...
                        'Callback',re.getCallbackString('saveCumDataCallback'),...
                        'Icon',fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','Save.png'),...
                        'StatusTip','Save');
                        cm.addMenuItem(eMenu);
                    end
                    excludeAllText=getString(message('Slvnv:simcoverage:cvresultsexplorer:ExcludeAll'));
                    eMenu=re.am.createAction(e,...
                    'Text',excludeAllText,...
                    'Tag','ExcludeAll',...
                    'Callback',re.getCallbackString('clearCallback'),...
                    'Icon',fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','Delete_X.png'),...
                    'StatusTip','Delete');
                    cm.addMenuItem(eMenu);

                else
                    re=obj.resultsExplorer;
                    cvi.ResultsExplorer.ResultsExplorer.activeNode(obj.root,re.topModelName);
                    e=re.explorer;
                    cm=re.am.createPopupMenu(e);
                    loadText=getString(message('Slvnv:simcoverage:cvresultsexplorer:Load'));
                    eMenu=re.am.createAction(e,...
                    'Text',loadText,...
                    'Tag','Load',...
                    'Callback',re.getCallbackString('loadCallback'),...
                    'Icon',fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','Open.png'),...
                    'StatusTip','Load');
                    cm.addMenuItem(eMenu);
                    saveAllText=getString(message('Slvnv:simcoverage:cvresultsexplorer:SaveAllData'));
                    eMenu=re.am.createAction(e,...
                    'Text',saveAllText,...
                    'Tag','SaveAllData',...
                    'Callback',re.getCallbackString('saveAllDataCallback'),...
                    'Icon',fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','Save.png'),...
                    'StatusTip',getString(message('Slvnv:simcoverage:cvresultsexplorer:SaveToolTip')));
                    cm.addMenuItem(eMenu);

                    if(strcmp(cv('Feature','RE Data Repository Include All'),'on'))
                        allMarked=true;
                        for r=1:numel(obj.root.children)
                            childNode=obj.root.children{r};
                            if~childNode.data.marked&&~childNode.allChildrenMarked
                                allMarked=false;
                                break;
                            end
                        end
                        if(~allMarked)
                            includeText=getString(message('Slvnv:simcoverage:cvresultsexplorer:IncludeAll'));
                            eMenu=re.am.createAction(e,...
                            'Text',includeText,...
                            'Tag','IncludeAll',...
                            'Callback',re.getCallbackString('addAllCallback'),...
                            'Icon',fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','AddData.png'),...
                            'StatusTip','Include All');
                            cm.addMenuItem(eMenu);
                        end
                    end
                end
            catch MEx
                display(MEx.stack(1));
            end
        end
    end
end
