function[removeButton]=createRemoveButton(source,rowSpan,colSpan)





    removeButton.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_Remove');
    removeButton.Type='pushbutton';
    removeButton.RowSpan=rowSpan;
    removeButton.ColSpan=colSpan;
    removeButton.Enabled=0;
    removeButton.Tag='removeButton';
    removeButton.ObjectMethod='remove';
    removeButton.MethodArgs={'%dialog'};
    removeButton.ArgDataTypes={'handle'};
    removeButton.Source=source;
end

