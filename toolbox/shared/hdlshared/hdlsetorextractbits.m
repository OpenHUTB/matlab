function hdlbody=hdlsetorextractbits(in,out,bitindex,bitvalstr)






    if length(in)~=1||length(out)~=1
        error(message('HDLShared:directemit:arrayinput'));
    end


    gConnOld=hdlconnectivity.genConnectivity(0);
    if gConnOld,
        hConnDir=hdlconnectivity.getConnectivityDirector;
        hConnDir.addDriverReceiverPair(in,out,'realonly',true,'unroll',true);
    end


    if hdlgetparameter('isvhdl')
        hdlbody=vhdlsetorextractbits(in,out,bitindex,bitvalstr);
    elseif hdlgetparameter('isverilog')
        hdlbody=verilogsetorextractbits(in,out,bitindex,bitvalstr);
    else
        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
    end


    hdlconnectivity.genConnectivity(gConnOld);


