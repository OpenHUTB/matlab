function y=hdleml_init_len(u,outLen)



%#codegen

    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(outLen);

    if isreal(u)
        y=hdleml_init_real(u,outLen);
    else
        y_r=hdleml_init_real(real(u),outLen);
        y=complex(y_r,y_r);
    end

end

function y=hdleml_init_real(u,outLen)
    eml_prefer_const(outLen);

    if coder.isenum(u)
        eml_assert(false,'Enumerated types are not supported by hdleml_init_len.');
    else
        y=zeros(outLen,1,'like',u);
    end
end

