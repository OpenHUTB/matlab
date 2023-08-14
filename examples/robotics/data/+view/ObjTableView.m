classdef ObjTableView<handle



    properties
HandleTable
    end
    methods
        function obj=ObjTableView(hTable)
            obj.HandleTable=hTable;
        end
        function updateObjTable(obj,tableData)


            obj.HandleTable.Data=tableData;
            nCols=size(obj.HandleTable.Data.Variables,2);
            obj.HandleTable.ColumnEditable=true([1,nCols]);
        end
    end
end

