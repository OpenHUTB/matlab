%#codegen
function y=hdleml_delay_enabled_classic(u,enb,ic)





    coder.allowpcode('plain')
    eml_prefer_const(ic);

    persistent bypass_delay
    if isempty(bypass_delay)
        bypass_delay=bypass_register_init(ic,size(ic));
    end

    persistent reg;
    if isempty(reg)


        reg=eml_const(ic);
    end

    if(enb==1)
        y=reg;
    else
        y=bypass_delay;
    end

    bypass_delay=reg;

    reg=u;



