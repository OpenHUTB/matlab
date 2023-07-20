%#codegen
function y=hdleml_intdelay_enabled_resettable_classic(u,rst,enb,N,ic)






    coder.allowpcode('plain')
    eml_prefer_const(N,ic);

    persistent bypass
    if isempty(bypass)
        bypass=bypass_register_init(ic,size(ic(:,N)));
    end

    persistent reg;
    if isempty(reg)


        reg=eml_const(ic);
    end

    if(rst==1)

        delay_out=eml_const(ic(:,N));
    else
        delay_out=reg(:,N);
    end

    if(enb==1)
        y=delay_out;
    else
        y=bypass;
    end

    bypass=delay_out;

    reg=[u,reg(:,1:(N-1))];



