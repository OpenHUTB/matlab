classdef SourceList<handle




    properties(Access=private)
        mSrcCmpt;
        mData;
        mSelectedSourceName;
        mSetManagerRow;
        mSelectFunc;
        mValSrcMgr;
        mDefinitionSource;
        mDefinitionSourceModel;
        UiListenerFunction;
        mSelected;
        mSourceList;
    end


    methods(Static,Access=public)
        function result=handleSelectionChange(compSrc,selection,thisObj)
        end

    end


    methods(Access=public)
        function this=SourceList(cmptSource,fcnSelect,valsrcMgr)
            this.mSrcCmpt=cmptSource;
            this.mSetManagerRow=[];
            this.mSelectFunc=fcnSelect;
            this.mValSrcMgr=valsrcMgr;
            this.mDefinitionSource=[];
            this.mDefinitionSourceModel=[];
            this.mSelected={};
            this.mSourceList={};
            this.mSelectedSourceName='';

            this.fillSourceList();
        end

        function r=onSelectionChanged(thisObj,tag,sels,dlg)
            thisObj.mSelectFunc(thisObj,sels);
        end

        function dlgStruct=getDialogSchema(thisObj,arg1)

            source.Type='combobox';
            source.Tag='sourceChoice';
            source.RowSpan=[1,1];
            source.ColSpan=[1,2];
            source.Entries=thisObj.mSourceList;
            if isempty(thisObj.mSelectedSourceName)||...
                ~ismember(thisObj.mSelectedSourceName,thisObj.mSourceList)
                if~isempty(source.Entries)
                    source.Value=source.Entries{1};
                    source.Value=0;
                else
                    source.Value='';
                    source.Value=-1;
                end
            else
                source.Value=thisObj.mSelectedSourceName;
                source.Value=(find(ismember(source.Entries,thisObj.mSelectedSourceName)))-1;
            end

            source.ObjectMethod='changeSource';
            source.MethodArgs={'%dialog','%value'};
            source.ArgDataTypes={'handle','ustring'};

            refresh.Type='pushbutton';
            refresh.FilePath=fullfile(matlabroot,'toolbox',...
            'simulink','sl_valuesrc','+sl_valuesrc','valuesrcPlugin','resources',...
            'icons','refresh_16.png');
            refresh.Tag='refresh';
            refresh.ToolTip=message('sl_valuesrc:messages:RefreshSourceList').getString;
            refresh.RowSpan=[1,1];
            refresh.ColSpan=[3,3];
            refresh.ObjectMethod='refreshSourceList';
            refresh.Source=thisObj;
            refresh.MethodArgs={'%dialog',true};
            refresh.ArgDataTypes={'handle','boolean'};

            list.Type='spreadsheet';
            list.SelectionChangedCallback=@(tag,sels,dlg)thisObj.onSelectionChanged(tag,sels,dlg);
            list.Tag='navList';
            list.Source=thisObj;
            list.RowSpan=[2,3];
            list.ColSpan=[1,3];
            list.Columns={'Name','Active'};
            list.Hierarchical=true;

            dlgStruct.LayoutGrid=[3,3];
            dlgStruct.ColStretch=[0,1,0];
            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;
            dlgStruct.Items={source,refresh,list};
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};
        end

        function modelCloseListener(thisObj,src,~)
            thisObj.fillSourceList();
            if~isempty(src)
                if isequal(thisObj.mSelectedSourceName,src.Name)
                    thisObj.setSourceObject('');
                end
                [isMbr,loc]=ismember(src.Name,thisObj.mSourceList);
                if isMbr
                    thisObj.mSourceList(loc)=[];
                end
            end
            if isvalid(thisObj.mSrcCmpt)
                dlg=thisObj.mSrcCmpt.getDialog();
                thisObj.refreshSourceList(dlg,false);
            end
            thisObj.mSelectFunc(thisObj,'');
        end

        function refreshSourceList(thisObj,dlg,bRefreshList)
            if bRefreshList
                thisObj.fillSourceList();
            end
            if~isempty(thisObj.mSelectedSourceName)&&...
                ~ismember(thisObj.mSelectedSourceName,thisObj.mSourceList)
                thisObj.setSourceObject('');
            end
            if isempty(thisObj.mSelectedSourceName)&&~isempty(thisObj.mSourceList)
                thisObj.setSourceObject(thisObj.mSourceList{1});
            end
            if~isempty(dlg)
                dlg.refresh();
            end
        end

        function tf=isHierarchical(thisObj)
            tf=true;
        end

        function tf=isHierarchicalChildren(thisObj)
            tf=true;
        end

        function children=getHierarchicalChildren(thisObj)
            children=[];
            if isempty(thisObj.mData)
                thisObj.mData=thisObj.generateChildren();
            end
            children=thisObj.mData;
        end

        function children=getChildren(thisObj)
            children=[];
            if isempty(thisObj.mData)
                thisObj.mData=thisObj.generateChildren();
            end
            children=thisObj.mData;
        end

        function changeSource(thisObj,dlg,selection)
            thisObj.setSourceObject(dlg.getComboBoxText('sourceChoice'));

            ss=dlg.getWidgetInterface('navList');
            ss.update();

            thisObj.mValSrcMgr.handleSourceChange([],[]);
        end

        function setSelected(thisObj,selection)
            thisObj.mSelected=selection;
        end

        function selection=getSelected(thisObj)
            selection=thisObj.mSelected;
        end

        function doCreate(thisObj)
            thisObj.mSetManagerRow.doCreate();
        end

        function doDelete(thisObj)
            txn=thisObj.mDefinitionSourceModel.beginTransaction;
            selected=thisObj.mSelected;
            for i=1:numel(selected)
                if any(strcmp(methods(selected{i}),'doDelete'))
                    selected{i}.doDelete();
                end
            end
            txn.commit;
        end

        function topPriority(thisObj)
            selected=thisObj.mSelected;
            if isequal(numel(selected),1)
                if any(strcmp(methods(selected{1}),'topPriority'))
                    selected{1}.topPriority();
                end
            end
        end

        function incrPriority(thisObj)
            selected=thisObj.mSelected;
            if isequal(numel(selected),1)
                if any(strcmp(methods(selected{1}),'incrPriority'))
                    selected{1}.incrPriority();
                end
            end
        end

        function decrPriority(thisObj)
            selected=thisObj.mSelected;
            if isequal(numel(selected),1)
                if any(strcmp(methods(selected{1}),'decrPriority'))
                    selected{1}.decrPriority();
                end
            end
        end

        function refreshList(thisObj)
            dlg=thisObj.mSrcCmpt.getDialog();
            ss=dlg.getWidgetInterface('navList');
            ss.update();
        end

        function selectSource(thisObj,srcName)
            thisObj.fillSourceList();
            thisObj.setSourceObject(srcName)
            dlg=thisObj.mSrcCmpt.getDialog();
            value=(find(ismember(thisObj.mSourceList,srcName)))-1;
            if~isempty(dlg)
                dlg.setWidgetValue('sourceChoice',value);
                dlg.refresh();
            end
        end

        function addSource(thisObj)
            txn=thisObj.mDefinitionSourceModel.beginTransaction;
            for i=1:numel(thisObj.mSelected)
                if any(strcmp(methods(thisObj.mSelected{i}),'addSource'))
                    thisObj.mSelected{i}.addSource();
                end
            end
            txn.commit;
        end

        function delSource(thisObj)
            txn=thisObj.mDefinitionSourceModel.beginTransaction;
            selected=thisObj.mSelected;
            for i=1:numel(selected)
                if any(strcmp(methods(selected{i}),'delSource'))
                    selected{i}.delSource();
                end
            end
            txn.commit;
        end

        function refreshSources(thisObj)
            thisObj.mDefinitionSource.refreshSources();



            dlg=thisObj.mSrcCmpt.getDialog();
            ss=dlg.getWidgetInterface('navList');
            sels=ss.getSelection();
            if~isempty(sels)
                thisObj.mSelectFunc(thisObj,sels(1));
            end

        end

        function changeListenerStatus(thisObj,enable)
            if enable
                thisObj.UiListenerFunction=@thisObj.handleListener;
                thisObj.mDefinitionSourceModel.addObservingListener(thisObj.UiListenerFunction);
            elseif~isempty(thisObj.UiListenerFunction)
                thisObj.mDefinitionSourceModel.removeListener(thisObj.UiListenerFunction);
                thisObj.UiListenerFunction=function_handle.empty();
            end
        end

        function handleListener(thisObj,changeReport)
            thisObj.changeListenerStatus(false);
            try
                [nodesToUpdate,hierarchyChange]=thisObj.mSetManagerRow.handleListener(changeReport);
            catch E
            end
            thisObj.changeListenerStatus(true);

            if isvalid(thisObj.mSrcCmpt)
                dlg=thisObj.mSrcCmpt.getDialog();
                ss=dlg.getWidgetInterface('navList');
                if hierarchyChange
                    ss.update();
                    sels=ss.getSelection();
                    thisObj.mSelectFunc(thisObj,sels);
                else
                    sels=ss.getSelection();
                    for i=1:numel(nodesToUpdate)
                        ss.update(nodesToUpdate{i});
                        for j=1:numel(sels)
                            if isequal(sels{j},nodesToUpdate{i})
                                thisObj.mSelectFunc(thisObj,sels(j));
                            end
                        end
                    end
                end
                nodeToSelect=thisObj.mSetManagerRow.getPendingSelection();
                if~isempty(nodeToSelect)
                    ss.select(nodeToSelect);
                end
            end
        end

        function updateDefinitions(thisObj,eventData,sourceName,op)
            if~isequal(sourceName,thisObj.mSelectedSourceName)

                return;
            end

            for i=1:numel(thisObj.mSelected)
                if any(strcmp(methods(thisObj.mSelected{i}),'updateDefinitions'))
                    thisObj.mSelected{i}.updateDefinitions(eventData,op);
                end
            end
        end

        function cacheUpdateEvent(thisObj,eventData,sourceName)
            if~isequal(sourceName,thisObj.mSelectedSourceName)

                return;
            end

            for i=1:numel(thisObj.mSelected)
                if any(strcmp(methods(thisObj.mSelected{i}),'cacheUpdateEvent'))
                    if thisObj.mSelected{i}.cacheUpdateEvent(eventData)
                        thisObj.mValSrcMgr.updateListRow([]);
                        break;
                    end
                end
            end
        end
    end


    methods(Access=private)
        function children=generateChildren(thisObj)
            children{1}=sl_valuesrc.internal.DefinitionsSrcRow('sl_valuesrc:messages:ParameterDefinitions',thisObj.mDefinitionSource,thisObj.mValSrcMgr);
            children{2}=sl_valuesrc.internal.GroupsSrcRow('sl_valuesrc:messages:ParameterGroups',thisObj.mDefinitionSource,thisObj.mValSrcMgr);
            thisObj.mSetManagerRow=children{2};
        end

        function fillSourceList(thisObj)

            names=find_system('Type','block_diagram');
            selectFcn=@(name,type)isequal(type,get_param(name,'BlockDiagramType'));
            thisObj.mSourceList=names(cellfun(@(name)selectFcn(name,'model'),names));

            sourceNameList={};
            sourceObjList={};
            for i=1:numel(thisObj.mSourceList)
                sourceNameList{end+1}=thisObj.mSourceList{i};
                sourceObjList{end+1}=get_param(thisObj.mSourceList{i},'Object');
            end

            thisObj.mValSrcMgr.syncEventListeners(sourceNameList,sourceObjList);
        end

        function setSourceObject(thisObj,sourceName)
            if isequal(sourceName,thisObj.mSelectedSourceName)
                return;
            end

            thisObj.mData=[];
            thisObj.mSelectedSourceName=sourceName;
            if~isempty(thisObj.mDefinitionSourceModel)
                thisObj.changeListenerStatus(false);
            end

            if isempty(thisObj.mSelectedSourceName)
                thisObj.mDefinitionSource=[];
                thisObj.mDefinitionSourceModel=[];
                return;
            end


            if exist(thisObj.mSelectedSourceName,'file')==4

                thisObj.mDefinitionSource=sl_valuesrc.internal.ModelWorkspace(thisObj.mSelectedSourceName,thisObj.mValSrcMgr);
            else
                thisObj.mDefinitionSource=[];
            end
            if~isempty(thisObj.mDefinitionSource)
                thisObj.mDefinitionSourceModel=thisObj.mDefinitionSource.getSourceModel();

                thisObj.changeListenerStatus(true);
            end
        end

    end
end
