%#codegen
function varargout=hdleml_cplx2reim(u,mode)


    coder.allowpcode('plain')
    eml_prefer_const(mode);

    switch mode
    case 1

        varargout{1}=real(u);
        varargout{2}=imag(u);
    case 2

        varargout{1}=real(u);
    case 3

        varargout{1}=imag(u);
    end
