%#codegen
function y=hdleml_bitrotate(mode,N,u)


    coder.allowpcode('plain')
    eml_prefer_const(mode,N);

    outLen=length(u);
    y=hdleml_define_len(u,outLen);

    for ii=1:outLen

        switch mode
        case 1
            y(ii)=bitrol(u(ii),N);
        case 2
            y(ii)=bitror(u(ii),N);
        otherwise
            eml_assert(0,'failed to recognize rotate mode');
        end

    end

