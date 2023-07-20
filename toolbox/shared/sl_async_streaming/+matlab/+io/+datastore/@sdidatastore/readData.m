function[data,info]=readData(this)
    if hasdata(this)
        opt.sigID=this.SignalID;
        opt.chunk=this.LastReadChunkIndex+1;
        exporter=Simulink.sdi.internal.export.WorkspaceExporter.getDefault();
        ds=exportRun(exporter,this.Repo,opt,false);
        assert(numElements(ds)==1);
        el=getElement(ds,1);
        vals=el.Values;
        this.LastReadChunkIndex=this.LastReadChunkIndex+1;
    else
        vals.Time=[];
        vals.Data=[];
    end

    [data,info]=createTimetable(this,vals);
end
