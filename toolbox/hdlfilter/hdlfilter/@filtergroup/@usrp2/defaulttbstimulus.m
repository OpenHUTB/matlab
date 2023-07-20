function stimcell=defaulttbstimulus(this)










    Rxstimcell=defaulttbstimulus(this.RxChain);
    Txstimcell=defaulttbstimulus(this.TxChain);
    stimcell=intersect(Rxstimcell,Txstimcell);





