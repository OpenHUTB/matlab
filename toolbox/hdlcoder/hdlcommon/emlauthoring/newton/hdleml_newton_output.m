%#codegen
function xout=hdleml_newton_output(xin,dynamicShift,preshift_ex,denorm_ex,output_ex)





    coder.allowpcode('plain')
    eml_prefer_const(dynamicShift,preshift_ex,denorm_ex,output_ex);


    xcast=fi(xin,numerictype(preshift_ex),hdlfimath);


    xshift=bitsll(xcast,int(dynamicShift));



    xdenorm=reinterpretcast(xshift,numerictype(denorm_ex));


    xout=fi(xdenorm,numerictype(output_ex),fimath(output_ex));
