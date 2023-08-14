classdef FilterNode<handle




    properties(SetObservable=true)
        interface=[]
        parentTree=[]
        parent=[]
        children=[]

        filterRec=[]

        editNameTag=''
        editDescrTag=''
        uuid=''
    end

    properties(Constant)
        dlgTag='Tree_';
    end
    methods(Static=true)

    end
    methods

        function node=FilterNode(parentTree,filterRec)

            node.parentTree=parentTree;
            node.interface=SlCovResultsExplorer.Data(parentTree.filterExplorer,node);
            if~isempty(filterRec)
                node.filterRec=filterRec;
            end
            guidStr=char(matlab.lang.internal.uuid);
            node.uuid=guidStr;

        end

        function setFilterRec(node,filterRec)
            node.filterRec=filterRec;
        end


        function saveFilter(node)
            node.parentTree.filterExplorer.saveFilter(node.filterRec.uuid);
        end

        function uuid=getUUID(node)
            uuid=node.uuid;
        end

        function str=print(node)
            str=node.getDisplayLabel;
        end

        function addChild(pNode,childNode)
            assert(isempty(childNode.parent));
            pNode.children=[pNode.children,{childNode}];
            childNode.parent=pNode;
            pNode.interface.addToHierarchy(childNode.interface);
        end

        function removeChild(childNode)
            pNode=childNode.parent;
            if~isempty(pNode)
                pChildren=pNode.children;
                didx=[];
                for idx=1:numel(pChildren)
                    if pChildren{idx}==childNode
                        didx=idx;
                        break;
                    end
                end
                if~isempty(didx)
                    childNode.parent.children(didx)=[];
                    childNode.interface.removeFromHierarchy();
                end
                childNode.parent=[];
            end
        end


        function label=getDisplayLabel(node)
            label=node.filterRec.filterObj.filterName;
        end

        function res=hasChildren(node)
            res=~isempty(node.children);
        end

        function chld=getHierarchicalChildren(node)
            chld=node.children;
        end


        function icon=getDisplayIcon(~)
            icon=fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','filter.png');
        end




        function obj=getFilter(node)
            obj=node.filterRec.filterObj;
        end

        function obj=getExplorer(node)
            obj=node.parentTree.filterExplorer;
        end

        function retVal=getPropertyStyle(~,~)

            retVal=DAStudio.PropertyStyle;
            retVal.Tooltip='Filter';
        end

        function revert(obj)
            fe=obj.parentTree.filterExplorer;
            dlg=fe.imme.getDialogHandle;
            if~isempty(dlg)&&dlg.hasUnappliedChanges
                obj.postRevertCallback(dlg);
                dlg.enableApplyButton(false);
            end
        end


        function apply(obj)
            fe=obj.parentTree.filterExplorer;
            dlg=fe.imme.getDialogHandle;
            if~isempty(dlg)
                dlg.apply();
            end
        end

        function[status,id]=preApplyCallback(obj)
            try
                status=true;
                id='';
                fileName=obj.filterRec.fileName;
                if~isempty(fileName)
                    [~,~,~,msg]=cvi.ReportUtils.getFilePartsWithWriteChecks(fileName,'.cvf',true);
                    if~isempty(msg)
                        id=getString(msg);
                        status=false;
                    end
                end
            catch MEx
                display(MEx.stack(1));
            end
        end


        function[status,id]=postApplyCallback(obj,dlg,nameTag,descriptionTag)
            try
                status=true;

                if~isempty(nameTag)
                    fObj=obj.filterRec.filterObj;
                    fObj.filterName=dlg.getWidgetValue(nameTag);
                    checkFilterName(obj.parentTree.filterExplorer,fObj);
                end
                if~isempty(descriptionTag)
                    obj.filterRec.filterObj.filterDescr=dlg.getWidgetValue(descriptionTag);
                end
                obj.parentTree.filterExplorer.filterChangedCallback('changed',obj.filterRec.uuid);
                id='';
                obj.filterRec.filterObj.hasUnappliedChanges=false;
                obj.filterRec.filterObj.lastFilterElement={};
                dlg.refresh();

            catch MEx
                display(MEx.stack(1));
            end
        end

        function[status,id]=closeCallback(obj,dlg,nameTag,descriptionTag)
            status=true;
            id='';
            fe=obj.parentTree.filterExplorer;
            if~isvalid(obj.parentTree.filterExplorer)||...
                (~isempty(fe.resultsExplorer)&&~isvalid(fe.resultsExplorer))
                return;
            end
            if dlg.hasUnappliedChanges
                if strcmpi(obj.parentTree.filterExplorer.ctxType,'STM')
                    title=getString(message('Slvnv:simcoverage:cvresultsexplorer:FilterExplorer'));
                else
                    title=DAStudio.message('Slvnv:simcoverage:cvresultsexplorer:Root');
                end
                applyStr=getString(message('Slvnv:simcoverage:cvresultsexplorer:UnappliedChangesApply'));
                ignoreStr=DAStudio.message('Slvnv:simcoverage:cvresultsexplorer:UnappliedChangesIgnore');
                buttonRes=questdlg(DAStudio.message('Slvnv:simcoverage:cvresultsexplorer:UnappliedChangesMsg'),...
                [title,' - ',DAStudio.message('Slvnv:simcoverage:cvresultsexplorer:UnappliedChangesAplpyChanges')],...
                applyStr,...
                ignoreStr,...
                ignoreStr);
                if strcmpi(buttonRes,applyStr)
                    [status,id]=obj.postApplyCallback(dlg,nameTag,descriptionTag);
                else
                    [status,id]=obj.postRevertCallback(dlg);
                end
            end

        end

        function[status,id]=postRevertCallback(obj,dlg)
            try
                status=true;
                obj.filterRec.filterObj.revert(dlg);
                id='';
            catch MEx
                display(MEx.stack(1));
            end
        end

        function cm=getContextMenu(obj)
            try
                cm=[];


                fe=obj.parentTree.filterExplorer;
                e=fe.explorer;
                cm=fe.am.createPopupMenu(e);






                deleteText='Remove';
                deleteMenu=fe.am.createAction(e,...
                'Text',deleteText,...
                'Tag','Remove',...
                'Callback',cvi.FilterExplorer.FilterTree.getCallbackString('removeFilterCallback',obj.getUUID),...
                'Icon',fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','Delete_X.png'),...
                'StatusTip','Exclude');

                cvi.FilterExplorer.FilterTree.menuNode(obj.getUUID,obj);
                cm.addMenuItem(deleteMenu);

            catch MEx
                display(MEx.stack(1));
            end
        end

    end
end


