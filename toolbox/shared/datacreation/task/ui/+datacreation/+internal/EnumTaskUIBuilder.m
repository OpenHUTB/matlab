classdef(Hidden)EnumTaskUIBuilder<datacreation.internal.TaskUIBuilder





    methods(Access=protected)


        function createDataTypeLabelAndWidget(obj)
            obj.app.UIComponents.DataTypeDropDownLabel=uilabel(obj.app.UIComponents.StoragePropGrid);
            obj.app.UIComponents.DataTypeDropDownLabel.HorizontalAlignment='left';
            obj.app.UIComponents.DataTypeDropDownLabel.Text=message('datacreation:datacreation:dataTypeEnumerationLabel').getString;
            obj.app.UIComponents.EnumEditField=uieditfield(obj.app.UIComponents.StoragePropGrid);

            obj.app.UIComponents.EnumEditField.Value='matlab.lang.OnOffSwitchState';
        end


        function itemsSupported=getStorageSupportedItems(obj)




            itemsSupported={...
            message('datacreation:datacreation:timeseriesButtonLabel').getString,...
            message('datacreation:datacreation:timeTableButtonLabel').getString,...
            message('datacreation:datacreation:vectorButtonLabel').getString};
        end

    end


end
