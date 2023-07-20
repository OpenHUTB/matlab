function hdltbbody=hdlpackage(this,hdltbbody,tbpkgfid,tbdatafid)





    if hdlgetparameter('isvhdl')
        this.vhdlpackage(hdltbbody,tbpkgfid,tbdatafid);
    else
        hdltbbody=this.verilogpackage(hdltbbody,tbpkgfid,tbdatafid);
    end
