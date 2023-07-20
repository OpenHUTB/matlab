function unbindSignal(sigId,row,column)



























    eng=Simulink.sdi.Instance.engine();
    curPlotId=eng.sigRepository.getSignalChecked(sigId);

    if nargin==3

        subPlotId=(column-1)*8+row;
    else

        subPlotId=Simulink.sdi.getSelectedPlot(eng.sigRepository);
    end

    if isempty(curPlotId(curPlotId==subPlotId))

        return;
    else

        plotIndices=curPlotId;
        plotIndices(plotIndices==subPlotId)=[];
    end

    eng.sigRepository.setSignalChecked(sigId,plotIndices);
    notify(eng,'treeSignalPropertyEvent',Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',...
    sigId,plotIndices,'checked'));

end
