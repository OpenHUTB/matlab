function[data,info]=readAllData(this)
    opt.sigID=this.SignalID;
    exporter=Simulink.sdi.internal.export.WorkspaceExporter.getDefault();
    ds=exportRun(exporter,this.Repo,opt,false);
    assert(numElements(ds)==1);
    el=getElement(ds,1);
    [data,info]=createTimetable(this,el.Values);
end
