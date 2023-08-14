classdef DDSList<handle




    properties(Access=private)
        mDDFilepath;
        mDDSMdl;
        mDDSMdlTree;
        mListSS;
        mTabs;
        mCurrentTab;
        mData;
        mColumns;
        mRefreshChildren;
        mObjSelected;
        mReparseNeeded;
    end

    properties(Constant)
        TYPES_TABID=message('dds:ui:TypesTabID').getString;
        DOMAINS_TABID=message('dds:ui:DomainsTabID').getString;
        QOS_TABID=message('dds:ui:QoSTabID').getString;
    end


    methods(Static,Access=public)
        function handleTabChanged(ssComponent,tabName,thisObj)
            if~isequal(tabName,thisObj.mCurrentTab)
                thisObj.setSelected([]);
                thisObj.changeTab(tabName);
            end
        end

        function result=handleSelectionChange(compSrc,selection,thisObj)
            thisObj.setSelected(selection);
        end
    end


    methods(Access=public)
        function this=DDSList(listSS,ddFilepath,ddsMdl)
            this.mObjSelected=[];
            this.mData=containers.Map;
            this.mRefreshChildren=true;
            this.mDDFilepath=ddFilepath;

            this.mDDSMdl=ddsMdl;
            this.mReparseNeeded=false;
            this.parseSystem();

            this.mListSS=listSS;
            this.fillTabs();

            for i=1:length(this.mTabs)
                tabData=this.mTabs{i};
                this.mListSS.addTab(tabData{1},tabData{2},tabData{3});
            end
            this.mListSS.setTitle(message('dds:ui:DDSUINodeName').getString);

            columns=this.getColumns(this.getTab());
            this.mListSS.setColumns(columns,columns{1},'',true);
            this.mListSS.enableHierarchicalView(true);

        end

        function tabChanged(thisObj,tabName)
            if~isequal(tabName,thisObj.mCurrentTab)
                thisObj.setSelected([]);
                thisObj.changeTab(tabName);
            end
        end

        function setSelected(thisObj,selection)
            thisObj.mObjSelected=selection;
        end

        function parseSystem(thisObj)




            sys=dds.internal.getSystemInModel(thisObj.mDDSMdl);
            if~isempty(sys(1).Listener)
                pauseObj=sys(1).Listener.PauseListener();%#ok<NASGU>
            end
            txn=thisObj.mDDSMdl.beginTransaction;
            if isempty(thisObj.mDDSMdlTree)
                thisObj.mDDSMdlTree=dds.internal.simulink.Util.replaceOrCreateModelTree(thisObj.mDDSMdl);
            end
            thisObj.mDDSMdlTree.parseSystem(sys(1));
            txn.commit;
            pauseObj=[];%#ok<NASGU> Cause a sync 
        end

        function refresh(thisObj,changeReport)
            handled=false;
            if~isempty(changeReport.Modified)||...
                ~isempty(changeReport.Created)||...
                ~isempty(changeReport.Destroyed)
                children=thisObj.mData.values;
                for i=1:numel(children)
                    row=children{i};
                    if row.refresh(changeReport)
                        handled=true;
                    end
                end
            end
            if~isempty(changeReport.Created)
                thisObj.mRefreshChildren=true;
                sys=dds.internal.getSystemInModel(thisObj.mDDSMdl);
                for i=1:numel(changeReport.Created)
                    if isequal(sys,changeReport.Created(i).Container)
                        thisObj.mReparseNeeded=true;
                        handled=1;
                        break;
                    end
                end
            elseif~isempty(changeReport.Destroyed)
                thisObj.mRefreshChildren=true;
                sys=dds.internal.getSystemInModel(thisObj.mDDSMdl);
                for i=1:numel(changeReport.Modified)
                    if isequal(sys,changeReport.Modified(i).Element)
                        thisObj.mReparseNeeded=true;
                        handled=1;
                        break;
                    end
                end
            elseif~isempty(changeReport.Modified)
                sys=dds.internal.getSystemInModel(thisObj.mDDSMdl);
                for i=1:numel(changeReport.Modified)
                    if isequal(sys,changeReport.Modified(i).Element)
                        thisObj.mReparseNeeded=true;
                        handled=1;
                        break;
                    end
                end
            end
            if handled&&thisObj.mRefreshChildren
                thisObj.mListSS.update(true);
            end
        end

        function updateRow(thisObj,row)
            thisObj.mListSS.update(row);
        end

        function bUse=useDetailActions(thisObj)
            bUse=false;
        end

        function dlgStruct=getDialogSchema(thisObj,~)
            filterWidget.Type='spreadsheetfilter';
            filterWidget.Tag='spreadsheetfilter';
            filterWidget.PlaceholderText=DAStudio.message('Simulink:studio:DataView_default_filter');
            filterWidget.Clearable=true;
            filterWidget.RowSpan=[1,1];
            filterWidget.ColSpan=[3,3];

            dlgStruct.LayoutGrid=[1,3];
            dlgStruct.ColStretch=[0,1,0];
            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;
            dlgStruct.Items={filterWidget};
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};
        end

        function children=getChildren(thisObj,component,tab,userData)
            if nargin<3
                tab=thisObj.mCurrentTab;
            end
            if isempty(thisObj.mData)||~isequal(tab,thisObj.mCurrentTab)||thisObj.mRefreshChildren
                thisObj.mRefreshChildren=false;
                if thisObj.mReparseNeeded
                    thisObj.mReparseNeeded=false;
                    thisObj.parseSystem();
                end

                thisObj.mData=thisObj.generateChildren(tab);
                thisObj.mCurrentTab=tab;
            end

            children=[];
            values=thisObj.mData.values;
            if~isempty(values)
                children=values{1};
                for i=2:numel(values)
                    children(i)=values{i};
                end
            end
        end

        function setCurrentTabByName(thisObj,tabName)
            for tabIdx=1:numel(thisObj.mTabs)
                tabInfo=thisObj.mTabs{tabIdx};
                if isequal(tabInfo{1},tabName)
                    if~isequal((tabIdx-1),thisObj.mListSS.getCurrentTab())
                        thisObj.mListSS.setCurrentTab(tabIdx-1);
                        break;
                    end
                end
            end
        end

        function createLibrary(thisObj)
            tabName=thisObj.getTabName();
            if isequal(tabName,'Types')
                thisObj.mRefreshChildren=true;
                libObj=dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.create(thisObj.mDDSMdl,thisObj.mDDSMdlTree,[],'');
            elseif isequal(tabName,'Domains')
                thisObj.mRefreshChildren=true;
                libObj=dds.internal.simulink.ui.internal.dds.datamodel.domain.DomainLibrary.create(thisObj.mDDSMdl,thisObj.mDDSMdlTree,[],'');
            end
        end

        function addSection(thisObj)
            for i=1:numel(thisObj.mObjSelected)
                thisObj.mObjSelected{i}.addSection();
            end
        end

        function addObject(thisObj,type)
            for i=1:numel(thisObj.mObjSelected)
                thisObj.mObjSelected{i}.addObject(type);
            end
        end

        function duplicateSelection(thisObj)
            for i=1:numel(thisObj.mObjSelected)
                thisObj.mObjSelected{i}.duplicate();
            end
        end

        function deleteSelection(thisObj)
            selection={};
            for i=1:numel(thisObj.mObjSelected)
                obj=thisObj.mObjSelected{i};
                selection{end+1}=obj.getForwardedObject();
            end
            dds.internal.simulink.ui.internal.DDSLibraryUI.deleteSelection(thisObj.mDDSMdl,selection);
        end

        function showHelp(thisObj)


            helpview(fullfile(docroot,'dds','helptargets.map'),'DDS_Dictionary');
        end

        function tabTypeChain=getTabTypeChain(thisObj)
            idx=thisObj.getTabIdx;
            tabTypeChain={['Tab_',num2str(idx)]};
        end

        function tabIdx=getTabIdx(thisObj)
            tabIdx=0;
            for tabIdx=1:numel(thisObj.mTabs)
                tabInfo=thisObj.mTabs{tabIdx};
                if isequal(tabInfo{2},thisObj.mCurrentTab)
                    return;
                end
            end
            tabIdx=0;
        end
    end

    methods(Access=private)
        function fillTabs(thisObj)

            numSections=thisObj.mDDSMdlTree.Children.Size();
            if numSections>3&&slfeature('DDSUI')<2
                numSections=3;
            end
            tabIdx=1;
            for idx=1:numSections
                if~isempty(thisObj.mDDSMdlTree.Children(idx).TabName)
                    tabName=thisObj.mDDSMdlTree.Children(idx).TabName;
                    tabTooltip=thisObj.mDDSMdlTree.Children(idx).TabName;

                    tabID=thisObj.mDDSMdlTree.Children(idx).UUID;

                    thisObj.mTabs{tabIdx}={tabName,...
                    tabID,...
                    tabTooltip};
                    thisObj.mColumns{tabIdx}=thisObj.mDDSMdlTree.Children(idx).ColumnNames.toArray;
                    tabIdx=tabIdx+1;
                end
            end

            thisObj.mCurrentTab=thisObj.mTabs{1}{2};
        end

        function tabName=getTab(thisObj)
            tabName=thisObj.mCurrentTab;
        end

        function tabName=getTabName(thisObj)
            for tabIdx=1:numel(thisObj.mTabs)
                tabInfo=thisObj.mTabs{tabIdx};
                if isequal(tabInfo{2},thisObj.mCurrentTab)
                    tabName=tabInfo{1};
                    return;
                end
            end
            tabName='';
        end

        function columns=getColumns(thisObj,tabName)
            columns={'Name'};
            for tabIdx=1:numel(thisObj.mTabs)
                tabInfo=thisObj.mTabs{tabIdx};
                if isequal(tabInfo{2},tabName)
                    columns=thisObj.mColumns{tabIdx};
                    break;
                end
            end
        end

        function children=generateChildren(thisObj,tabName)
            children=containers.Map;
            numSections=thisObj.mDDSMdlTree.Children.Size();
            for idx=1:numSections
                element=thisObj.mDDSMdlTree.Children(idx).UUID;
                if isequal(element,tabName)
                    topChildren=thisObj.mDDSMdlTree.Children(idx).Children;
                    for idxChild=1:topChildren.Size()
                        if~isempty(topChildren(idxChild).Element)&&~isempty(topChildren(idxChild).Element.Container)
                            if thisObj.mData.isKey(topChildren(idxChild).UUID)
                                children(topChildren(idxChild).UUID)=thisObj.mData(topChildren(idxChild).UUID);
                            else
                                child=dds.internal.simulink.ui.internal.DDSLibraryRow(thisObj,...
                                thisObj.mDDSMdl,...
                                thisObj.mDDSMdlTree,...
                                topChildren(idxChild),...
                                thisObj.getColumns(tabName));
                                children(topChildren(idxChild).UUID)=child;
                            end
                        end
                    end
                    break;
                end
            end
        end

        function changeTab(thisObj,tabName)
            cols=thisObj.getColumns(tabName);
            thisObj.mListSS.setColumns(cols,cols{1},'',true);
            thisObj.mListSS.update(false);
        end

    end
end
