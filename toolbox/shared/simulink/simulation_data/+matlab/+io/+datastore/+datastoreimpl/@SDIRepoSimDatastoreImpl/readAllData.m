function[data,info]=readAllData(this)



    opt.sigID=this.SignalID;
    ds=exportRun(this.Repo.WksExporter,this.Repo,opt,false);
    assert(numElements(ds)==1);
    el=getElement(ds,1);
    [data,info]=createTimetable(this,el.Values);
end
