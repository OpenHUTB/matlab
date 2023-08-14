function[data,info]=readData(this)



    if~hasdata(this)
        error(message(...
'MATLAB:datastoreio:splittabledatastore:noMoreData'...
        )...
        );
    end

    info=struct();

    if isempty(this.currChunk)
        opt.sigID=this.SignalID;
        opt.chunk=1;
        ds=exportRun(this.Repo.WksExporter,this.Repo,opt,false);
        assert(numElements(ds)==1);
        el=getElement(ds,1);
        vals=el.Values;
        this.currChunk=createTimetable(this,vals);
        this.currChunkIdx=1;
        this.currChunkSize=numel(vals.Data);
        this.LastReadChunkIndex=1;
    end

    data=[];
    chunksToReadBeyondCurr=mod(this.ReadSize+this.currChunkIdx-1,this.ReadSize);
    while chunksToReadBeyondCurr>1

        data=[data;this.currChunk(this.currChunkIdx:this.currChunkSize,:)];%#ok<AGROW>


        opt.sigID=this.SignalID;
        opt.chunk=this.LastReadChunkIndex+1;
        ds=exportRun(this.Repo.WksExporter,this.Repo,opt,false);
        assert(numElements(ds)==1);
        el=getElement(ds,1);
        vals=el.Values;
        this.LastReadChunkIndex=this.LastReadChunkIndex+1;
        this.currChunk=createTimetable(this,vals);
        this.currChunkIdx=mod(this.currChunkIdx,this.ReadSize);
        data=[data,this.currChunk(1:this.currChunkIdx-1,:)];%#ok<AGROW>
        chunksToReadBeyondCurr=chunksToReadBeyondCurr-1;
    end

    lastChunkIdx=min(this.ReadSize-1,this.currChunkSize-this.currChunkIdx);
    data=[data,this.currChunk(this.currChunkIdx:this.currChunkIdx+lastChunkIdx,:)];
    this.currChunkIdx=this.currChunkIdx+this.ReadSize;

end


