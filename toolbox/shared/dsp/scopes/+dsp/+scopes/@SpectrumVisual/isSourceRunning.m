function flag=isSourceRunning(this)




    hSource=this.Application.DataSource;
    if isempty(hSource)
        flag=false;
    else
        flag=hSource.isRunning||hSource.isPaused;
    end
end
