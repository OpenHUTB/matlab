function bindSignal(sigId,row,column)



























    eng=Simulink.sdi.Instance.engine();
    curPlotIdx=eng.sigRepository.getSignalChecked(sigId);

    if nargin==3

        subPlotId=(column-1)*8+row;
    else

        subPlotId=Simulink.sdi.getSelectedPlot(eng.sigRepository);
    end
    if isempty(curPlotIdx(curPlotIdx==subPlotId))
        plotIndices=[curPlotIdx;subPlotId];
    else
        return;
    end

    eng.sigRepository.setSignalChecked(sigId,plotIndices);
    notify(eng,'treeSignalPropertyEvent',Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',...
    sigId,plotIndices,'checked'));

end
