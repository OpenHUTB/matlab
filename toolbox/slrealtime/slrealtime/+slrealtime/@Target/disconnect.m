function disconnect(this)













    if startsWith(this.stateChartGetActiveState(),'Status.Connected.Loading')


        slrealtime.internal.throw.Warning('slrealtime:target:appLoading');
        return;
    end

    this.stateChart.disconnect;
    notify(this,'PostDisconnected');
end
