function fract=progress(this)
    numChunks=getSignalNumChunks(this.Repo,this.SignalID);
    fract=double(this.LastReadChunkIndex)/double(numChunks);
end

