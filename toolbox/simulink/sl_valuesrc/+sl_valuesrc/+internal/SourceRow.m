classdef SourceRow<handle






    properties(Access=protected)
        mRowID;
        mDefinitionSrcObj;
        mData;
        mRefresh;
        mValSrcMgr;
        mPendingSelection;
    end


    methods(Static,Access=public)
    end


    methods(Access=public)
        function thisObj=SourceRow(rowID,srcObj,valsrcMgr)
            thisObj.mRowID=rowID;
            thisObj.mDefinitionSrcObj=srcObj;
            thisObj.mData=containers.Map;
            thisObj.mRefresh=true;
            thisObj.mValSrcMgr=valsrcMgr;
            thisObj.mPendingSelection=[];
        end

        function doCreate(thisObj)
            if isempty(thisObj.mDefinitionSrcObj)
                return;
            end
            valueSrcManager=thisObj.mDefinitionSrcObj.getValueSrcManager();
            srcMdl=thisObj.mDefinitionSrcObj.getSourceModel();
            txn=srcMdl.beginTransaction();
            newName=thisObj.getNewGroupName();
            vset=valueSrcManager.addValueOverrideGroup();
            vset.setName(newName);
            vset.setActive(true);
            thisObj.mPendingSelection=vset;
            txn.commit();
        end

        function label=getDisplayLabel(thisObj)
            try
                label=message(thisObj.mRowID).getString;
            catch
                label=thisObj.mRowID;
            end
        end

        function valid=isValidProperty(thisObj,propName)
            valid=false;
            if isempty(propName)||isequal(propName,'Name')
                valid=true;
            end
        end

        function readonly=isReadonlyProperty(thisObj,propName)
            readonly=true;
        end

        function prop=getPropValue(thisObj,propName)
            if isempty(propName)
                prop=getDisplayLabel(thisObj);
            end
        end

        function dlgstruct=getDialogSchema(thisObj,arg1)
            dlgstruct=[];
        end

        function[nodesToUpdate,anyHierarchyChange]=handleListener(thisObj,changeReport)
            nodesToUpdate={};
            anyHierarchyChange=false;
            values=thisObj.mData.values;
            for i=1:numel(values)
                [node,hierarchyChange]=values{i}.handleListener(changeReport);
                if~isempty(node)
                    nodesToUpdate=[nodesToUpdate,node];
                end
                anyHierarchyChange=anyHierarchyChange|hierarchyChange;
            end

            refreshEffectiveValues=false;
            if~isempty(changeReport.Modified)
                modified=changeReport.Modified;
                for i=1:numel(modified)
                    if isequal(class(modified(i).Element),'valuesrc.ValueManager')
                        thisObj.mRefresh=true;
                        anyHierarchyChange=true;
                        break;
                    elseif isequal(class(modified(i).Element),'valuesrc.ValueOverrideGroup')
                        if~isempty(modified(i).ModifiedProperties)
                            prop=modified(i).ModifiedProperties.name;
                            if isequal(prop,'isActive')||...
                                isequal(prop,'valueOverlayList')||...
                                isequal(prop,'valueEntryMap')
                                refreshEffectiveValues=true;
                            end
                        end
                    elseif isequal(class(modified(i).Element),'valuesrc.ValueOverlay')
                        if~isempty(modified(i).ModifiedProperties)
                            prop=modified(i).ModifiedProperties.name;
                            if isequal(prop,'isActive')
                                refreshEffectiveValues=true;
                            end
                        end
                    end
                end
            end
            if refreshEffectiveValues
                thisObj.mDefinitionSrcObj.refreshValues();
            end
        end

        function nodeToSelect=getPendingSelection(thisObj)
            nodeToSelect=thisObj.mPendingSelection;
            if~isempty(thisObj.mPendingSelection)
                try
                    if thisObj.mData.isKey(thisObj.mPendingSelection.UUID)
                        nodeToSelect=thisObj.mData(thisObj.mPendingSelection.UUID);
                    end
                catch
                end
            end
            thisObj.mPendingSelection=[];
        end
    end


    methods(Access=protected)

        function newName=getNewGroupName(thisObj)
            valueSrcManager=thisObj.mDefinitionSrcObj.getValueSrcManager();
            list=valueSrcManager.getValueOverrideGroupList;
            namelist={};
            for i=1:numel(list)
                namelist{end+1}=list(i).getName();
            end
            baseName=message("sl_valuesrc:messages:GroupBaseName").getString();
            index=1;
            while(ismember([baseName,num2str(index)],namelist))
                index=index+1;
            end

            newName=[baseName,num2str(index)];
        end
    end

end