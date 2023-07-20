function DSMaskValueChangedCallback(dlg,row,column,newValue)







    if(column==0)
        dlgSource=dlg.getDialogSource();
        dlgSource.signals{row+1,1}=strtrim(newValue);
        dlg.refresh();
    end

end

