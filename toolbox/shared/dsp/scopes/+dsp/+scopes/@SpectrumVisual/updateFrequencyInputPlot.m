function updateFrequencyInputPlot(this)




    if~isempty(this.FrequencyInputData)||~isempty(this.CurrentSpectrogram)
        if isSpectrogramMode(this)||isCombinedViewMode(this)
            this.Plotter.draw(...
            this.CurrentMaxHoldPSD,...
            this.CurrentMinHoldPSD,...
            this.CurrentFVector,...
            this.ScaledSpectrogram{:},...
            this.ScaledFrequencyInputData)
        else

            this.Plotter.draw(this.CurrentMaxHoldPSD,...
            this.CurrentMinHoldPSD,...
            this.CurrentFVector,...
            this.ScaledFrequencyInputData)
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