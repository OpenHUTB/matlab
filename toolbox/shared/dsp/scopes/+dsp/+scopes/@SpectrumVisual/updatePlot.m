function[PSD,maxHoldPSD,minHoldPSD,FVect]=updatePlot(this)





    hPlotter=this.Plotter;
    if~isempty(this.CurrentPSD)
        [PSD,maxHoldPSD,minHoldPSD,FVect]=scaleSpectrum(this);
        if strcmp(this.pViewType,'Spectrogram')
            updateCurrentSpectrogram(this,PSD);
            S=this.CurrentSpectrogram;
            hPlotter.draw([],[],FVect,S);
        elseif strcmp(this.pViewType,'Spectrum')
            hPlotter.draw(maxHoldPSD,minHoldPSD,FVect,PSD);
        else
            S=this.CurrentSpectrogram;
            hPlotter.draw(maxHoldPSD,minHoldPSD,FVect,S,PSD);
        end
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



