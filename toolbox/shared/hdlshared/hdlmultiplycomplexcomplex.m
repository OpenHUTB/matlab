function[hdlbody,hdlsignals]=hdlmultiplycomplexcomplex(in1,in2,out,rounding,saturation)







    hdlbody='';
    hdlsignals='';

    in1im=hdlsignalimag(in1);
    in2im=hdlsignalimag(in2);
    outim=hdlsignalimag(out);





    vtype=hdlsignalvtype(out);
    sltype=hdlsignalsltype(out);


    real_postfix=hdlgetparameter('complex_real_postfix');
    imag_postfix=hdlgetparameter('complex_imag_postfix');

    [re1,re1_ptr]=hdlnewsignal(['mul',real_postfix,'1'],'block',-1,0,0,vtype,sltype);
    [re2,re2_ptr]=hdlnewsignal(['mul',real_postfix,'2'],'block',-1,0,0,vtype,sltype);
    [im1,im1_ptr]=hdlnewsignal(['mul',imag_postfix,'1'],'block',-1,0,0,vtype,sltype);
    [im2,im2_ptr]=hdlnewsignal(['mul',imag_postfix,'2'],'block',-1,0,0,vtype,sltype);

    hdlsignals=[hdlsignals,makehdlsignaldecl([re1_ptr,re2_ptr,im1_ptr,im2_ptr])];



    [body1,signals1]=hdlmultiplyrealreal(in1,in2,re1_ptr,rounding,saturation);
    [body2,signals2]=hdlmultiplyrealreal(in1im,in2im,re2_ptr,rounding,saturation);
    [body3,signals3]=hdlsub(re1_ptr,re2_ptr,out,rounding,saturation,1);

    hdlbody=[hdlbody,body1,body2,body3];
    hdlsignals=[hdlsignals,signals1,signals2,signals3];



    [body1,signals1]=hdlmultiplyrealreal(in1im,in2,im1_ptr,rounding,saturation);
    [body2,signals2]=hdlmultiplyrealreal(in1,in2im,im2_ptr,rounding,saturation);
    [body3,signals3]=hdladd(im1_ptr,im2_ptr,outim,rounding,saturation);

    hdlbody=[hdlbody,body1,body2,body3];
    hdlsignals=[hdlsignals,signals1,signals2,signals3];