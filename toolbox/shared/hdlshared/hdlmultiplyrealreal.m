function[hdlbody,hdlsignals]=hdlmultiplyrealreal(in1,in2,out,rounding,saturation)






    if hdlgetparameter('isvhdl')
        [hdlbody,hdlsignals]=vhdlmultiplyrealreal(in1,in2,out,rounding,saturation);
    elseif hdlgetparameter('isverilog')
        [hdlbody,hdlsignals]=verilogmultiplyrealreal(in1,in2,out,rounding,saturation);
    else
        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
    end


    sltype1=hdlsignalsltype(in1);
    [size1,~,~]=hdlwordsize(sltype1);

    sltype2=hdlsignalsltype(in2);
    [size2,~,~]=hdlwordsize(sltype2);

    if~((size1==1)||(size2==1))
        resourceLog(min(size1,size2),max(size1,size2),'mul')
    end


