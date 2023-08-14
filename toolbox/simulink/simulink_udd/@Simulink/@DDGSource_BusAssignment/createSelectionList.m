function[assignedList]=createSelectionList(source,block)




    assignedList.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_AssignedList');
    assignedList.Type='listbox';
    assignedList.MultiSelect=1;
    assignedList.Entries=validate(source,block);
    assignedList.UserData=assignedList.Entries;
    assignedList.RowSpan=[1,4];
    assignedList.ColSpan=[1,1];
    assignedList.MinimumSize=[200,200];
    assignedList.Tag='assignedList';
    assignedList.ObjectMethod='hiliteSignalInList';
    assignedList.MethodArgs={'%dialog'};
    assignedList.ArgDataTypes={'handle'};
    assignedList.ListKeyPressCallback=@listKeyPressCB;
    assignedList.Source=source;
end


function listKeyPressCB(dlg,tag,key)%#ok
    if strcmpi(key,'del')
        dlg.getDialogSource.remove(dlg);
    end
end

