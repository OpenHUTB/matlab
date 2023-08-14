classdef FilterTree<handle




    properties(SetObservable=true)
        interface=[]
        root=[]
        filterExplorer=[]
        name=''
        activeTab=0
        isCodeFilterTab=false
    end
    properties(Constant)
        dlgTag='FilterTree_';
    end

    methods(Static=true)

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

        res=getCallbackString(command,filterExplorerUUID,varargin)

        aNode=menuNode(varargin)

        function removeFilterCallback(uuid)
            filterNode=cvi.FilterExplorer.FilterTree.menuNode(uuid);
            filterNode.revert();
            filterExplorer=filterNode.parentTree.filterExplorer;
            filterExplorer.removeFilter(filterNode.filterRec.uuid);
        end

        function addNewFilterCallback(filterExplorerUUID)
            filterExplorer=cvi.FilterExplorer.FilterTree.menuNode(filterExplorerUUID);
            filterExplorer.newFilter();
        end

        function loadFilterCallback(filterExplorerUUID)
            filterExplorer=cvi.FilterExplorer.FilterTree.menuNode(filterExplorerUUID);
            filterExplorer.loadFilter();
        end

        function makeDeadLogicFilterCallback(filterExplorerUUID,type)
            filterExplorer=cvi.FilterExplorer.FilterTree.menuNode(filterExplorerUUID);

            if~isempty(filterExplorer.resultsExplorer)
                obj=filterExplorer.resultsExplorer;
            else
                obj=filterExplorer;
            end

            if strcmpi(type,'sldv')
                filterObj=filterExplorer.newFilter('sldv');
                cvi.ResultsExplorer.ResultsExplorer.makeFilterCallback(obj,obj.topModelName,filterObj);
            elseif strcmpi(type,'polyspace')
                filterObj=filterExplorer.newFilter('polyspace');
                obj.makeCodeProverFilterCallback(filterObj);
            end
        end

    end
    methods

        function tree=FilterTree(name,filterExplorer)

            tree.filterExplorer=filterExplorer;
            tree.name=name;
            tree.interface=SlCovResultsExplorer.Folder(filterExplorer,tree);
            tree.root=cvi.FilterExplorer.FilterNode(tree,[]);

            tree.root.interface=tree.interface;

        end

        function filterNode=getSelectedNode(obj)
            filterNode=[];
            activeDlg=obj.filterExplorer.imme.getDialogHandle;
            if~isempty(activeDlg)
                src=activeDlg.getSource;
                if isa(src,'SlCovResultsExplorer.Data')
                    filterNode=src.m_impl;
                end
            end
        end


        function selectRoot(obj)
            obj.filterExplorer.imme.selectTreeViewNode(obj.root.interface);
        end

        function expandRoot(obj)
            obj.filterExplorer.imme.expandTreeNode(obj.root.interface);
        end

        function setSelectedNode(obj,node)
            obj.filterExplorer.imme.selectTreeViewNode(node.interface);
        end


        function filterNode=addNewFilterNode(obj,filterRec)
            filterNode=cvi.FilterExplorer.FilterNode(obj,filterRec);
            obj.addNodeToRoot(filterNode);
            obj.show();
        end


        function removeFilterNode(obj,filterId)
            node=obj.findNodeById(filterId);
            node.removeChild();
        end


        function addNodeToRoot(tree,childNode)
            tree.root.addChild(childNode);
            childNode.parentTree=tree;
        end


        function node=findNodeById(obj,filterId)
            node=[];


            for idx=1:numel(obj.root.children)
                if strcmpi(obj.root.children{idx}.filterRec.uuid,filterId)
                    node=obj.root.children{idx};
                end
            end
        end

        function show(obj,filterId,forCode)
            if nargin<2
                filterId='';
            end

            if nargin<3
                forCode=false;
            end
            node=[];
            if~isempty(filterId)
                node=findNodeById(obj,filterId);
                setSelectedNode(obj,node);
            end

            filterObj=[];
            if~isempty(node)
                filterObj=node.filterRec.filterObj;
            end


            if~isempty(filterObj)&&(~filterObj.isEmpty()||filterObj.hasUnappliedChanges)
                activeDlg=obj.filterExplorer.imme.getDialogHandle;
                if~isempty(activeDlg)
                    if filterObj.hasUnappliedChanges
                        activeDlg.enableApplyButton(true);
                    end
                    fnDlgTag=cvi.FilterExplorer.FilterNode.dlgTag;
                    SlCov.FilterEditor.activateTab(activeDlg,fnDlgTag,forCode);

                    widgetName='filterState';

                    if forCode
                        widgetName=['c',widgetName];
                        SlCov.FilterEditor.updateFilterNameWidget(activeDlg,forCode)
                    end

                    tableWidgetTag=[fnDlgTag,widgetName];
                    activeDlg.refresh();
                    idx=activeDlg.getSelectedTableRow(tableWidgetTag);
                    activeDlg.ensureTableRowVisible(tableWidgetTag,idx);

                end
            end
        end

        function showFilterRule(obj,filterId,ssid,idx,outcomeIdx,metricName,forCode)
            obj.show(filterId,forCode);

            node=obj.getSelectedNode;
            filterObj=node.filterRec.filterObj;
            filterObj.showMetricRule(ssid,idx,outcomeIdx,metricName,forCode,obj.filterExplorer.imme.getDialogHandle,'Tree_');
        end


        function label=getDisplayLabel(obj)
            label=sprintf('%s (%d)',obj.name,numel(obj.root.children));
        end


        function icon=getDisplayIcon(obj)

            icon=fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','multipleFilter.png');

        end


        function res=isEmpty(obj)
            res=numel(obj.root.children)==0;
        end
        function res=isSingle(obj)
            res=numel(obj.root.children)==1;
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


        function retVal=getPropertyStyle(~,~)
            retVal=DAStudio.PropertyStyle;
            retVal.Tooltip=getString(message('Slvnv:simcoverage:cvresultsexplorer:AvailableData'));
        end


        function cm=getContextMenu(obj)
            try
                cm=[];

                e=obj.filterExplorer.explorer;
                am=obj.filterExplorer.am;
                cm=am.createPopupMenu(e);

                newFilterText=getString(message('Slvnv:simcoverage:cvresultsexplorer:NewFilter'));
                newFilterMenu=am.createAction(e,...
                'Text',newFilterText,...
                'Tag','New filter',...
                'Callback',cvi.FilterExplorer.FilterTree.getCallbackString('addNewFilterCallback',obj.filterExplorer.getUUID),...
                'Icon',fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','AddData.png'),...
                'StatusTip','Exclude');

                cm.addMenuItem(newFilterMenu);
                newFilterText=getString(message('Slvnv:simcoverage:cvresultsexplorer:LoadFilter'));
                newFilterMenu=am.createAction(e,...
                'Text',newFilterText,...
                'Tag','Load filter',...
                'Callback',cvi.FilterExplorer.FilterTree.getCallbackString('loadFilterCallback',obj.filterExplorer.getUUID),...
                'Icon',fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','Open.png'),...
                'StatusTip','Exclude');

                cm.addMenuItem(newFilterMenu);
                cvi.FilterExplorer.FilterTree.menuNode(obj.filterExplorer.getUUID,obj.filterExplorer);

            catch MEx
                display(MEx.stack(1));
            end
        end




    end
end
