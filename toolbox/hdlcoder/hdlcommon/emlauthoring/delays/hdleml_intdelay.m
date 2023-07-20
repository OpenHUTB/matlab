%#codegen
function y=hdleml_intdelay(u,N,ic)






    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(N,ic);

    persistent reg;
    if isempty(reg)


        reg=eml_const(ic);
    end

    y=reg(:,N);

    reg=[u,reg(:,1:(N-1))];
