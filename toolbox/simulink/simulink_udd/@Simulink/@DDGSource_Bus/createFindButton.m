function[findButton]=createFindButton(source,rowSpan,colSpan)




    findButton.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_Find');
    findButton.Type='pushbutton';
    findButton.RowSpan=rowSpan;
    findButton.ColSpan=colSpan;
    findButton.Tag='findButton';
    findButton.ObjectMethod='findSrc';
    findButton.MethodArgs={'%dialog'};
    findButton.ArgDataTypes={'handle'};
    findButton.Source=source;
    if~isempty(source)&&~isempty(source.signalSelector)&&~isempty(source.signalSelector.TCPeer)
        findButton.Enabled=source.signalSelector.TCPeer.isAnyTreeSelection;
    else
        findButton.Enabled=0;
    end
end

