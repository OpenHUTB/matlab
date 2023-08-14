function S=updateSpectrogramPlot(this)





    hPlotter=this.Plotter;
    S=this.CurrentSpectrogram;
    if~isempty(S)
        S=scaleSpectrogram(this);
        hPlotter.draw([],[],this.CurrentFVector,S);
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
