classdef ValueSrcRow<handle





    properties(Access=private)
        mSrcObj;
        mData;
        mListObj;
        mListSrc;
        mDefinitionSrcObj;
        mGroupObj;
        mValSrcMgr;
    end


    methods(Static,Access=public)

    end


    methods
        function addToGroup(thisObj,dlg)
            ss=dlg.getWidgetInterface('paramList');
            selection=ss.getSelection();
            for i=1:numel(selection)
                thisObj.mSrcObj.addEntry(selection{i}.getUUID());
            end
            if~isempty(thisObj.mListObj)
                thisObj.mListObj.refresh();
                dlg.refresh();
            end
        end
    end
    methods(Access=public)
        function thisObj=ValueSrcRow(srcObj,groupObj,definitionSrcObj,valsrcMgr)
            thisObj.mSrcObj=srcObj;
            thisObj.mGroupObj=groupObj;
            thisObj.mDefinitionSrcObj=definitionSrcObj;
            thisObj.mValSrcMgr=valsrcMgr;
            thisObj.mListSrc=sl_valuesrc.internal.ValueSrc(thisObj.mSrcObj,thisObj.mGroupObj,thisObj.mDefinitionSrcObj);
        end

        function children=getChildren(thisObj)
            children=[];
            if isempty(thisObj.mData)

            end
            children=thisObj.mData;
        end

        function label=getDisplayLabel(thisObj)
            label=thisObj.mSrcObj.getName();
        end

        function icon=getDisplayIcon(thisObj)
            if~thisObj.mGroupObj.getActive()
                icon='toolbox/simulink/sl_valuesrc/+sl_valuesrc/valuesrcPlugin/resources/icons/Bars0_16.png';
            else
                priority=thisObj.mGroupObj.getOverlayPriority(thisObj.mSrcObj);
                switch priority
                case 1
                    icon='toolbox/simulink/sl_valuesrc/+sl_valuesrc/valuesrcPlugin/resources/icons/Bars3_16.png';
                case 2
                    icon='toolbox/simulink/sl_valuesrc/+sl_valuesrc/valuesrcPlugin/resources/icons/Bars2_16.png';
                case 3
                    icon='toolbox/simulink/sl_valuesrc/+sl_valuesrc/valuesrcPlugin/resources/icons/Bars1_16.png';
                end
            end
        end

        function valid=isValidProperty(thisObj,propName)
            valid=false;
            if isempty(propName)||isequal(propName,'Name')||isequal(propName,'Active')
                valid=true;
            end
        end

        function readonly=isReadonlyProperty(thisObj,propName)
            readonly=false;
            if isequal(propName,'Active')
                readonly=~thisObj.mGroupObj.getActive();
            end
        end

        function datatype=getPropDataType(thisObj,propName)
            datatype='string';
            if isequal(propName,'Active')
                datatype='bool';
            end
        end

        function prop=getPropValue(thisObj,propName)
            prop='';
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
                if thisObj.isOverlayNameUnique(value)
                    thisObj.mSrcObj.setName(value);
                end
            elseif isequal(propName,'Active')
                if isequal(value,'1')
                    thisObj.mSrcObj.setActive(true);
                else
                    thisObj.mSrcObj.setActive(false);
                end
            end
            if~isempty(thisObj.mListObj)
                thisObj.mListObj.refresh(true);
            end
        end

        function getPropertyStyle(thisObj,propName,propertyStyle)
            if isempty(propName)||isequal(propName,'Name')
                filename=thisObj.mSrcObj.getSource();
                [path,name,ext]=fileparts(filename);
                filedisp=['(',name,ext,')'];
                propertyStyle.WidgetInfo=struct('Type','label','Text',filedisp,'Location','right');
            end
        end

        function dlgStruct=getDialogSchema(thisObj,arg1)
            dlgStruct=[];

            nameLbl.Name=message('sl_valuesrc:messages:NameLabel').getString;
            nameLbl.Type='text';
            nameLbl.RowSpan=[1,1];
            nameLbl.ColSpan=[1,1];
            nameFld.Source=thisObj;
            nameFld.ObjectProperty='Name';
            nameFld.Type='edit';
            nameFld.Tag='name';
            nameFld.RowSpan=[1,1];
            nameFld.ColSpan=[2,2];
            nameFld.Mode=1;
            nameFld.Graphical=1;

            overlayFile=thisObj.mSrcObj.getSource();
            [~,name,ext]=fileparts(overlayFile);
            filedisp=[name,ext];

            fileLbl.Name=message('sl_valuesrc:messages:FileLabel').getString;
            fileLbl.Type='text';
            fileLbl.RowSpan=[2,2];
            fileLbl.ColSpan=[1,1];
            fileFld.Name=filedisp;
            fileFld.Tag='file';
            fileFld.Type='text';
            fileFld.RowSpan=[2,2];
            fileFld.ColSpan=[2,2];

            metaGrp.Type='panel';
            metaGrp.LayoutGrid=[2,2];
            metaGrp.ColStretch=[0,1];
            metaGrp.RowSpan=[1,1];
            metaGrp.ColSpan=[1,2];
            metaGrp.Items={nameLbl,nameFld,fileLbl,fileFld};

            dlgStruct.Items={metaGrp};
            dlgStruct.LayoutGrid=[2,2];
            dlgStruct.ColStretch=[0,0];
            dlgStruct.RowStretch=[0,1];
            dlgStruct.DialogTitle=message('sl_valuesrc:messages:OverlayLabel').getString;

        end

        function src=getListSource(thisObj)
            src=thisObj.mListSrc;
        end

        function setListObj(thisObj,listObj)
            thisObj.mListObj=listObj;
        end

        function addSource(thisObj)
            thisObj.mGroupObj.addSource();
        end

        function delSource(thisObj)
            thisObj.mListObj=[];
            thisObj.mListSrc=[];
            thisObj.mGroupObj.deleteOverlay(thisObj.mSrcObj);
        end

        function rtn=cacheUpdateEvent(thisObj,eventData)
            rtn=false;
            if isequal(thisObj.mSrcObj.UUID,eventData.overlayUuid)
                rtn=true;
            end
        end

        function updateDefinitions(thisObj,eventData,op)
            if~isequal(op,'add')
                thisObj.mValSrcMgr.updateListRow([]);
            end
        end

        function adjustToolstrip(thisObj,toolstrip,selection)
            topAction=toolstrip.getAction('topPriority_PushButtonAction');
            incrAction=toolstrip.getAction('incrPriority_PushButtonAction');
            decrAction=toolstrip.getAction('decrPriority_PushButtonAction');
            if isequal(numel(selection),1)
                thisObj.adjustToolstripAction(topAction);
                thisObj.adjustToolstripAction(incrAction);
                thisObj.adjustToolstripAction(decrAction);
            else
                topAction.enabled=false;
                incrAction.enabled=false;
                decrAction.enabled=false;
            end
        end

        function adjustToolstripAction(thisObj,action)
            overlays=thisObj.mGroupObj.getOverlayList();
            if numel(overlays)<2

                return;
            end
            position=find(ismember(overlays,thisObj.mSrcObj));

            if position>1
                upAction=true;
            else
                upAction=false;
            end

            if position<numel(overlays)
                downAction=true;
            else
                downAction=false;
            end

            if isequal(action.name,'topPriority_PushButtonAction')||...
                isequal(action.name,'incrPriority_PushButtonAction')
                action.enabled=upAction;
            elseif isequal(action.name,'decrPriority_PushButtonAction')
                action.enabled=downAction;
            end
        end

        function topPriority(thisObj)
            thisObj.mGroupObj.topPriority(thisObj.mSrcObj);
        end

        function incrPriority(thisObj)
            thisObj.mGroupObj.incrPriority(thisObj.mSrcObj);
        end

        function decrPriority(thisObj)
            thisObj.mGroupObj.decrPriority(thisObj.mSrcObj);
        end

    end


    methods(Access=private)
        function children=generateChildren(thisObj)
            children=[];
        end

        function isUnique=isOverlayNameUnique(thisObj,overlayName)
            overlays=thisObj.mGroupObj.getOverlayList();
            overlayList={};
            for idx=1:numel(overlays)
                overlayList{end+1}=overlays(idx).getName();
            end
            if~any(ismember(overlayList,overlayName))
                isUnique=true;
            else
                isUnique=false;
            end
        end
    end

end