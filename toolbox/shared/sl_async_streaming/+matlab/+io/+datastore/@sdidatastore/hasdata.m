function ret=hasdata(this)
    numChunks=getSignalNumChunks(this.Repo,this.SignalID);
    ret=this.LastReadChunkIndex<numChunks;
end