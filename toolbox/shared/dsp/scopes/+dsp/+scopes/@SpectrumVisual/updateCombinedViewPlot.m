function[PSD,S,maxHoldPSD,minHoldPSD,FVect]=updateCombinedViewPlot(this)





    hPlotter=this.Plotter;
    if~(isempty(this.CurrentSpectrogram)&&isempty(this.CurrentPSD))
        [PSD,maxHoldPSD,minHoldPSD,FVect]=scaleSpectrum(this);
        S=scaleSpectrogram(this);
        hPlotter.draw(maxHoldPSD,minHoldPSD,FVect,S,PSD);

        if~this.ReduceUpdates||this.IsSystemObjectSource
            drawnow expose;
        end
        sendEvent(this.Application,'VisualUpdated');

        if this.IsSystemObjectSource&&this.ReduceUpdates
            this.DataBuffer.restartTimer();
        end
    end



    if~this.ReduceUpdates&&this.DrawNowTimer.isTimeUp
        drawnow;
        this.DrawNowTimer.start;
    end
end


