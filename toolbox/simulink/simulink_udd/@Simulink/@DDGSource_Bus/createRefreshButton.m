function[refreshButton]=createRefreshButton(source,rowSpan,colSpan)




    refreshButton.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_Refresh');
    refreshButton.Type='pushbutton';
    refreshButton.RowSpan=rowSpan;
    refreshButton.ColSpan=colSpan;
    refreshButton.Tag='refreshButton';
    refreshButton.ObjectMethod='refresh';
    refreshButton.MethodArgs={'%dialog',true};
    refreshButton.ArgDataTypes={'handle','bool'};
    refreshButton.Source=source;
end

