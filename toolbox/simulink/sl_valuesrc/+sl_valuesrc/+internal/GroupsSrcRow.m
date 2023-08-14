classdef GroupsSrcRow<sl_valuesrc.internal.SourceRow




    properties(Access=private)
    end


    methods(Static,Access=public)
    end


    methods(Access=public)
        function thisObj=GroupsSrcRow(rowID,srcObj,valsrcMgr)
            thisObj@sl_valuesrc.internal.SourceRow(rowID,srcObj,valsrcMgr);
        end

        function tf=isHierarchical(thisObj)
            tf=true;
        end

        function tf=isHierarchicalChildren(thisObj)
            tf=true;
        end

        function children=getHierarchicalChildren(thisObj)
            children=[];
            if isempty(thisObj.mData)||thisObj.mRefresh
                thisObj.mRefresh=false;
                thisObj.mData=thisObj.generateChildren();
            end
            values=thisObj.mData.values;
            names=containers.Map;
            for i=1:numel(values)
                names(values{i}.getDisplayLabel())=values{i};
            end
            children=[];
            values=names.values;
            if~isempty(values)
                children=values{1};
                for i=2:numel(values)
                    children(i)=values{i};
                end
            end
        end

        function icon=getDisplayIcon(thisObj)
            icon='toolbox/simulink/sl_valuesrc/+sl_valuesrc/valuesrcPlugin/resources/icons/Folder_16.png';
        end

        function dlgstruct=getDialogSchema(thisObj,arg1)
            dlgstruct=[];
        end

        function src=getListSource(thisObj)
            src='';
        end

        function[nodesToUpdate,anyHierarchyChange]=handleListener(thisObj,changeReport)
            [nodesToUpdate,anyHierarchyChange]=handleListener@sl_valuesrc.internal.SourceRow(thisObj,changeReport);
        end

    end


    methods(Access=private)
        function children=generateChildren(thisObj)
            children=containers.Map;
            if isequal(thisObj.mRowID,'sl_valuesrc:messages:ParameterGroups')
                if isempty(thisObj.mDefinitionSrcObj)
                    return;
                end
                valueSrcManager=thisObj.mDefinitionSrcObj.getValueSrcManager();
                list=valueSrcManager.getValueOverrideGroupList();
                for idxChild=1:numel(list)
                    if thisObj.mData.isKey(list(idxChild).UUID)
                        children(list(idxChild).UUID)=thisObj.mData(list(idxChild).UUID);
                    else
                        child=sl_valuesrc.internal.ValueGroupRow(list(idxChild),thisObj.mValSrcMgr,thisObj.mDefinitionSrcObj);
                        children(list(idxChild).UUID)=child;
                    end
                end
            end
        end
    end

end