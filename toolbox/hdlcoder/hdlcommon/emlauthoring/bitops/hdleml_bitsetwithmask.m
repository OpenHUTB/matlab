%#codegen
function y=hdleml_bitsetwithmask(modeIsSet,bitMask,u)


    coder.allowpcode('plain')
    eml_prefer_const(modeIsSet,bitMask);

    outLen=length(u);
    y=hdleml_define_len(u,outLen);

    if length(bitMask)~=outLen
        eml_assert(0,'vector-length mismatch');
    end

    for ii=coder.unroll(1:outLen)

        if modeIsSet
            y(ii)=eml_bitor(u(ii),bitMask(ii));
        else
            y(ii)=eml_bitand(u(ii),bitMask(ii));
        end
    end

