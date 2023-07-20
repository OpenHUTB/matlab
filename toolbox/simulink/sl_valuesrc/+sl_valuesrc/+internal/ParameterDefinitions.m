classdef ParameterDefinitions<handle





    properties(Access=private)
        mValueGrpObj;
        mDefinitionsObj;
        mData;
    end


    methods(Static,Access=public)
    end


    methods(Access=public)
        function thisObj=ParameterDefinitions(valueGrpObj,definitionsObj)
            thisObj.mData=containers.Map;
            thisObj.mValueGrpObj=valueGrpObj;
            thisObj.mDefinitionsObj=definitionsObj;
        end

        function cols=getColumns(thisObj)
            cols={' ','Name'};
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

    end


    methods(Access=private)
        function children=generateChildren(thisObj)
            children=containers.Map;
            list=thisObj.mDefinitionsObj.getChildren('','','');
            for idxChild=1:numel(list)
                if thisObj.mData.isKey(list(idxChild).getUUID())
                    children(list(idxChild).getUUID())=thisObj.mData(list(idxChild).getUUID());
                else
                    children(list(idxChild).getUUID())=sl_valuesrc.internal.ParameterDefProxy(list(idxChild),thisObj.mValueGrpObj);
                end
            end
        end
    end

end