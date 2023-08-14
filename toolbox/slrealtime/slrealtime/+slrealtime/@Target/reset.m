function reset(this)





    try
        this.cleanupAsyncFlags();
        this.xcpDisconnect();
        this.disconnectTarget();

        delete(this.stateChart);
        this.stateChart=TargetStateChart('tg_',this);

        this.disableCANBusLogging();
        this.cleanupCANBusLogging();

        this.cleanupRecording();
    catch

    end
end
