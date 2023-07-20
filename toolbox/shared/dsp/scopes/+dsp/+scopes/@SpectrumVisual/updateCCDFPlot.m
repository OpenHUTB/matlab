function updateCCDFPlot(this)





    if~isempty(this.CurrentCCDFDistribution)
        drawCCDFDistribution(this.Plotter,this.CurrentCCDFDistribution);
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
