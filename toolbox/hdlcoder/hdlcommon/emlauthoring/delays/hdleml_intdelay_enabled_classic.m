%#codegen
function y=hdleml_intdelay_enabled_classic(u,enb,N,ic)






    coder.allowpcode('plain')
    eml_prefer_const(N,ic);

    persistent bypass_delay
    if isempty(bypass_delay)
        bypass_delay=bypass_register_init(ic,size(ic(:,N)));
    end

    persistent reg;
    if isempty(reg)


        reg=eml_const(ic);
    end

    if(enb==1)
        y=reg(:,N);
    else
        y=bypass_delay;
    end

    bypass_delay=reg(:,N);

    reg=[u,reg(:,1:(N-1))];



