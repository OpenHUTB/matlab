%#codegen
function xout=hdleml_recipnewton_output(xin,dynamicShift,oneMoreShift,maxEvenDynamicShift,intermWL,outflreqwidshift,denorm_ex,output_ex)





    coder.allowpcode('plain')
    eml_prefer_const(dynamicShift,maxEvenDynamicShift,outflreqwidshift,denorm_ex,output_ex);


    prexshift=construct_even_dynamicshifter(xin,dynamicShift,maxEvenDynamicShift,intermWL,outflreqwidshift);


    fm=hdlfimath;


    if oneMoreShift==fi(0,0,1,0,fm)
        xshift=bitsra(prexshift,1);
    else
        xshift=prexshift;
    end




    xdenorm=reinterpretcast(xshift,numerictype(denorm_ex));


    xout=fi(xdenorm,numerictype(output_ex),fimath(output_ex));
end

function y=construct_even_dynamicshifter(u,sel,maxEvenDynamicShift,intermWL,outflreqwidshift)

    eml_prefer_const(maxEvenDynamicShift,intermWL,outflreqwidshift);

    zero=fi(0,numerictype(u),fimath(u));
    shiftarr=hdleml_define_len(zero,maxEvenDynamicShift/2+1);
    for ii=coder.unroll(0:2:maxEvenDynamicShift-1)





        shiftarr(ii/2+1)=bitsra(u,intermWL-ii-outflreqwidshift-1);
    end

    shiftarr(maxEvenDynamicShift/2+1)=u;
    y=shiftarr(sel+1);
end
