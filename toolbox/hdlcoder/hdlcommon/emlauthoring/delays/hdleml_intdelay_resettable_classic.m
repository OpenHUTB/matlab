%#codegen
function y=hdleml_intdelay_resettable_classic(u,rst,N,ic)






    coder.allowpcode('plain')
    eml_prefer_const(N,ic);

    persistent reg;
    if isempty(reg)


        reg=eml_const(ic);
    end

    if(rst==1)

        y=eml_const(ic(:,N));
    else
        y=reg(:,N);
    end

    reg=[u,reg(:,1:(N-1))];



