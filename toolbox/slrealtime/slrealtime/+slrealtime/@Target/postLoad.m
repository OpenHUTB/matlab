function postLoad(this)







    appName=this.tc.ModelProperties.Application;

    this.xcpConnect();










    if this.RunProfiler
        this.startProfiler(appName);
    end





    this.stateChart.loadInitialized();
end
