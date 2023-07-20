classdef MulticoreSpreadsheetDataSource<handle





    properties
UIObj
SpreadsheetObj
MappingData
Data
    end

    methods
        function obj=MulticoreSpreadsheetDataSource(uiObj,ssObj)
            obj.UIObj=uiObj;
            obj.SpreadsheetObj=ssObj;
        end

        function mappingData=get.MappingData(obj)
            mappingData=getMappingData(obj.UIObj);
        end

        function children=getChildren(obj,~,x,y)%#ok<INUSD>
            obj.Data=[];


            updateContents(obj);
            obj.SpreadsheetObj.Component.setConfig('{"expandall":true, "disablepropertyinspectorupdate":true}');
            children=obj.Data;
        end
        function gr=getColumnGroup(~)
            gr='';
        end
    end

    methods(Abstract)
        columns=getColumns(obj)
        [sortColumn,direction]=getSortColumn(obj)
        updateContents(obj)
    end
end


