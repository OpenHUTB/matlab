%#codegen
function y=hdleml_bitshift(mode,N,u)


    coder.allowpcode('plain')
    eml_prefer_const(mode,N);

    outLen=length(u);
    y=hdleml_define_len(u,outLen);

    for ii=1:outLen
        idx=min(length(N),ii);
        switch mode
        case 1
            y(ii)=bitsll(u(ii),N(idx));
        case 2
            y(ii)=bitsrl(u(ii),N(idx));
        case 3
            y(ii)=bitsra(u(ii),N(idx));
        otherwise
            eml_assert(0,'failed to recognize shift mode');
        end
    end
