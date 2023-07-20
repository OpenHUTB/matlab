function hdlbody=hdlchecker(this,rdenb,checker_enb,addr,instance,errCnt,testFailure)


    if hdlgetparameter('isvhdl')
        hdlbody=this.vhdlchecker(rdenb,checker_enb,addr,instance,errCnt,testFailure);
    else
        hdlbody=this.verilogchecker(rdenb,checker_enb,addr,instance,errCnt,testFailure);
    end
