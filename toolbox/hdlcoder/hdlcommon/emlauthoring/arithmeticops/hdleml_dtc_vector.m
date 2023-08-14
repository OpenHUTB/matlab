%#codegen
function y=hdleml_dtc_vector(u,outtpex,mode,outIsBool)


    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(outtpex,mode,outIsBool);

    outLen=length(u);
    y=hdleml_define_len(outtpex,outLen);

    if outIsBool
        for ii=coder.unroll(1:outLen)
            y(ii)=hdleml_dtc(u(ii),outtpex,mode,outIsBool);
        end
    else
        for ii=1:outLen
            y(ii)=hdleml_dtc(u(ii),outtpex,mode,outIsBool);
        end
    end
