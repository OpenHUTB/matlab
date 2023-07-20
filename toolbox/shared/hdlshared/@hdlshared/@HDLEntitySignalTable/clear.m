function clear(this)





    hSignal=this.down;
    while~isempty(hSignal)
        disconnect(hSignal);
        hSignal=hSignal.right;
    end








    this.reset;
    this.Names=containers.Map;
