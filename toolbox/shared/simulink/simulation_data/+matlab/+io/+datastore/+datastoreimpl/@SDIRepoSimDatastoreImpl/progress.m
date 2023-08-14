function fract=progress(this)



    numChunks=getSignalNumChunks(this.Repo.sigRepository,this.SignalID);
    fract=double(this.LastReadChunkIndex)/double(numChunks);
end

