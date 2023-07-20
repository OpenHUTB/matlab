%#codegen
function y=hdleml_dynamic_bitshift(mode,u,s)


    coder.allowpcode('plain')
    eml_prefer_const(mode);

    outLen=length(u);
    y=hdleml_define_len(u,outLen);

    eml_assert(isequal(size(s),size(u)),'dimensions of input and shift value variables are mismatched');

    for idx=(1:outLen)
        switch mode
        case 1
            y(idx)=bitsll(u(idx),s(idx));
        case 2
            y(idx)=bitsra(u(idx),s(idx));
        otherwise
            eml_assert(0,'failed to recognize shift mode');
        end
    end

