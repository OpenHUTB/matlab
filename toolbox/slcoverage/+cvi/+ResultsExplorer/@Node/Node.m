classdef Node<handle




    properties(SetObservable=true)
        interface=[]
        parentTree=[]
        parent=[]
        children=[]
        data=[]
        srcNode=[]
        saveId=0
        needsApply=false
        uuid=[]
        appliedFilterIds={}
        rememberToExcludeVariant=false
        rememberToExcludeVariantValue=false
    end
    methods(Static=true)

        function node=create(data,parentTree)
            node=cvi.ResultsExplorer.Node(parentTree,data);
            node.interface=SlCovResultsExplorer.Data(parentTree.resultsExplorer,node);
        end

        function newNode=createRef(node,parentTree)
            newNode=cvi.ResultsExplorer.Node(parentTree,node.data);
            newNode.srcNode=node;
            node.data.dstNode=newNode;
            newNode.interface=SlCovResultsExplorer.Data(parentTree.resultsExplorer,newNode);
        end

    end
    methods

        function node=Node(parentTree,data)
            node.parentTree=parentTree;
            node.data=data;
            guidStr=char(matlab.lang.internal.uuid);
            node.uuid=guidStr;
        end

        function uuid=getUUID(node)
            uuid=node.uuid;
        end

        function str=isCum(node)
            str=numel(node.children)>1;
        end
        function res=isActiveRoot(node)
            res=node.parentTree.isActive&&(node.parentTree.root==node);
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
            if~isempty(childNode.srcNode)
                childNode.srcNode.data.dstNode=[];
            end
            if~isempty(childNode.data)
                childNode.data.unMark;
            end
        end

        function res=allChildrenMarked(node)
            res=false;
            if isempty(node.children)
                return;
            end
            res=true;
            for idx=1:numel(node.children)
                if~node.children{idx}.data.marked
                    res=false;
                    return;
                end
            end
        end

        function resetFilter(node)
            node.data.applyFilterOnCvData('');
        end

        function str=getSummary(node)
            str='';
            if~isempty(node.data)
                if node.isActiveRoot()
                    node.applyFilter;
                end
                str=node.data.getSummary();
            end
        end

        function label=getLabel(node)
            label='';
            if isempty(node.data)
                return;
            end
            label=node.data.getTag;
            if isempty(label)
                label=node.data.filename;
            end
        end

        function res=isHighlighted(node)
            res=node.parentTree.resultsExplorer.highlightedNode==node;
        end

        function label=getDisplayLabel(node)
            label='';
            if isempty(node.data)
                return;
            end
            label=getLabel(node);
            if node.data.needSave
                label=[label,'*'];
            end

            if node.isHighlighted()
                label=[label,' (H)'];
            end




        end

        function res=hasChildren(node)
            res=~isempty(node.children);
        end

        function chld=getHierarchicalChildren(node)
            chld=node.children;
        end


        function icon=getDisplayIcon(node)
            if node.data.marked&&~node.parentTree.isActive
                icon=fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','SingleDataAdded.png');
            elseif isCum(node)
                if node.allChildrenMarked
                    icon=fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','CumDataAdded.png');
                else
                    icon=fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','CumData.png');
                end
            else
                icon=fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','SingleData.png');
            end
        end



        function s=saveNode(node)
            s=[];

            s.parent=[];
            if~isempty(node.parent)
                s.parent=node.parent.saveId;
            end
            s.children={};
            for idx=1:numel(node.children)
                s.children=[s.children,{node.children{idx}.saveId}];
            end

        end



        function obj=getExplorer(node)
            obj=node.parentTree.resultsExplorer;
        end

        function retVal=getPropertyStyle(this,~)

            retVal=DAStudio.PropertyStyle;
            if this.data.isCvdatagroup
                retVal.Tooltip='cv.cvdatagroup';
            elseif~isempty(this.srcNode)
                retVal.Tooltip=getString(message('Slvnv:simcoverage:cvresultsexplorer:DataFrom',this.data.filename));
            else
                retVal.Tooltip=['"',this.data.filename,'" - ',this.data.date];
            end

        end


        function[status,id]=postApplyCallback(obj,dlg,descriptionTag,tagTag,excludeInactiveVariantsTag)
            try
                status=true;
                id='';
                changeTag=false;
                if~isempty(tagTag)
                    tag=dlg.getWidgetValue(tagTag);
                    changeTag=obj.data.setTag(tag);
                    if changeTag
                        obj.data.userEditedTag=true;
                    end
                end
                changeDescr=false;
                if~isempty(descriptionTag)
                    descr=dlg.getWidgetValue(descriptionTag);
                    changeDescr=obj.data.setDescription(descr);
                    if changeDescr
                        obj.data.userEditedDescr=true;
                    end
                end

                explrObj=obj.parentTree.resultsExplorer;

                changeExcludeInactiveVariantsCheckbox=false;
                if~isempty(excludeInactiveVariantsTag)
                    checkboxValue=dlg.getWidgetValue(excludeInactiveVariantsTag);
                    changeExcludeInactiveVariantsCheckbox=obj.excludeInactiveVariant(explrObj,checkboxValue);
                end

                changeFilter=postApplyFilter(obj.parentTree.resultsExplorer);
                obj.needsApply=false;

                if changeTag||changeDescr||changeFilter||changeExcludeInactiveVariantsCheckbox

                    explrObj.root.activeTree.needAggregate=true;

                    if~isempty(obj.data)
                        obj.data.resetLastReport;
                        obj.applyFilter;

                        if(~obj.isActiveRoot)
                            cvsave(obj.data.fullFileName,obj.data.cvd);

                            if changeExcludeInactiveVariantsCheckbox&&~isempty(obj.parent.isHighlighted)
                                if~obj.parent.rememberToExcludeVariant||(numel(obj.parent.children)==1)
                                    obj.parent.aggregate();
                                end
                                if obj.parent.isHighlighted
                                    obj.parent.modelview;
                                end
                            end
                        else


                            if(obj.rememberToExcludeVariant)
                                if(isa(obj.data.cvd,'cvdata'))
                                    allCvd={obj.data.cvd};
                                else
                                    allCvd=obj.data.cvd.getAll;
                                end
                                if(numel(obj.children)==1)
                                    obj.children{1}.data.resetSummary;
                                else
                                    for i=1:length(allCvd)
                                        [allCvd{i}.excludeInactiveVariants]=deal(obj.rememberToExcludeVariantValue);
                                    end
                                end
                            end
                            if changeExcludeInactiveVariantsCheckbox&&~isempty(obj.isHighlighted)
                                if obj.isHighlighted
                                    obj.modelview;
                                end
                            end
                        end
                        obj.data.resetSummary;
                        explrObj.dataChange(obj);
                    end

                end
                dlg.refresh();
            catch MEx
                display(MEx.stack(1));
            end
        end

        function[status,id]=closeCallback(obj,dlg,descriptionTag,tagTag,excludeInactiveVariantsTag)
            status=true;
            id='';
            if isvalid(obj.parentTree.resultsExplorer)&&dlg.hasUnappliedChanges
                applyStr=getString(message('Slvnv:simcoverage:cvresultsexplorer:UnappliedChangesApply'));
                ignoreStr=DAStudio.message('Slvnv:simcoverage:cvresultsexplorer:UnappliedChangesIgnore');
                buttonRes=questdlg(DAStudio.message('Slvnv:simcoverage:cvresultsexplorer:UnappliedChangesMsg'),...
                [DAStudio.message('Slvnv:simcoverage:cvresultsexplorer:Root'),' - ',DAStudio.message('Slvnv:simcoverage:cvresultsexplorer:UnappliedChangesAplpyChanges')],...
                applyStr,...
                ignoreStr,...
                ignoreStr);
                if strcmpi(buttonRes,applyStr)
                    [status,id]=obj.postApplyCallback(dlg,descriptionTag,tagTag,excludeInactiveVariantsTag);
                else
                    [status,id]=obj.postRevertCallback(dlg);
                end
            end

        end

        function[status,id]=postRevertCallback(obj,dlg)
            try
                status=true;
                explorer=obj.parentTree.resultsExplorer;
                explorer.filterEditor.revert(dlg);
                obj.needsApply=false;
                id='';

            catch MEx
                display(MEx.stack(1));
            end
        end

        function actionCallback(obj,action)
            try
                explorer=obj.parentTree.resultsExplorer;
                switch action
                case{'genReport','openReport'}
                    obj.createReport;
                case{'modelview'}
                    obj.modelview;
                case{'removeHighlight'}
                    if explorer.highlightedNode==obj
                        modelcovId=get_param(explorer.topModelName,'CoverageId');
                        if modelcovId~=0
                            cvi.Informer.close(modelcovId);
                        end
                        explorer.highlightChange(obj,false);
                    end
                case{'saveCovData'}
                    cvi.ResultsExplorer.ResultsExplorer.activeNode(obj,explorer.topModelName);
                    cvi.ResultsExplorer.ResultsExplorer.saveCumDataCallback(explorer.topModelName);
                case{'saveFilter'}
                    explorer.saveFilterCallback;
                case{'loadFilter'}
                    explorer.loadFilterCallback;
                case{'makeFilter'}
                    cvi.ResultsExplorer.ResultsExplorer.makeFilterCallback(explorer.filterEditor,explorer.topModelName);
                case{'makeCPFilter'}
                    explorer.makeCodeProverFilterCallback(explorer.filterEditor);
                case{'openSDI'}
                    openSDI(obj);
                end

            catch MEx
                display(MEx.stack(1));
            end
        end

        function res=getAppliedFilterIds(obj)
            res=obj.appliedFilterIds;
        end

        function setAppliedFilterIds(obj,appliedFilterIds)
            obj.appliedFilterIds=appliedFilterIds;
        end



        function openSDI(~)
            Simulink.sdi.view;
        end

        function cm=getContextMenu(obj)
            try
                cm=[];


                re=obj.parentTree.resultsExplorer;

                e=re.explorer;
                cm=re.am.createPopupMenu(e);

                excludeText=getString(message('Slvnv:simcoverage:cvresultsexplorer:Exclude'));
                excludeMenu=re.am.createAction(e,...
                'Text',excludeText,...
                'Tag','Exclude',...
                'Callback',re.getCallbackString('deleteCallback','false'),...
                'Icon',fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','Delete_X.png'),...
                'StatusTip','Exclude');

                cvi.ResultsExplorer.ResultsExplorer.activeNode(obj,re.topModelName);
                if obj.parentTree.isActive

                    cm.addMenuItem(excludeMenu);
                else
                    cvi.ResultsExplorer.ResultsExplorer.activeNode(obj,re.topModelName);
                    if isempty(obj.children)
                        if~obj.data.marked
                            includeText=getString(message('Slvnv:simcoverage:cvresultsexplorer:Include'));
                            eMenu=re.am.createAction(e,...
                            'Text',includeText,...
                            'Tag','Include',...
                            'Callback',re.getCallbackString('addCallback'),...
                            'Icon',fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','AddData.png'),...
                            'StatusTip','Include');
                            cm.addMenuItem(eMenu);
                        else
                            cm.addMenuItem(excludeMenu);
                        end
                    else
                        if obj.allChildrenMarked
                            excludeAllText=getString(message('Slvnv:simcoverage:cvresultsexplorer:ExcludeAll'));
                            eMenu=re.am.createAction(e,...
                            'Text',excludeAllText,...
                            'Tag','ExcludeAll',...
                            'Callback',re.getCallbackString('deleteCallback','false'),...
                            'Icon',fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','Delete_X.png'),...
                            'StatusTip','Exclude All');
                            cm.addMenuItem(eMenu);
                        else
                            includeAllText=getString(message('Slvnv:simcoverage:cvresultsexplorer:IncludeAll'));
                            eMenu=re.am.createAction(e,...
                            'Text',includeAllText,...
                            'Tag','IncludeAll',...
                            'Callback',re.getCallbackString('addCallback'),...
                            'Icon',fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','AddData.png'),...
                            'StatusTip','Include All');
                            cm.addMenuItem(eMenu);
                        end
                    end

                end
                if obj.data.needSave()
                    cvi.ResultsExplorer.ResultsExplorer.activeNode(obj,re.topModelName);
                    saveText=getString(message('Slvnv:simcoverage:cvresultsexplorer:SaveData'));

                    eMenu=re.am.createAction(e,...
                    'Text',saveText,...
                    'Tag','SaveData',...
                    'Callback',re.getCallbackString('saveDataCallback'),...
                    'Icon',fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','Save.png'),...
                    'StatusTip',getString(message('Slvnv:simcoverage:cvresultsexplorer:SaveToolTip')));
                    cm.addMenuItem(eMenu);
                end
                if~isempty(obj.srcNode)||~isempty(obj.data.dstNode)
                    if~isempty(obj.srcNode)
                        gotoText=getString(message('Slvnv:simcoverage:cvresultsexplorer:GotoSrc'));
                        gotoCmd=re.getCallbackString('gotoCallback','0');
                    else
                        gotoText=getString(message('Slvnv:simcoverage:cvresultsexplorer:GotoDst'));
                        gotoCmd=re.getCallbackString('gotoCallback','1');
                    end
                    eMenu=re.am.createAction(e,...
                    'Text',gotoText,...
                    'Tag','Goto',...
                    'Callback',gotoCmd,...
                    'Icon',fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','LinkedIcon.png'),...
                    'StatusTip','Goto');
                    cm.addMenuItem(eMenu);
                end
            catch MEx
                display(MEx.stack(1));
            end
        end

    end
end


