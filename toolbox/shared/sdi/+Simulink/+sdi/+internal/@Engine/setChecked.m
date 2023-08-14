function setChecked(this,id,value)
    plotIdx=Simulink.sdi.getSelectedPlot(this.sigRepository);
    curPlotIdx=this.sigRepository.getSignalChecked(id);
    if value

        if isempty(curPlotIdx(curPlotIdx==plotIdx))
            value=[curPlotIdx;plotIdx];
        else

            return;
        end
    else
        if isempty(curPlotIdx(curPlotIdx==plotIdx))

            return;
        else

            value=curPlotIdx;
            value(value==plotIdx)=[];
        end
    end

    this.sigRepository.setSignalChecked(id,value);
    Simulink.sdi.internalSWSCheckSignal(id);
    this.dirty=true;
end
