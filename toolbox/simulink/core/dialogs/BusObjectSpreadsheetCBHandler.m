classdef BusObjectSpreadsheetCBHandler<handle

    properties
    end

    methods
        function obj=BusObjectSpreadsheetCBHandler()
        end
    end

    methods(Static)
        function onLoadingCompleteCB(compTag,dlg)
            selectionData=dlg.getUserData('MoveElementDownBtn').selData;
            if~dlg.isVisible('BusObjectSpreadsheet')
                dlg.setVisible('BusObjectSpreadsheet');
            end

            DialogState=dlg.getUserData('MoveElementUpBtn');
            tempBusObject=DialogState.tempBusObject;
            if isempty(tempBusObject.Elements)
                dlg.setEnabled('AddElementBtn',true);
                dlg.setEnabled('DeleteElementBtn',false);
            end

            w=dlg.getWidgetInterface(compTag);
            w.select(selectionData);
        end
    end
end