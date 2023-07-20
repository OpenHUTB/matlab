classdef ValueSrc<handle





    properties(Access=private)
        mSrcObj;
        mGroupObj;
        mDefinitionSrcObj;
        mData;
        mCols;
    end


    methods(Static,Access=public)
    end


    methods(Access=public)
        function thisObj=ValueSrc(srcObj,groupObj,definitionSrcObj)
            thisObj.mSrcObj=srcObj;
            thisObj.mGroupObj=groupObj;
            thisObj.mDefinitionSrcObj=definitionSrcObj;
            thisObj.mData=containers.Map;
            thisObj.mCols={' ','Name','Value'};
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
            fwdObj=[];
        end
    end


    methods(Access=private)
        function children=generateChildren(thisObj)
            children=containers.Map;
            if~isvalid(thisObj.mSrcObj)
                return;
            end
            list=thisObj.mGroupObj.getEntryList();
            try
                for idxChild=1:numel(list)

                    if thisObj.mData.isKey(list(idxChild).UUID)
                        children(list(idxChild).UUID)=thisObj.mData(list(idxChild).UUID);
                    else

                        defObj=thisObj.mDefinitionSrcObj;
                        children(list(idxChild).UUID)=sl_valuesrc.internal.ValueSrcEntry(list(idxChild),defObj,thisObj,thisObj.mSrcObj);
                    end

                end
            catch ME
            end
        end
    end

end