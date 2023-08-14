function ret=hasdata(this)



    numChunks=getSignalNumChunks(this.Repo.sigRepository,this.SignalID);
    ret=this.LastReadChunkIndex<=numChunks&&...
    this.currChunkIdx<=this.currChunkSize;
end
