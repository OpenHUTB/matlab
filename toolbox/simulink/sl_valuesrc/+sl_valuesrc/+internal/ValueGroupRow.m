classdef ValueGroupRow<handle






    properties(Access=private)
        mSrcObj;
        mData;
        mRefreshChildren;
        mListSrc;
        mParamSrc;
        mListObj;
        mValSrcMgr;
        mChildList;
    end


    methods(Static,Access=public)

    end


    methods
        function addToGroup(thisObj,dlg)
            ss=dlg.getWidgetInterface('paramList');
            selection=ss.getSelection();
            srcMdl=thisObj.mParamSrc.getSourceModel();
            txn=srcMdl.beginTransaction();
            for i=1:numel(selection)
                thisObj.mSrcObj.addEntry(selection{i}.getUUID());
            end
            txn.commit();
            if~isempty(thisObj.mListObj)
                thisObj.mListObj.refresh();
                dlg.refresh();
            end
        end
    end
    methods(Access=public)
        function thisObj=ValueGroupRow(srcObj,valsrcMgr,defSrc)
            thisObj.mSrcObj=srcObj;
            thisObj.mValSrcMgr=valsrcMgr;
            thisObj.mParamSrc=defSrc;
            thisObj.mListSrc=sl_valuesrc.internal.ValueGroup(thisObj.mSrcObj,thisObj.mParamSrc);
            thisObj.mData=containers.Map;
            thisObj.mChildList={};
        end

        function tf=isHierarchical(thisObj)
            tf=true;
        end

        function tf=isHierarchicalChildren(thisObj)
            tf=true;
        end

        function children=getHierarchicalChildren(thisObj)
            children=[];
            if isempty(thisObj.mData)||thisObj.mRefreshChildren
                thisObj.mRefreshChildren=false;
                [thisObj.mData,thisObj.mChildList]=thisObj.generateChildren();
            end
            children=[];
            values=thisObj.mChildList;
            if~isempty(values)
                children=thisObj.mData(values{1});
                for i=2:numel(values)
                    children(i)=thisObj.mData(values{i});
                end
            end
        end

        function children=getChildren(thisObj)
            children=[];
            if isempty(thisObj.mData)

            end
            children=thisObj.mData;
        end

        function label=getDisplayLabel(thisObj)
            try
                label=thisObj.mSrcObj.getName();
            catch
                label='<groupname>';
            end
        end

        function icon=getDisplayIcon(thisObj)
            icon='toolbox/simulink/sl_valuesrc/+sl_valuesrc/valuesrcPlugin/resources/icons/ParamFolder_16.png';
        end

        function valid=isValidProperty(thisObj,propName)
            valid=false;
            if isempty(propName)||isequal(propName,'Name')||isequal(propName,'Active')
                valid=true;
            end
        end

        function readonly=isReadonlyProperty(thisObj,propName)
            readonly=false;
        end

        function datatype=getPropDataType(thisObj,propName)
            if isempty(propName)||isequal(propName,'Name')
                datatype='string';
            elseif isequal(propName,'Active')
                datatype='bool';
            end
        end

        function prop=getPropValue(thisObj,propName)
            if isempty(propName)||isequal(propName,'Name')
                prop=getDisplayLabel(thisObj);
            elseif isequal(propName,'Active')
                if thisObj.mSrcObj.getActive()
                    prop='on';
                else
                    prop='off';
                end
            end
        end

        function setPropValue(thisObj,propName,value)
            if isempty(propName)||isequal(propName,'Name')
                thisObj.mSrcObj.setName(value);
            elseif isequal(propName,'Active')
                if isequal(value,'1')
                    thisObj.mSrcObj.setActive(true);
                else
                    thisObj.mSrcObj.setActive(false);
                end
            end
        end

        function src=getListSource(thisObj)
            src=thisObj.mListSrc;
        end

        function dlgStruct=getDialogSchema(thisObj,arg1)
            tabcontainer.Type='tab';

            propsTab=thisObj.buildPropsTab();
            paramsTab=thisObj.buildParamsTab();

            tabcontainer.Tabs={paramsTab,propsTab};
            dlgStruct.Items={tabcontainer};
        end

        function r=onValSrcSelectionChanged(thisObj,dlg,tag)
            r='';
            if isequal(tag,'ValueSrc')
                sels=dlg.getWidgetValue(tag);
                if isempty(sels)
                    delEnabled=false;
                    moveUpEnabled=false;
                    moveDownEnabled=false;
                else
                    delEnabled=true;
                    if sels(1)>0
                        moveUpEnabled=true;
                    else
                        moveUpEnabled=false;
                    end
                    overlays=thisObj.mSrcObj.getOverlayList();
                    if(sels(numel(sels))+1)<numel(overlays)
                        moveDownEnabled=true;
                    else
                        moveDownEnabled=false;
                    end
                end
                dlg.setEnabled('ValueSrcRemove',delEnabled);
                dlg.setEnabled('ValueSrcMoveUp',moveUpEnabled);
                dlg.setEnabled('ValueSrcMoveDown',moveDownEnabled);
            end
        end

        function r=onSelectionChanged(thisObj,tag,sels,dlg)
            r=[];
            if isequal(tag,'paramList')
                if isempty(sels)
                    enabled=false;
                else
                    enabled=true;
                    for i=1:numel(sels)
                        if thisObj.mSrcObj.isParameterInGroup(sels{i}.getUUID)
                            enabled=false;
                            break;
                        end
                    end
                end
                dlg.setEnabled('addBtn',enabled);
            end
        end

        function onDoubleClicked(thisObj,tag,sels,~,dlg)
            if isequal(tag,'paramList')&&~isempty(sels)
                thisObj.addToGroup(dlg);
            end
        end

        function setListObj(thisObj,listObj)
            thisObj.mListObj=listObj;
        end

        function doRemoveEntry(thisObj,selection)
            srcMdl=thisObj.mParamSrc.getSourceModel();
            txn=srcMdl.beginTransaction();
            for i=1:numel(selection)
                selection{i}.remove();
            end
            txn.commit();
        end

        function doDelete(thisObj)
            valueSrcManager=thisObj.mParamSrc.getValueSrcManager();
            valueSrcManager.deleteValueOverrideGroup(thisObj.mSrcObj);
        end

        function addSource(thisObj)
            [filenames,pathname]=uigetfile(...
            thisObj.mParamSrc.getValueSrcManager.getAllowedOverlayFileExtensions,...
            message('sl_valuesrc:messages:AddExternalSource').getString,...
            'MultiSelect','on');
            if~isequal(filenames,0)&&~isequal(pathname,0)

                if~iscell(filenames)
                    filenames={fullfile(pathname,filenames)};
                else
                    for i=1:numel(filenames)
                        filenames{i}=fullfile(pathname,filenames{i});
                    end
                end
            else
                filenames={};
            end
            for j=1:numel(filenames)
                [~,overlayName,~]=fileparts(filenames{j});
                try
                    buildDir=thisObj.mParamSrc.getBuildDir(filenames{j});
                    overlayName=thisObj.getUniqueOverlayName(overlayName);
                    overlay=thisObj.mSrcObj.addOverlay(overlayName,filenames{j});
                    if~isempty(buildDir)
                        overlay.setBuildDirectory(buildDir);
                    end
                catch ME
                    errordlg(ME.message,DAStudio.message('sl_valuesrc:messages:ValueSetMgrTitle'));
                end
            end
        end

        function removeOverlay(thisObj,dlg)
            sels=dlg.getWidgetValue('ValueSrc');
            if~isempty(sels)
                overlays=thisObj.getOverlayList();
                for idx=1:numel(sels)
                    thisObj.deleteOverlay(overlays(sels(idx)+1));
                end
            end
        end

        function deleteOverlay(thisObj,overlay)
            thisObj.mSrcObj.deleteOverlay(overlay);
        end

        function moveSourceUp(thisObj,dlg)
            sels=dlg.getWidgetValue('ValueSrc');
            if~isempty(sels)
                srcMdl=thisObj.mParamSrc.getSourceModel();
                txn=srcMdl.beginTransaction();
                overlays=thisObj.getOverlayList();
                for idx=1:numel(sels)
                    thisObj.incrPriority(overlays(sels(idx)+1));
                end
                txn.commit();
            end
        end

        function moveSourceDown(thisObj,dlg)
            sels=dlg.getWidgetValue('ValueSrc');
            if~isempty(sels)
                srcMdl=thisObj.mParamSrc.getSourceModel();
                txn=srcMdl.beginTransaction();
                overlays=thisObj.getOverlayList();
                for idx=1:numel(sels)
                    thisObj.decrPriority(overlays(sels(idx)+1));
                end
                txn.commit();
            end
        end

        function topPriority(thisObj,overlay)
            overlays=thisObj.getOverlayList();
            position=find(ismember(overlays,overlay));
            srcMdl=thisObj.mParamSrc.getSourceModel();
            txn=srcMdl.beginTransaction();
            while position>1
                thisObj.incrPriority(overlay);
                position=position-1;
            end
            txn.commit();
        end

        function incrPriority(thisObj,overlay)
            thisObj.mSrcObj.overlayMoveUp(overlay);
        end

        function decrPriority(thisObj,overlay)
            thisObj.mSrcObj.overlayMoveDown(overlay);
        end

        function[rowsToUpdate,hierarchyChange]=refresh(thisObj,modChangeReport,rowsToUpdate)
            hierarchyChange=false;
            if~isempty(thisObj.mListObj)
                thisObj.mListObj.refresh(true);
            end
            rowsToUpdate{end+1}=thisObj;

            modifiedProps=modChangeReport.ModifiedProperties;
            for i=1:numel(modifiedProps)
                if isequal(modifiedProps(i).name,'isActive')
                    keys=thisObj.mData.keys;
                    for j=1:numel(keys)
                        rowsToUpdate{end+1}=thisObj.mData(keys{j});
                    end
                elseif isequal(modifiedProps(i).name,'valueOverlayList')
                    thisObj.mRefreshChildren=true;
                    hierarchyChange=true;
                elseif isequal(modifiedProps(i).name,'valueEntryMap')
                end
            end
        end

        function[rowsToUpdate,hierarchyChange]=handleListener(thisObj,changeReport)
            rowsToUpdate={};
            hierarchyChange=false;
            if~isempty(changeReport.Modified)
                modified=changeReport.Modified;
                for i=1:numel(modified)
                    if modified(i).Element==thisObj.mSrcObj
                        [rowsToUpdate,hierarchyChange]=thisObj.refresh(modified(i),rowsToUpdate);
                        break;
                    elseif~isempty(thisObj.mData)&&thisObj.mData.isKey(modified(i).Element.UUID)
                        rowsToUpdate{end+1}=thisObj.mData(modified(i).Element.UUID);
                    else
                        listrow=thisObj.mListSrc.getChildRow(modified(i).Element.UUID);
                        if~isempty(listrow)
                            thisObj.mValSrcMgr.updateListRow(listrow);
                        end
                    end
                end
            end
        end

        function active=getActive(thisObj)
            active=thisObj.mSrcObj.getActive();
        end

        function list=getEntryList(thisObj)
            list=thisObj.mSrcObj.getEntryList();
        end

        function priorityLevel=getOverlayPriority(thisObj,overlayObj)
            priorityLevel=1;
            values=thisObj.mChildList;
            if numel(values)>1
                overlayUUID=overlayObj.UUID;
                for i=1:numel(values)
                    if isequal(overlayUUID,values{i})
                        if i==1
                            priorityLevel=1;
                        elseif(i<numel(values))||(i==2)
                            priorityLevel=2;
                        else
                            priorityLevel=3;
                        end
                        break;
                    end
                end
            end
        end

        function updateDefinitions(thisObj,eventData,op)
            thisObj.mValSrcMgr.updateDetails(thisObj);
        end

        function rtn=cacheUpdateEvent(thisObj,eventData)
            rtn=false;
            if thisObj.mData.isKey(eventData.overlayUuid)
                rtn=true;
            end
        end

        function overlayList=getOverlayList(thisObj)
            overlays=thisObj.mSrcObj.getOverlayList();
            overlayList={};
            for idx=1:numel(overlays)

                overlayList=horzcat(overlays(idx),overlayList);
            end
        end
    end


    methods(Access=private)
        function[children,orderedList]=generateChildren(thisObj)
            children=containers.Map;
            orderedList={};
            list=thisObj.getOverlayList();
            for idxChild=1:numel(list)
                orderedList{end+1}=list(idxChild).UUID;
                if thisObj.mData.isKey(list(idxChild).UUID)
                    children(list(idxChild).UUID)=thisObj.mData(list(idxChild).UUID);
                else
                    child=sl_valuesrc.internal.ValueSrcRow(list(idxChild),thisObj,thisObj.mParamSrc,thisObj.mValSrcMgr);
                    children(list(idxChild).UUID)=child;
                end
            end
        end

        function newOverlayName=getUniqueOverlayName(thisObj,overlayName)
            overlays=thisObj.mSrcObj.getOverlayList();
            overlayList={};
            for idx=1:numel(overlays)
                overlayList{end+1}=overlays(idx).getName();
            end
            if~any(ismember(overlayList,overlayName))
                newOverlayName=overlayName;
                return;
            end
            index=1;
            while true
                newOverlayName=[overlayName,num2str(index)];
                if~any(ismember(overlayList,newOverlayName))
                    break;
                end
                index=index+1;
            end
        end

        function propsTab=buildPropsTab(thisObj)























































            valSrcLabel.Type='text';
            valSrcLabel.Name=message('sl_valuesrc:messages:ValueSources').getString;
            valSrcLabel.RowSpan=[6,6];
            valSrcLabel.ColSpan=[1,3];

            valSrc.Type='listbox';
            valSrc.Graphical=true;
            valSrc.Tag='ValueSrc';
            valSrc.RowSpan=[7,11];
            valSrc.ColSpan=[2,3];
            overlays=thisObj.getOverlayList();
            entries={};
            for idx=1:numel(overlays)
                [~,name,ext]=fileparts(overlays(idx).getSource());
                entries{end+1}=[name,ext];
            end
            valSrc.Entries=entries;
            valSrc.Source=thisObj;
            valSrc.ObjectMethod='onValSrcSelectionChanged';
            valSrc.MethodArgs={'%dialog','%tag'};
            valSrc.ArgDataTypes={'handle','string'};

            valSrcAdd.Type='pushbutton';
            valSrcAdd.Tag='ValueSrcAdd';
            valSrcAdd.FilePath=fullfile(matlabroot,'toolbox',...
            'simulink','sl_valuesrc','+sl_valuesrc','valuesrcPlugin','resources',...
            'icons','add_16.png');
            valSrcAdd.RowSpan=[7,7];
            valSrcAdd.ColSpan=[1,1];
            valSrcAdd.ObjectMethod='addSource';
            valSrcAdd.Source=thisObj;
            valSrcAdd.MethodArgs={};
            valSrcAdd.ArgDataTypes={};

            valSrcRemove.Type='pushbutton';
            valSrcRemove.Tag='ValueSrcRemove';
            valSrcRemove.FilePath=fullfile(matlabroot,'toolbox',...
            'simulink','sl_valuesrc','+sl_valuesrc','valuesrcPlugin','resources',...
            'icons','delete2_16.png');
            valSrcRemove.RowSpan=[8,8];
            valSrcRemove.ColSpan=[1,1];
            valSrcRemove.Enabled=false;
            valSrcRemove.ObjectMethod='removeOverlay';
            valSrcRemove.Source=thisObj;
            valSrcRemove.MethodArgs={'%dialog'};
            valSrcRemove.ArgDataTypes={'handle'};

            valSrcMoveUp.Type='pushbutton';
            valSrcMoveUp.Tag='ValueSrcMoveUp';
            valSrcMoveUp.FilePath=fullfile(matlabroot,'toolbox',...
            'simulink','sl_valuesrc','+sl_valuesrc','valuesrcPlugin','resources',...
            'icons','up_16.png');
            valSrcMoveUp.RowSpan=[9,9];
            valSrcMoveUp.ColSpan=[1,1];
            valSrcMoveUp.Enabled=false;
            valSrcMoveUp.ObjectMethod='moveSourceUp';
            valSrcMoveUp.Source=thisObj;
            valSrcMoveUp.MethodArgs={'%dialog'};
            valSrcMoveUp.ArgDataTypes={'handle'};

            valSrcMoveDown.Type='pushbutton';
            valSrcMoveDown.Tag='ValueSrcMoveDown';
            valSrcMoveDown.FilePath=fullfile(matlabroot,'toolbox',...
            'simulink','sl_valuesrc','+sl_valuesrc','valuesrcPlugin','resources',...
            'icons','down_16.png');
            valSrcMoveDown.RowSpan=[10,10];
            valSrcMoveDown.ColSpan=[1,1];
            valSrcMoveDown.Enabled=false;
            valSrcMoveDown.ObjectMethod='moveSourceDown';
            valSrcMoveDown.Source=thisObj;
            valSrcMoveDown.MethodArgs={'%dialog'};
            valSrcMoveDown.ArgDataTypes={'handle'};







            panel.Type='panel';
            panel.LayoutGrid=[1,1];
            panel.LayoutGrid=[12,3];
            panel.RowStretch=[0,0,0,0,0,0,0,0,0,0,1,.1];
            panel.ColStretch=[0,1,0];


            panel.Items={valSrcLabel,valSrc,valSrcAdd,valSrcRemove,valSrcMoveUp,valSrcMoveDown};

            propsTab.Name=message('sl_valuesrc:messages:PropertiesTab').getString;
            propsTab.LayoutGrid=[1,1];
            propsTab.Items={panel};
            propsTab.Tag='propsTab';
        end

        function paramsTab=buildParamsTab(thisObj)

            paramList.Type='spreadsheet';
            paramList.Tag='paramList';

            filterWidget.Type='spreadsheetfilter';
            filterWidget.Tag='spreadsheetfilter';
            filterWidget.TargetSpreadsheet=paramList.Tag;
            filterWidget.PlaceholderText=DAStudio.message('Simulink:studio:DataView_default_filter');
            filterWidget.Clearable=true;
            filterWidget.RowSpan=[1,1];
            filterWidget.ColSpan=[2,3];

            paramList.RowSpan=[2,3];
            paramList.ColSpan=[1,3];
            paramList.Columns={' ','Name'};
            paramList.SortColumn='Name';
            paramList.SortOrder=true;
            paramList.Source=sl_valuesrc.internal.ParameterDefinitions(thisObj.mSrcObj,thisObj.mParamSrc);
            paramList.SelectionChangedCallback=@(tag,sels,dlg)thisObj.onSelectionChanged(tag,sels,dlg);
            paramList.ItemDoubleClickedCallback=@thisObj.onDoubleClicked;

            addBtn.Type='pushbutton';
            addBtn.Name=message('sl_valuesrc:messages:AddParam').getString;
            addBtn.Tag='addBtn';
            addBtn.RowSpan=[4,4];
            addBtn.ColSpan=[3,3];
            addBtn.Enabled=false;
            addBtn.ObjectMethod='addToGroup';
            addBtn.Source=thisObj;
            addBtn.MethodArgs={'%dialog'};
            addBtn.ArgDataTypes={'handle'};

            panel.Type='panel';
            panel.LayoutGrid=[4,3];
            panel.RowStretch=[0,1,1,0];
            panel.ColStretch=[1,0,0];
            panel.Items={filterWidget,paramList,addBtn};

            paramsTab.Name=message('sl_valuesrc:messages:ParametersTab').getString;
            paramsTab.LayoutGrid=[1,1];
            paramsTab.Items={panel};
            paramsTab.Tag='paramsTab';
        end
    end

end
