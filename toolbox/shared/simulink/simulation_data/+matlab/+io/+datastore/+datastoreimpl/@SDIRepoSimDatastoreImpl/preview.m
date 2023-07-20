function previewData=preview(this,varargin)



    rowsToRead=10;
    if nargin>1
        rowsToRead=varargin{1};
        if iscell(rowsToRead)
            rowsToRead=rowsToRead{1};
        end
    end

    opt.sigID=this.SignalID;
    opt.chunk=1;
    ds=exportRun(this.Repo.WksExporter,this.Repo,opt,false);
    assert(numElements(ds)==1);
    el=getElement(ds,1);
    vals=el.Values;

    previewData=createTimetable(this,vals,rowsToRead);
end
