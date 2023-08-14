function hdlcode=hdltbcodercodeinit(this,node,level,nname)


    if hdlgetparameter('isverilog')
        hdlcode=this.verilogtbcodercodeinit(node,level,nname);
    elseif hdlgetparameter('isvhdl')
        hdlcode=this.vhdltbcodercodeinit(node,level,nname);
    end