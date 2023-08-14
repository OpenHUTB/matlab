function[upButton]=createUpButton(source,rowSpan,colSpan)




    upButton.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_Up');
    upButton.Type='pushbutton';
    upButton.RowSpan=rowSpan;
    upButton.ColSpan=colSpan;
    upButton.Enabled=0;
    upButton.Value=-1;
    upButton.Tag='upButton';
    upButton.ObjectMethod='swap';
    upButton.MethodArgs={'%dialog',upButton.Value};
    upButton.ArgDataTypes={'handle','double'};
    upButton.Source=source;
end

