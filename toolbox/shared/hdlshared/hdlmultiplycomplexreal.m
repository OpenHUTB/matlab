function[hdlbody,hdlsignals]=hdlmultiplycomplexreal(in1,in2,out,rounding,saturation)








    hdlbody='';
    hdlsignals='';

    in1im=hdlsignalimag(in1);
    outim=hdlsignalimag(out);

    [body1,signals1]=hdlmultiplyrealreal(in1,in2,out,rounding,saturation);
    [body2,signals2]=hdlmultiplyrealreal(in1im,in2,outim,rounding,saturation);

    hdlbody=[hdlbody,body1,body2];
    hdlsignals=[hdlsignals,signals1,signals2];



