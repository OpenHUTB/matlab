function hF=createhdlfilter(this)





    hF=hdlfilter.usrp2;
    hF.RxChain=createhdlfilter(this.RxChain);
    hF.TxChain=createhdlfilter(this.TxChain);
    hF.FilterStructure=this.FilterStructure;


