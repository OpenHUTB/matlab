%#codegen
function y=hdleml_bitreduce(mode,u)


    coder.allowpcode('plain')
    eml_prefer_const(mode);

    switch mode
    case 1
        y=bitandreduce(u);
    case 2
        y=bitorreduce(u);
    case 3
        y=bitxorreduce(u);
    otherwise
        eml_assert(0,'failed to recognize reduce mode');
    end



