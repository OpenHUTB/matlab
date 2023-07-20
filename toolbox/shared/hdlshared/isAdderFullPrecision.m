function[fp]=isAdderFullPrecision(in1,in2,out)






    sltypein1=hdlsignalsltype(in1);
    [in1size,in1bp]=hdlgetsizesfromtype(sltypein1);
    sltypein2=hdlsignalsltype(in2);
    [in2size,in2bp]=hdlgetsizesfromtype(sltypein2);

    sltypeout=hdlsignalsltype(out);
    [outsize,outbp]=hdlgetsizesfromtype(sltypeout);


    act_outbp=max(in1bp,in2bp);
    act_outsize=max(in1size-in1bp,in2size-in2bp)+act_outbp+1;


    if outsize==act_outsize&&outbp==act_outbp
        fp=1;
    else
        fp=0;
    end
end

