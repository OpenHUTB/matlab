function deleteChoice(ddgCreator,dlg)






    spreadSheetInterface=dlg.getWidgetInterface(ddgCreator.SpreadSheetTag);


    selectedRows=spreadSheetInterface.getSelection();
    if isempty(selectedRows)
        return;
    end


    for selectedId=1:numel(selectedRows)
        selectedRow=selectedRows{selectedId};
        ddgCreator.removeChoice(selectedRow.Condition);
    end


    spreadSheetInterface.update();
    dlg.enableApplyButton(true);
end
