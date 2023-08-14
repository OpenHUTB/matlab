function[outputsList]=createSelectionList(source,block)




    outputsList.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_OutputList');
    outputsList.Type='listbox';
    outputsList.MultiSelect=1;
    outputsList.Entries=validate(source,block);
    outputsList.UserData=outputsList.Entries;
    outputsList.RowSpan=[1,4];
    outputsList.ColSpan=[1,1];
    outputsList.MinimumSize=[200,200];
    outputsList.Tag='outputsList';
    outputsList.ObjectMethod='hiliteSignalInList';
    outputsList.MethodArgs={'%dialog'};
    outputsList.ArgDataTypes={'handle'};
    outputsList.ListKeyPressCallback=@listKeyPressCB;
    outputsList.Source=source;
end


function listKeyPressCB(dlg,tag,key)%#ok
    if strcmpi(key,'del')
        dlg.getDialogSource.remove(dlg);
    end
end

