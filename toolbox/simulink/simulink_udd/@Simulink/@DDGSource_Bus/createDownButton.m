function[downButton]=createDownButton(source,rowSpan,colSpan)




    downButton.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_Down');
    downButton.Type='pushbutton';
    downButton.RowSpan=rowSpan;
    downButton.ColSpan=colSpan;
    downButton.Enabled=0;
    downButton.Value=1;
    downButton.Tag='downButton';
    downButton.ObjectMethod='swap';
    downButton.MethodArgs={'%dialog',downButton.Value};
    downButton.ArgDataTypes={'handle','double'};
    downButton.Source=source;

end

