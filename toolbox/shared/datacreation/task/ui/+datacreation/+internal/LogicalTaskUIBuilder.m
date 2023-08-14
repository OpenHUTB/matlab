classdef(Hidden)LogicalTaskUIBuilder<datacreation.internal.TaskUIBuilder





    methods(Access=protected)

        function dataColumnFormat=getTableDataColumnFormat(obj)
            dataColumnFormat={'char'};
        end


        function msgOut=getDataTypeLabelStr(~)
            msgOut=message('datacreation:datacreation:dataTypeLogicalLabel').getString;
        end


        function createDataTypeWidget(obj)

            obj.app.UIComponents.DataTypeLogicalLabel=uilabel(obj.app.UIComponents.StoragePropGrid);
            obj.app.UIComponents.DataTypeLogicalLabel.HorizontalAlignment='left';
            obj.app.UIComponents.DataTypeLogicalLabel.Text=message('datacreation:datacreation:logicalDataType').getString;
        end


        function itemsSupported=getStorageSupportedItems(obj)




            itemsSupported={...
            message('datacreation:datacreation:timeseriesButtonLabel').getString,...
            message('datacreation:datacreation:timeTableButtonLabel').getString,...
            message('datacreation:datacreation:vectorButtonLabel').getString};
        end



    end


end
