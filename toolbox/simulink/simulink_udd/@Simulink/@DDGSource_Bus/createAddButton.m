function[addButton]=createAddButton(source,rowSpan,colSpan)




    addButton.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_Add');
    addButton.Type='pushbutton';
    addButton.RowSpan=rowSpan;
    addButton.ColSpan=colSpan;
    addButton.Tag='addButton';
    addButton.ObjectMethod='add';
    addButton.MethodArgs={'%dialog'};
    addButton.ArgDataTypes={'handle'};
    addButton.Source=source;
end
