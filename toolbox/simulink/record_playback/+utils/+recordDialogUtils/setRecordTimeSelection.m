function setRecordTimeSelection(dlg,obj)
    value=dlg.getComboBoxText('TimeSelectionCombobox');
    blockHandle=get(obj.blockObj,'handle');
    recordSettings=get_param(blockHandle,'FileSettings');
    excelSettings=recordSettings.excelSettings;

    switch excelSettings.time
    case Streamout.ExcelTime.INDIVIDUALCOLUMNS
        if strcmp(value,DAStudio.message('record_playback:toolstrip:IndividualTimeColumns'))
            return;
        else
            recordSettings.excelSettings.time=Streamout.ExcelTime.SHAREDCOLUMNS;
        end
    case Streamout.ExcelTime.SHAREDCOLUMNS
        if strcmp(value,DAStudio.message('record_playback:toolstrip:SharedTimeColumns'))
            return;
        else
            recordSettings.excelSettings.time=Streamout.ExcelTime.INDIVIDUALCOLUMNS;
        end
    end

    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{'FileSettings',recordSettings});

    dlg.clearWidgetDirtyFlag('TimeSelectionCombobox');
end
