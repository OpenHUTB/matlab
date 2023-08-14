function deleteQueryRow()

    maskObj=Simulink.Mask.get(gcb);
    tableControl=maskObj.getDialogControl('queryTable');
    tempSelectedRows=tableControl.getSelectedRows;
    if~isempty(tempSelectedRows)
        tableControl.removeRow(tempSelectedRows);
    end

end

