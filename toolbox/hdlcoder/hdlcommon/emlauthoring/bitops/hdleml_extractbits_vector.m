%#codegen
function y=hdleml_extractbits_vector(msb,lsb,mode,outtpex,u)


    coder.allowpcode('plain')
    eml_prefer_const(msb,lsb,mode,outtpex);

    outLen=length(u);
    y=hdleml_define_len(outtpex,outLen);

    for ii=coder.unroll(1:outLen)
        y(ii)=hdleml_extractbits(msb,lsb,mode,u(ii));
    end

