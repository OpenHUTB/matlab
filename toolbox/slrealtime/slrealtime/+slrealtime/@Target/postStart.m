function postStart(this)








    if this.RunProfiler&&~strcmpi(this.ProfilerStatus,'Running')
        this.resetProfiler;
        this.startProfiler;
    end





    this.stateChart.startInitialized();
end
