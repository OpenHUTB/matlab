function CloseCallback(this)


    if~isempty(this.fSigSelWid)
        this.fSigSelWid.TCPeer.delete;
        this.fSigSelWid=[];
    end
    this.delete;
end
