function[selectButton]=createSelectButton(source,rowSpan,colSpan)




    selectButton.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_Select');
    selectButton.Type='pushbutton';
    selectButton.RowSpan=rowSpan;
    selectButton.ColSpan=colSpan;
    selectButton.Tag='selectButton';
    selectButton.ObjectMethod='select';
    selectButton.MethodArgs={'%dialog'};
    selectButton.ArgDataTypes={'handle'};
    selectButton.Source=source;
    if~isempty(source)&&~isempty(source.signalSelector)&&~isempty(source.signalSelector.TCPeer)
        selectButton.Enabled=source.signalSelector.TCPeer.isAnyTreeSelection;
    else
        selectButton.Enabled=0;
    end
end

