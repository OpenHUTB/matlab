classdef ValueGroup<handle





    properties(Access=private)
        mSrcObj;
        mDefinitionsObj;
        mData;
        mCols;
    end


    methods(Static,Access=public)
    end


    methods(Access=public)
        function thisObj=ValueGroup(srcObj,definitionsObj)
            thisObj.mSrcObj=srcObj;
            thisObj.mDefinitionsObj=definitionsObj;
            thisObj.mData=containers.Map;
            thisObj.mCols={' ','Name','Default Value','Effective Value','Overlay'};
        end

        function[cols,sortCol]=getColumns(thisObj)
            cols=thisObj.mCols;
            sortCol='Name';
        end

        function valid=isValidProperty(thisObj,propName)
            valid=ismember(propName,thisObj.mCols);
        end

        function children=getChildren(thisObj,component,tab,userData)
            thisObj.mData=thisObj.generateChildren();
            values=thisObj.mData.values;
            if~isempty(values)
                for i=1:numel(values)
                    children(i)=values{i};
                end
            else
                children=[];
            end
        end

        function fwdObj=getForwardedObject(thisObj,srcObj)
            fwdObj=thisObj.mDefinitionsObj.getDefinitionObj(srcObj.getName());
        end

        function defObj=getDefinitionObject(thisObj,srcObj)
            defObj=thisObj.mDefinitionsObj.getDefinitionObj(srcObj.getName());
        end

        function defObj=getEffectiveObject(thisObj,srcObj)
            val=thisObj.getEffectiveValue(srcObj);
            defObj=thisObj.mDefinitionsObj.getEffectiveObject(srcObj.getName(),val);
        end

        function val=getEffectiveValue(thisObj,srcObj)
            val=[];
            try
                if~isempty(thisObj.mSrcObj)&&thisObj.mSrcObj.getActive()
                    val=srcObj.getValueThrowError();
                end
                if isempty(val)
                    obj=thisObj.mDefinitionsObj.getDefinitionObj(srcObj.getName());
                    val=obj.getValue();
                end
            catch ME
                val=DAStudio.message('Simulink:Data:MWSInaccessibleOverriddenValue');
            end
        end

        function row=getChildRow(thisObj,uuid)
            if thisObj.mData.isKey(uuid)
                row=thisObj.mData(uuid);
            else
                row=[];
            end
        end

    end


    methods(Access=private)
        function children=generateChildren(thisObj)
            children=containers.Map;
            list=thisObj.mSrcObj.getEntryList();
            for idxChild=1:numel(list)
                if thisObj.mData.isKey(list(idxChild).UUID)
                    children(list(idxChild).UUID)=thisObj.mData(list(idxChild).UUID);
                else

                    defObj=thisObj.mDefinitionsObj;
                    children(list(idxChild).UUID)=sl_valuesrc.internal.ValueGroupEntry(list(idxChild),defObj,thisObj,thisObj.mSrcObj);
                end
            end
        end
    end

end